import Fluent

struct CreateLures: AsyncMigration {

    func prepare(on database: any Database) async throws {

        try await database.schema("lures")
            .id()
            .field("name", .string, .required)
            .field("kind", .string, .required)
            .field("status", .string, .required)
            .field("notes", .string)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: any Database) async throws {

        try await database.schema("lures").delete()
    }
}
