import Vapor

// MARK: - Authenticated Operator

struct LureOperator: Authenticatable, Sendable {}

// MARK: - Bearer Authentication

struct LureOperatorAuthenticator: BearerAuthenticator {

    let configuredToken: String?

    func authenticate(
        bearer: BearerAuthorization,
        for request: Request
    ) -> EventLoopFuture<Void> {

        // Fail closed if no sufficiently long
        // server-side token is configured.

        guard let configuredToken,
              configuredToken.utf8.count >= 32 else {
            return request.eventLoop.makeSucceededFuture(())
        }

        // This is a local-development authenticator.
        // Harden token verification before production use.

        if bearer.token == configuredToken {
            request.auth.login(LureOperator())
        }

        return request.eventLoop.makeSucceededFuture(())
    }
}
