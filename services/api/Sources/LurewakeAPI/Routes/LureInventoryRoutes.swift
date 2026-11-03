import Fluent
import Foundation
import Vapor

struct LureSummary: Content {
    let id: UUID
    let name: String
    let kind: String
    let status: String
    let createdAt: Date?
}

struct LureInventoryResponse: Content {
    let items: [LureSummary]
    let returnedCount: Int
    let limit: Int
}

func registerLureInventoryRoutes(_ app: Application) {

    app.get("api", "v1", "lures") {
        request async throws -> LureInventoryResponse in

        guard Environment.get(
            "LUREWAKE_DB_PASSWORD"
        )?.isEmpty == false else {
            throw Abort(
                .serviceUnavailable,
                reason: "Database not configured"
            )
        }

        let lures = try await Lure.query(
            on: request.db(.psql)
        )
        .sort(\.$name, .ascending)
        .limit(100)
        .all()

        let summaries = try lures.map { lure in
            LureSummary(
                id: try lure.requireID(),
                name: lure.name,
                kind: lure.kind,
                status: lure.status,
                createdAt: lure.createdAt
            )
        }

        return LureInventoryResponse(
            items: summaries,
            returnedCount: summaries.count,
            limit: 100
        )
    }
}
