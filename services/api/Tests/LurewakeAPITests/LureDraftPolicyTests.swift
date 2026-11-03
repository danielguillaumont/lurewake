@testable import LurewakeAPI

import Foundation
import Testing

@Suite("Lure Draft Policy")
struct LureDraftPolicyTests {

    @Test("Valid document draft is normalized")
    func validDraft() throws {
        let draft = try LureDraftPolicy.validate(
            name: "  Payroll Canary  ",
            kind: "  DOCUMENT ",
            notes: "  Local test only  "
        )

        #expect(draft.name == "Payroll Canary")
        #expect(draft.kind == .document)
        #expect(draft.notes == "Local test only")
        #expect(draft.status == .draft)
    }

    @Test("Short names are rejected")
    func shortName() {
        #expect(throws: LureDraftValidationError.self) {
            try LureDraftPolicy.validate(
                name: "ab",
                kind: "document"
            )
        }
    }

    @Test("Names longer than 80 characters are rejected")
    func longName() {
        #expect(throws: LureDraftValidationError.self) {
            try LureDraftPolicy.validate(
                name: String(repeating: "x", count: 81),
                kind: "document"
            )
        }
    }

    @Test("Control characters in names are rejected")
    func controlCharacters() {
        #expect(throws: LureDraftValidationError.self) {
            try LureDraftPolicy.validate(
                name: "Payroll\nCanary",
                kind: "document"
            )
        }
    }

    @Test("Unsupported lure kinds are rejected")
    func unsupportedKind() {
        #expect(throws: LureDraftValidationError.self) {
            try LureDraftPolicy.validate(
                name: "Sample Lure",
                kind: "unknown"
            )
        }
    }

    @Test("Notes over 500 characters are rejected")
    func longNotes() {
        #expect(throws: LureDraftValidationError.self) {
            try LureDraftPolicy.validate(
                name: "Sample Lure",
                kind: "link",
                notes: String(repeating: "n", count: 501)
            )
        }
    }

    @Test("Empty notes become nil")
    func blankNotes() throws {
        let draft = try LureDraftPolicy.validate(
            name: "Sample Lure",
            kind: "link",
            notes: "   "
        )

        #expect(draft.notes == nil)
    }

    @Test("Draft can transition to archived")
    func archiveDraft() throws {
        try LureLifecyclePolicy.validateTransition(
            from: .draft,
            to: .archived
        )
    }

    @Test("Archived lure cannot return to draft")
    func cannotReopenArchived() {
        #expect(throws: LureLifecycleError.self) {
            try LureLifecyclePolicy.validateTransition(
                from: .archived,
                to: .draft
            )
        }
    }
}
