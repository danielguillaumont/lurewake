@testable import LurewakeAPI

import Vapor
import VaporTesting
import Testing

@Suite("Lure Operator Authentication")
struct LureOperatorAuthTests {

    private let testToken = String(
        repeating: "a",
        count: 64
    )

    @Test("Requests without a token are rejected")
    func missingToken() async throws {
        try await withApp { app in
            registerProtectedTestRoute(
                on: app,
                token: testToken
            )

            try await app.testing().test(
                .GET,
                "test/operator"
            ) { response async in
                #expect(response.status == .unauthorized)
            }
        }
    }

    @Test("Incorrect bearer tokens are rejected")
    func incorrectToken() async throws {
        try await withApp { app in
            registerProtectedTestRoute(
                on: app,
                token: testToken
            )

            try await app.testing().test(
                .GET,
                "test/operator",
                headers: [
                    "Authorization": "Bearer invalid-token"
                ]
            ) { response async in
                #expect(response.status == .unauthorized)
            }
        }
    }

    @Test("Correct operator token is accepted")
    func correctToken() async throws {
        try await withApp { app in
            registerProtectedTestRoute(
                on: app,
                token: testToken
            )

            try await app.testing().test(
                .GET,
                "test/operator",
                headers: [
                    "Authorization": "Bearer \(testToken)"
                ]
            ) { response async in
                #expect(response.status == .ok)
            }
        }
    }

    @Test("Missing server configuration fails closed")
    func noConfiguredToken() async throws {
        try await withApp { app in
            registerProtectedTestRoute(
                on: app,
                token: nil
            )

            try await app.testing().test(
                .GET,
                "test/operator",
                headers: [
                    "Authorization": "Bearer \(testToken)"
                ]
            ) { response async in
                #expect(response.status == .unauthorized)
            }
        }
    }

    private func registerProtectedTestRoute(
        on app: Application,
        token: String?
    ) {
        app.routes.grouped([
            LureOperatorAuthenticator(
                configuredToken: token
            ),
            LureOperator.guardMiddleware()
        ])
        .get("test", "operator") { _ -> String in
            "authorized"
        }
    }
}
