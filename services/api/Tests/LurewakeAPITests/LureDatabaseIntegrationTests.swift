@testable import LurewakeAPI

import Fluent
import FluentPostgresDriver
import Foundation
import Testing
import Vapor
import VaporTesting

@Suite("PostgreSQL Lure Integration", .serialized)
struct LureDatabaseIntegrationTests {

    @Test(
        "Persisted draft is returned by the inventory API",
        .enabled(
            if: ProcessInfo.processInfo.environment[
                "LUREWAKE_RUN_DB_TESTS"
            ] == "1"
        )
    )
    func persistedDraftAppearsInInventory() async throws {

        let password = try #require(
            Environment.get("LUREWAKE_DB_PASSWORD")
        )

        let app = try await Application.make(.testing)

        do {
            // Intentionally connect ONLY to the test database.
            app.databases.use(
                DatabaseConfigurationFactory.postgres(
                    configuration: .init(
                        hostname: "127.0.0.1",
                        port: 5433,
                        username: "lurewake",
                        password: password,
                        database: "lurewake_test",
                        tls: .disable
                    )
                ),
                as: .psql
            )

            app.migrations.add(CreateLures())

            try routes(app)
            registerLureInventoryRoutes(app)

            try await app.autoMigrate()

            let draft = Lure()
            draft.name = "LW-AUTO-" + UUID().uuidString
            draft.kind = "document"
            draft.status = "draft"
            draft.notes = "AUTOMATED_TEST_ONLY"

            try await draft.create(on: app.db(.psql))

            let draftID = try draft.requireID()

            do {
                try await app.testing().test(
                    .GET,
                    "api/v1/lures"
                ) { response async throws in

                    #expect(response.status == .ok)

                    let inventory = try response.content.decode(
                        LureInventoryResponse.self
                    )

                    let result = try #require(
                        inventory.items.first {
                            $0.id == draftID
                        }
                    )

                    #expect(result.name == draft.name)
                    #expect(result.kind == "document")
                    #expect(result.status == "draft")
                    #expect(inventory.returnedCount >= 1)
                    #expect(inventory.limit == 100)
                }
            } catch {
                try? await draft.delete(on: app.db(.psql))
                throw error
            }

            // Clean up only the record this test created.
            try await draft.delete(on: app.db(.psql))

