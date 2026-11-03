import Vapor
import Fluent
import FluentPostgresDriver

func configure(_ app: Application) async throws {

    if let password = Environment.get(
        "LUREWAKE_DB_PASSWORD"
    ), !password.isEmpty {

        app.databases.use(
            DatabaseConfigurationFactory.postgres(
                configuration: .init(
                    hostname: "127.0.0.1",
                    port: 5433,
                    username: "lurewake",
                    password: password,
                    database: "lurewake",
                    tls: .disable
                )
            ),
            as: .psql
        )

        app.logger.info(
            "PostgreSQL driver configured"
        )

        app.migrations.add(CreateLures(), to: .psql)

    } else {

        app.logger.warning(
            "PostgreSQL not configured: password missing"
        )
    }

    try routes(app)
    registerLureInventoryRoutes(app)

    registerLureCreationRoutes(
        app,
        configuredToken: Environment.get(
            "LUREWAKE_OPERATOR_TOKEN"
        )
    )
}
