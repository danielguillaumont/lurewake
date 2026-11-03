import Foundation
import SwiftUI

// MARK: - Draft Types

private enum DraftKind: String, CaseIterable, Identifiable {
    case document
    case link

    var id: String { rawValue }

    var title: String {
        rawValue.capitalized
    }

    var symbol: String {
        self == .document ? "doc.text" : "link"
    }
}

private struct DraftPayload: Encodable {
    let name: String
    let kind: String
    let notes: String?
}

// MARK: - Inventory Creation Entry Point

struct LuresWorkspaceView: View {

    @State private var showingCreation = false
    @State private var inventoryVersion = UUID()

    var body: some View {
        LuresInventoryView()
            .id(inventoryVersion)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                Button {
                    showingCreation = true
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "plus.circle.fill")

                        Text("CREATE DRAFT")
                            .tracking(1)

                        Spacer()

                        Image(systemName: "arrow.up.right")
                    }
                    .font(.system(
                        size: 13,
                        weight: .semibold,
                        design: .monospaced
                    ))
                    .foregroundStyle(LurewakeTheme.ink)
                    .padding(18)
                    .background(
                        LurewakeTheme.gold,
                        in: RoundedRectangle(cornerRadius: 16)
                    )
                }
                .buttonStyle(.plain)
                .padding(.horizontal, LurewakeTheme.screenPadding)
                .padding(.vertical, 12)
                .background(LurewakeTheme.ink)
            }
            .sheet(isPresented: $showingCreation) {
                CreateLureDraftView {
                    inventoryVersion = UUID()
                }
                .presentationDragIndicator(.visible)
            }
    }
}

// MARK: - Creation Sheet

struct CreateLureDraftView: View {

    let onCreated: () -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var kind: DraftKind = .document
    @State private var notes = ""
    @State private var operatorToken = ""
    @State private var isSaving = false
    @State private var errorMessage: String?

