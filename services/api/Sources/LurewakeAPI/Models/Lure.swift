import Fluent
import Foundation

final class Lure: Model, @unchecked Sendable {

    static let schema = "lures"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "kind")
    var kind: String

    @Field(key: "status")
    var status: String

    @OptionalField(key: "notes")
    var notes: String?

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() {}

    init(
        id: UUID? = nil,
        name: String,
        kind: String,
        status: String = "draft",
        notes: String? = nil
    ) {
        self.id = id
        self.name = name
        self.kind = kind
        self.status = status
        self.notes = notes
        self.createdAt = nil
        self.updatedAt = nil
    }
}
