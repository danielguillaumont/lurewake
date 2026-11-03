import Crypto
import Foundation
import Vapor

struct LureOperator: Authenticatable, Sendable {}

struct LureOperatorAuthenticator: BearerAuthenticator {

    let configuredToken: String?

    private static let challenge = Data(
        "lurewake-operator-auth-v1".utf8
    )

    func authenticate(
        bearer: BearerAuthorization,
        for request: Request
    ) -> EventLoopFuture<Void> {

        guard let configuredToken,
              configuredToken.utf8.count >= 32 else {
            return request.eventLoop.makeSucceededFuture(())
        }

        let referenceKey = SymmetricKey(
            data: Data(configuredToken.utf8)
        )

        let candidateKey = SymmetricKey(
            data: Data(bearer.token.utf8)
        )

        let expectedCode = HMAC<SHA256>.authenticationCode(
            for: Self.challenge,
            using: referenceKey
        )

        if HMAC<SHA256>.isValidAuthenticationCode(
            expectedCode,
            authenticating: Self.challenge,
            using: candidateKey
        ) {
            request.auth.login(LureOperator())
        }

        return request.eventLoop.makeSucceededFuture(())
    }
}