    private var cleanedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var cleanedNotes: String {
        notes.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canCreate: Bool {
        (3...80).contains(cleanedName.count)
        && !cleanedName.unicodeScalars.contains {
            CharacterSet.controlCharacters.contains($0)
        }
        && cleanedNotes.count <= 500
        && operatorToken.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).utf8.count >= 32
        && !isSaving
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LurewakeTheme.ink
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {

                        LurewakeEyebrow(
                            title: "Controlled lure / draft"
                        )

                        Text("plant a signal.")
                            .font(LurewakeTheme.pageTitleFont)
                            .tracking(-2)
                            .foregroundStyle(
                                LurewakeTheme.parchment
                            )

                        Text(
                            "Define a controlled digital lure. " +
                            "Creation saves metadata only; " +
                            "nothing is deployed or activated."
                        )
                        .font(LurewakeTheme.bodyFont)
                        .foregroundStyle(LurewakeTheme.mutedText)

                        LurewakePanel {
                            VStack(alignment: .leading, spacing: 12) {
                                fieldLabel("Lure name")

                                TextField(
                                    "e.g. Finance Archive",
                                    text: $name
                                )
                                .textInputAutocapitalization(.words)
                                .autocorrectionDisabled()
                                .padding(14)
                                .background(
                                    LurewakeTheme.ink,
                                    in: RoundedRectangle(
                                        cornerRadius: 12
                                    )
                                )
                                .foregroundStyle(
                                    LurewakeTheme.parchment
                                )

                                Text("\(cleanedName.count) / 80 characters")
                                    .font(.caption.monospaced())
                                    .foregroundStyle(
                                        LurewakeTheme.mutedText
                                    )
                            }
                        }

                        LurewakePanel {
                            VStack(alignment: .leading, spacing: 14) {
                                fieldLabel("Lure category")

                                HStack(spacing: 10) {
                                    ForEach(DraftKind.allCases) { option in
                                        Button {
                                            kind = option
                                        } label: {
                                            VStack(spacing: 9) {
                                                Image(
                                                    systemName: option.symbol
                                                )
                                                .font(.title2)

                                                Text(option.title)
                                                    .font(.subheadline)
                                            }
                                            .foregroundStyle(
                                                kind == option
                                                ? LurewakeTheme.gold
                                                : LurewakeTheme.parchment
                                            )
                                            .frame(
                                                maxWidth: .infinity,
                                                minHeight: 75
                                            )
                                            .background(
                                                kind == option
                                                ? LurewakeTheme.gold.opacity(0.15)
                                                : LurewakeTheme.ink,
                                                in: RoundedRectangle(
                                                    cornerRadius: 12
                                                )
                                            )
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }

                        LurewakePanel {
                            VStack(alignment: .leading, spacing: 12) {
                                fieldLabel("Operator notes / optional")

                                TextEditor(text: $notes)
                                    .scrollContentBackground(.hidden)
                                    .frame(height: 100)
                                    .padding(8)
                                    .background(
                                        LurewakeTheme.ink,
                                        in: RoundedRectangle(
                                            cornerRadius: 12
                                        )
                                    )
                                    .foregroundStyle(
                                        LurewakeTheme.parchment
                                    )

                                Text("\(cleanedNotes.count) / 500 characters")
                                    .font(.caption.monospaced())
                                    .foregroundStyle(
                                        LurewakeTheme.mutedText
                                    )
                            }
                        }

                        LurewakePanel {
                            VStack(alignment: .leading, spacing: 12) {
                                fieldLabel("Local operator credential")

                                SecureField(
                                    "Paste development token",
                                    text: $operatorToken
                                )
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .padding(14)
                                .background(
                                    LurewakeTheme.ink,
                                    in: RoundedRectangle(
                                        cornerRadius: 12
                                    )
                                )

                                Text(
                                    "For localhost development only. " +
                                    "This token is not saved by the app."
                                )
                                .font(.caption)
                                .foregroundStyle(
                                    LurewakeTheme.mutedText
                                )
                            }
                        }

                        if let errorMessage {
                            Text(errorMessage)
                                .font(.subheadline)
                                .foregroundStyle(LurewakeTheme.gold)
                        }

                        Button {
                            Task {
                                await createDraft()
                            }
                        } label: {
                            HStack(spacing: 12) {
                                if isSaving {
                                    ProgressView()
                                        .tint(LurewakeTheme.ink)
                                } else {
                                    Image(systemName: "plus")
                                }

                                Text(
                                    isSaving
                                    ? "SAVING DRAFT"
                                    : "SAVE DRAFT"
                                )
                                .tracking(1)

                                Spacer()

                                Image(systemName: "arrow.up.right")
                            }
                            .font(.system(
                                size: 13,
                                weight: .semibold,
                                design: .monospaced
                            ))
                            .foregroundStyle(LurewakeTheme.ink)
                            .padding(18)
                            .background(
                                canCreate
                                ? LurewakeTheme.gold
                                : LurewakeTheme.mist,
                                in: RoundedRectangle(cornerRadius: 16)
                            )
                        }
                        .buttonStyle(.plain)
                        .disabled(!canCreate)

                        Text("DRAFT ONLY · NO DEPLOYMENT")
                            .font(.caption.monospaced())
                            .foregroundStyle(LurewakeTheme.mutedText)
                            .frame(maxWidth: .infinity)
                    }
                    .padding(LurewakeTheme.screenPadding)
                }
            }
            .navigationTitle("New draft")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .tint(LurewakeTheme.gold)
        .preferredColorScheme(.dark)
        .onDisappear {
            operatorToken = ""
        }
    }

    private func fieldLabel(_ value: String) -> some View {
        Text(value.uppercased())
            .font(LurewakeTheme.eyebrowFont)
            .tracking(1)
            .foregroundStyle(LurewakeTheme.gold)
    }

    @MainActor
    private func createDraft() async {
        guard canCreate else { return }

        isSaving = true
        errorMessage = nil

        defer { isSaving = false }

        guard let url = URL(
            string: "http://127.0.0.1:8080/api/v1/lures"
        ) else {
            errorMessage = "Invalid local API address."
            return
        }

        let payload = DraftPayload(
            name: cleanedName,
            kind: kind.rawValue,
            notes: cleanedNotes.isEmpty ? nil : cleanedNotes
        )

        do {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.timeoutInterval = 10

            request.setValue(
                "application/json",
                forHTTPHeaderField: "Content-Type"
            )

            request.setValue(
                "Bearer " + operatorToken.trimmingCharacters(
                    in: .whitespacesAndNewlines
                ),
                forHTTPHeaderField: "Authorization"
            )

            request.httpBody = try JSONEncoder().encode(payload)

            let (_, response) = try await URLSession.shared.data(
                for: request
            )

            guard let http = response as? HTTPURLResponse else {
                errorMessage = "No HTTP response received."
                return
            }

            switch http.statusCode {
            case 201:
                operatorToken = ""
                onCreated()
                dismiss()

            case 400:
                errorMessage = "The server rejected the draft metadata."

            case 401:
                errorMessage = "Operator credential was rejected."

            case 503:
                errorMessage = "The database is currently unavailable."

            default:
                errorMessage =
                    "Unable to create draft (HTTP \(http.statusCode))."
            }

        } catch {
            errorMessage =
                "Cannot reach the local API. Check that Vapor is running."
        }
    }
}