            // Confirm the deleted record is no longer listed.
            try await app.testing().test(
                .GET,
                "api/v1/lures"
            ) { response async throws in

                #expect(response.status == .ok)

                let inventory = try response.content.decode(
                    LureInventoryResponse.self
                )

                #expect(
                    !inventory.items.contains {
                        $0.id == draftID
                    }
                )
            }

        } catch {
            try? await app.asyncShutdown()
            throw error
        }

        try await app.asyncShutdown()
    }

    @Test(
        "Authenticated creation persists and cleans up its draft",
        .enabled(
            if: ProcessInfo.processInfo.environment[
                "LUREWAKE_RUN_DB_TESTS"
            ] == "1"
        )
    )
    func authenticatedDraftCreationPersists() async throws {

        let password = try #require(
            Environment.get("LUREWAKE_DB_PASSWORD")
        )

        let token = String(repeating: "t", count: 64)
        let recordName = "LW-V01-ROUTE-" + UUID().uuidString
        let cleanedNotes = "Automated PostgreSQL route test"

        let app = try await Application.make(.testing)

        do {
            // Never use the development database.
            app.databases.use(
                DatabaseConfigurationFactory.postgres(
                    configuration: .init(
                        hostname: "127.0.0.1",
                        port: 5433,
                        username: "lurewake",
                        password: password,
                        database: "lurewake_test",
                        tls: .disable
                    )
                ),
                as: .psql
            )

            app.migrations.add(CreateLures())

            registerLureInventoryRoutes(app)
            registerLureCreationRoutes(
                app,
                configuredToken: token
            )

            try await app.autoMigrate()

            let initialCount = try await Lure.query(
                on: app.db(.psql)
            ).count()

            let validPayload = CreateLureRequest(
                name: recordName,
                kind: "link",
                notes: "  \(cleanedNotes)  "
            )

            // No token: must reject the write.
            try await app.testing().test(
                .POST,
                "api/v1/lures",
                beforeRequest: { request in
                    try request.content.encode(validPayload)
                },
                afterResponse: { response async in
                    #expect(response.status == .unauthorized)
                }
            )

            // Wrong token: must reject the write.
            try await app.testing().test(
                .POST,
                "api/v1/lures",
                headers: [
                    "Authorization": "Bearer invalid-token"
                ],
                beforeRequest: { request in
                    try request.content.encode(validPayload)
                },
                afterResponse: { response async in
                    #expect(response.status == .unauthorized)
                }
            )

            // Correct token, invalid metadata: reject.
            try await app.testing().test(
                .POST,
                "api/v1/lures",
                headers: [
                    "Authorization": "Bearer \(token)"
                ],
                beforeRequest: { request in
                    try request.content.encode(
                        CreateLureRequest(
                            name: "ab",
                            kind: "link",
                            notes: nil
                        )
                    )
                },
                afterResponse: { response async in
                    #expect(response.status == .badRequest)
                }
            )

            let countAfterRejections = try await Lure.query(
                on: app.db(.psql)
            ).count()

            #expect(countAfterRejections == initialCount)

            // Valid, authenticated HTTP creation.
            try await app.testing().test(
                .POST,
                "api/v1/lures",
                headers: [
                    "Authorization": "Bearer \(token)"
                ],
                beforeRequest: { request in
                    try request.content.encode(validPayload)
                },
                afterResponse: { response async throws in
                    #expect(response.status == .created)

                    let summary = try response.content.decode(
                        LureSummary.self
                    )

                    #expect(summary.name == recordName)
                    #expect(summary.kind == "link")
                    #expect(summary.status == "draft")
                }
            )

            // Verify the actual stored PostgreSQL row.
            let matches = try await Lure.query(
                on: app.db(.psql)
            )
            .filter(\.$name == recordName)
            .all()

            #expect(matches.count == 1)

            let saved = try #require(matches.first)

            #expect(saved.kind == "link")
            #expect(saved.status == "draft")
            #expect(saved.notes == cleanedNotes)

            // Verify the record also appears through GET.
            let savedID = try saved.requireID()

            try await app.testing().test(
                .GET,
                "api/v1/lures"
            ) { response async throws in
                #expect(response.status == .ok)

                let inventory = try response.content.decode(
                    LureInventoryResponse.self
                )

                #expect(
                    inventory.items.contains {
                        $0.id == savedID
                    }
                )
            }

            // Delete only the record created by this test.
            try await saved.delete(on: app.db(.psql))

            let finalCount = try await Lure.query(
                on: app.db(.psql)
            ).count()

            #expect(finalCount == initialCount)

        } catch {
            // Best-effort cleanup if an assertion throws.
            if let leftovers = try? await Lure.query(
                on: app.db(.psql)
            )
            .filter(\.$name == recordName)
            .all() {
                for record in leftovers {
                    try? await record.delete(
                        on: app.db(.psql)
                    )
                }
            }

            try? await app.asyncShutdown()
            throw error
        }

        try await app.asyncShutdown()
    }


    @Test(
        "Authenticated archiving persists and prevents repeat transitions",
        .enabled(
            if: ProcessInfo.processInfo.environment[
                "LUREWAKE_RUN_DB_TESTS"
            ] == "1"
        )
    )
    func authenticatedArchivalPersists() async throws {

        let password = try #require(
            Environment.get("LUREWAKE_DB_PASSWORD")
        )

        let token = String(repeating: "t", count: 64)

        let draft = Lure(
            name: "LW-V01-ARCHIVE-" + UUID().uuidString,
            kind: "document",
            status: "draft",
            notes: "Automated archive integration test"
        )

        let app = try await Application.make(.testing)

        do {
            // This is the isolated TEST database only.
            app.databases.use(
                DatabaseConfigurationFactory.postgres(
                    configuration: .init(
                        hostname: "127.0.0.1",
                        port: 5433,
                        username: "lurewake",
                        password: password,
                        database: "lurewake_test",
                        tls: .disable
                    )
                ),
                as: .psql
            )

            app.migrations.add(CreateLures())

            registerLureInventoryRoutes(app)

            registerLureArchivalRoutes(
                app,
                configuredToken: token
            )

            try await app.autoMigrate()

            let initialCount = try await Lure.query(
                on: app.db(.psql)
            ).count()

            try await draft.create(on: app.db(.psql))

            let draftID = try draft.requireID()
            let archivePath =
                "api/v1/lures/\(draftID.uuidString)/archive"

            // Verify that a legitimate draft can be archived.
            try await app.testing().test(
                .PATCH,
                archivePath,
                headers: [
                    "Authorization": "Bearer \(token)"
                ]
            ) { response async throws in

                #expect(response.status == .ok)

                let result = try response.content.decode(
                    LureSummary.self
                )

                #expect(result.id == draftID)
                #expect(result.name == draft.name)
                #expect(result.kind == "document")
                #expect(result.status == "archived")
            }

            // Read a fresh model from PostgreSQL.
            let saved = try await Lure.find(
                draftID,
                on: app.db(.psql)
            )

            let persisted = try #require(saved)

            #expect(persisted.status == "archived")
            #expect(persisted.notes == draft.notes)

            // Confirm that inventory reflects the new state.
            try await app.testing().test(
                .GET,
                "api/v1/lures"
            ) { response async throws in

                #expect(response.status == .ok)

                let inventory = try response.content.decode(
                    LureInventoryResponse.self
                )

                let entry = try #require(
                    inventory.items.first {
                        $0.id == draftID
                    }
                )

                #expect(entry.status == "archived")
            }

            // Archiving twice must not be accepted.
            try await app.testing().test(
                .PATCH,
                archivePath,
                headers: [
                    "Authorization": "Bearer \(token)"
                ]
            ) { response async in
                #expect(response.status == .conflict)
            }

            // An unknown but valid UUID must return 404.
            let unknownID = UUID().uuidString

            try await app.testing().test(
                .PATCH,
                "api/v1/lures/\(unknownID)/archive",
                headers: [
                    "Authorization": "Bearer \(token)"
                ]
            ) { response async in
                #expect(response.status == .notFound)
            }

            // Delete only this test's temporary record.
            try await draft.delete(on: app.db(.psql))

            let finalCount = try await Lure.query(
                on: app.db(.psql)
            ).count()

            #expect(finalCount == initialCount)

        } catch {
            // Best-effort cleanup if an operation throws.
            try? await draft.delete(on: app.db(.psql))
            try? await app.asyncShutdown()
            throw error
        }

        try await app.asyncShutdown()
    }

}
