import Fluent
import Foundation
import Vapor

func registerLureArchivalRoutes(
    _ app: Application,
    configuredToken: String?
) {
    let protected = app.routes.grouped([
        LureOperatorAuthenticator(
            configuredToken: configuredToken
        ),
        LureOperator.guardMiddleware()
    ])

    protected.patch(
        "api", "v1", "lures", ":lureID", "archive"
    ) { request async throws -> Response in

        guard let rawID = request.parameters.get("lureID"),
              let lureID = UUID(uuidString: rawID) else {
            throw Abort(
                .badRequest,
                reason: "Invalid lure identifier"
            )
        }

        guard Environment.get(
            "LUREWAKE_DB_PASSWORD"
        )?.isEmpty == false else {
            throw Abort(
                .serviceUnavailable,
                reason: "Database unavailable"
            )
        }

        guard let lure = try await Lure.find(
            lureID,
            on: request.db(.psql)
        ) else {
            throw Abort(
                .notFound,
                reason: "Lure not found"
            )
        }

        guard let current = LureLifecycleStatus(
            rawValue: lure.status
        ) else {
            throw Abort(
                .conflict,
                reason: "Unsupported lifecycle status"
            )
        }

        do {
            try LureLifecyclePolicy.validateTransition(
                from: current,
                to: .archived
            )
        } catch is LureLifecycleError {
            throw Abort(
                .conflict,
                reason: "Lure cannot be archived from its current state"
            )
        }

        lure.status = LureLifecycleStatus.archived.rawValue

        try await lure.save(on: request.db(.psql))

        let summary = LureSummary(
            id: try lure.requireID(),
            name: lure.name,
            kind: lure.kind,
            status: lure.status,
            createdAt: lure.createdAt
        )

        let response = Response(status: .ok)
        try response.content.encode(summary)
        return response
    }
}
