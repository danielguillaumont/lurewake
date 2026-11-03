import Foundation

// MARK: - Supported Draft Categories

enum LureKind: String, Codable, CaseIterable, Sendable {
    case document
    case link
}

// MARK: - Lifecycle

enum LureLifecycleStatus: String, Codable, Sendable {
    case draft
    case archived
}

enum LureLifecycleError: Error, Equatable, Sendable {
    case forbiddenTransition
}

enum LureLifecyclePolicy {
    static func validateTransition(
        from current: LureLifecycleStatus,
        to next: LureLifecycleStatus
    ) throws {
        guard current == .draft, next == .archived else {
            throw LureLifecycleError.forbiddenTransition
        }
    }
}

// MARK: - Validated Draft

struct ValidatedLureDraft: Equatable, Sendable {
    let name: String
    let kind: LureKind
    let notes: String?
    let status: LureLifecycleStatus
}

enum LureDraftValidationError: Error, Equatable, Sendable {
    case invalidName
    case unsupportedKind
    case notesTooLong
}

// MARK: - Draft Policy

enum LureDraftPolicy {

    static func validate(
        name: String,
        kind: String,
        notes: String? = nil
    ) throws -> ValidatedLureDraft {

        let cleanedName = name.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard (3...80).contains(cleanedName.count),
              !cleanedName.unicodeScalars.contains(
                  where: {
                      CharacterSet.controlCharacters.contains($0)
                  }
              ) else {
            throw LureDraftValidationError.invalidName
        }

        let cleanedKind = kind
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        guard let parsedKind = LureKind(
            rawValue: cleanedKind
        ) else {
            throw LureDraftValidationError.unsupportedKind
        }

        let cleanedNotes = notes?.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard (cleanedNotes?.count ?? 0) <= 500 else {
            throw LureDraftValidationError.notesTooLong
        }

        return ValidatedLureDraft(
            name: cleanedName,
            kind: parsedKind,
            notes: cleanedNotes?.isEmpty == true
                ? nil
                : cleanedNotes,
            status: .draft
        )
    }
}
