import Vapor
import Fluent
import FluentPostgresDriver

struct HealthResponse: Content {
    let status: String
    let service: String
    let version: String
}

struct ReadinessResponse: Content {
    let status: String
    let database: String
}

func routes(_ app: Application) throws {

    app.get("health") { request async -> HealthResponse in
        HealthResponse(
            status: "ok",
            service: "lurewake-api",
            version: "0.1.0-dev"
        )
    }

    app.get("ready") { request async throws -> ReadinessResponse in

        guard Environment.get(
            "LUREWAKE_DB_PASSWORD"
        )?.isEmpty == false else {
            throw Abort(
                .serviceUnavailable,
                reason: "Database not configured"
            )
        }

        guard let postgres = request.db(.psql) as? PostgresDatabase else {
            throw Abort(
                .serviceUnavailable,
                reason: "PostgreSQL driver unavailable"
            )
        }

        do {
            let rows = try await postgres.simpleQuery(
                "SELECT 1 AS connectivity_check"
            ).get()

            guard !rows.isEmpty else {
                throw Abort(.serviceUnavailable)
            }

            return ReadinessResponse(
                status: "ok",
                database: "postgresql"
            )

        } catch {
            request.logger.warning(
                "Database readiness probe failed"
            )

            throw Abort(
                .serviceUnavailable,
                reason: "Database unavailable"
            )
        }
    }
}
