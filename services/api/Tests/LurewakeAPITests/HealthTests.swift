@testable import LurewakeAPI
import VaporTesting
import Testing

@Suite("Lurewake API Health Tests")
struct HealthTests {

    @Test("Health endpoint responds successfully")
    func healthEndpoint() async throws {
        try await withApp(configure: configure) { app in
            try await app.testing().test(
                .GET,
                "health"
            ) { response async throws in
                #expect(response.status == .ok)

                let health = try response.content.decode(
                    HealthResponse.self
                )

                #expect(health.status == "ok")
                #expect(health.service == "lurewake-api")
                #expect(health.version == "0.0.0-prep")
            }
        }
    }
}
