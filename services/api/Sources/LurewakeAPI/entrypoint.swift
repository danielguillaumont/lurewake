import Vapor

@main
enum LurewakeServer {
    static func main() async throws {
        let environment = try Environment.detect()
        let app = try await Application.make(environment)

        do {
            try await configure(app)
            try await app.execute()
        } catch {
            app.logger.report(error: error)
            try? await app.asyncShutdown()
            throw error
        }

        try await app.asyncShutdown()
    }
}
