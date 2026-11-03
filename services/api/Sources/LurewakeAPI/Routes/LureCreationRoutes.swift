import Fluent
import Vapor

struct CreateLureRequest: Content {
    let name: String
    let kind: String
    let notes: String?
}

func registerLureCreationRoutes(
    _ app: Application,
    configuredToken: String?
) {
    let protected = app.routes.grouped([
        LureOperatorAuthenticator(
            configuredToken: configuredToken
        ),
        LureOperator.guardMiddleware()
    ])

    protected.post("api", "v1", "lures") {
        request async throws -> Response in

        let input = try request.content.decode(
            CreateLureRequest.self
        )

        let draft: ValidatedLureDraft

        do {
            draft = try LureDraftPolicy.validate(
                name: input.name,
                kind: input.kind,
                notes: input.notes
            )
        } catch is LureDraftValidationError {
            throw Abort(
                .badRequest,
                reason: "Invalid draft metadata"
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

        let lure = Lure(
            name: draft.name,
            kind: draft.kind.rawValue,
            status: draft.status.rawValue,
            notes: draft.notes
        )

        try await lure.save(
            on: request.db(.psql)
        )

        let summary = LureSummary(
            id: try lure.requireID(),
            name: lure.name,
            kind: lure.kind,
            status: lure.status,
            createdAt: lure.createdAt
        )

        let response = Response(status: .created)
        try response.content.encode(summary)

        return response
    }
}
