import Vapor

struct HealthResponse: Content {
    let status: String
    let service: String
    let version: String
}

func routes(_ app: Application) throws {
    app.get("health") { request async -> HealthResponse in
        HealthResponse(
            status: "ok",
            service: "lurewake-api",
            version: "0.0.0-prep"
        )
    }
}
