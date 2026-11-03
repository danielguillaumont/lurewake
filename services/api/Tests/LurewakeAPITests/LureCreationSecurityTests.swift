@testable import LurewakeAPI

import Vapor
import VaporTesting
import Testing

@Suite("Protected Lure Creation")
struct LureCreationSecurityTests {

    private let token = String(
        repeating: "a",
        count: 64
    )

    @Test("Creation without credentials is rejected")
    func missingCredentials() async throws {
        try await withApp { app in
            registerLureCreationRoutes(
                app,
                configuredToken: token
            )

            try await app.testing().test(
                .POST,
                "api/v1/lures"
            ) { response async in
                #expect(response.status == .unauthorized)
            }
        }
    }

    @Test("Incorrect credentials cannot create drafts")
    func incorrectCredentials() async throws {
        try await withApp { app in
            registerLureCreationRoutes(
                app,
                configuredToken: token
            )

            try await app.testing().test(
                .POST,
                "api/v1/lures",
                headers: [
                    "Authorization": "Bearer incorrect-token"
                ]
            ) { response async in
                #expect(response.status == .unauthorized)
            }
        }
    }

    @Test("Missing operator configuration fails closed")
    func noConfiguredOperator() async throws {
        try await withApp { app in
            registerLureCreationRoutes(
                app,
                configuredToken: nil
            )

            try await app.testing().test(
                .POST,
                "api/v1/lures",
                headers: [
                    "Authorization": "Bearer \(token)"
                ]
            ) { response async in
                #expect(response.status == .unauthorized)
            }
        }
    }

    @Test("Invalid draft metadata is rejected")
    func invalidDraft() async throws {
        try await withApp { app in
            registerLureCreationRoutes(
                app,
                configuredToken: token
            )

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
                            kind: "document",
                            notes: nil
                        )
                    )
                },
                afterResponse: { response async in
                    #expect(response.status == .badRequest)
                }
            )
        }
    }
}
