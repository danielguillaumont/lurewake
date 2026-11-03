@testable import LurewakeAPI

import Foundation
import Vapor
import VaporTesting
import Testing

@Suite("Protected Lure Archiving")
struct LureArchivalSecurityTests {

    private let token = String(
        repeating: "t",
        count: 64
    )

    private let lureID =
        "00000000-0000-4000-8000-000000000001"

    @Test("Archive without credentials is rejected")
    func missingCredentials() async throws {
        try await withApp { app in
            registerLureArchivalRoutes(
                app,
                configuredToken: token
            )

            try await app.testing().test(
                .PATCH,
                "api/v1/lures/\(lureID)/archive"
            ) { response async in
                #expect(response.status == .unauthorized)
            }
        }
    }

    @Test("Archive with incorrect credentials is rejected")
    func incorrectCredentials() async throws {
        try await withApp { app in
            registerLureArchivalRoutes(
                app,
                configuredToken: token
            )

            try await app.testing().test(
                .PATCH,
                "api/v1/lures/\(lureID)/archive",
                headers: [
                    "Authorization": "Bearer incorrect-token"
                ]
            ) { response async in
                #expect(response.status == .unauthorized)
            }
        }
    }

    @Test("Missing operator configuration fails closed")
    func missingConfiguration() async throws {
        try await withApp { app in
            registerLureArchivalRoutes(
                app,
                configuredToken: nil
            )

            try await app.testing().test(
                .PATCH,
                "api/v1/lures/\(lureID)/archive",
                headers: [
                    "Authorization": "Bearer \(token)"
                ]
            ) { response async in
                #expect(response.status == .unauthorized)
            }
        }
    }

    @Test("Malformed lure identifier is rejected")
    func invalidIdentifier() async throws {
        try await withApp { app in
            registerLureArchivalRoutes(
                app,
                configuredToken: token
            )

            try await app.testing().test(
                .PATCH,
                "api/v1/lures/not-a-uuid/archive",
                headers: [
                    "Authorization": "Bearer \(token)"
                ]
            ) { response async in
                #expect(response.status == .badRequest)
            }
        }
    }
}
