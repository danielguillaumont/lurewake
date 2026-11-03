import Foundation
import SwiftUI

// MARK: - Protected Draft Archival

struct ArchiveLureDraftView: View {

    let lureID: UUID
    let lureName: String
    let onArchived: () -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var operatorToken = ""
    @State private var isArchiving = false
    @State private var errorMessage: String?

    private var canArchive: Bool {
        operatorToken.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).utf8.count >= 32 && !isArchiving
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LurewakeTheme.ink
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {

                        LurewakeEyebrow(
                            title: "Controlled lure / lifecycle"
                        )

                        Text("close the trail.")
                            .font(LurewakeTheme.pageTitleFont)
                            .tracking(-2)
                            .foregroundStyle(LurewakeTheme.parchment)

                        Text(
                            "Archive a draft without deleting " +
                            "its record. Archived drafts remain " +
                            "visible in the Lurewake inventory."
                        )
                        .font(LurewakeTheme.bodyFont)
                        .foregroundStyle(LurewakeTheme.mutedText)

                        LurewakePanel {
                            VStack(alignment: .leading, spacing: 14) {

                                Text("SELECTED DRAFT")
                                    .font(LurewakeTheme.eyebrowFont)
                                    .tracking(1)
                                    .foregroundStyle(LurewakeTheme.gold)

                                Text(lureName)
                                    .font(.title3.weight(.semibold))
                                    .foregroundStyle(
                                        LurewakeTheme.parchment
                                    )

                                Text(lureID.uuidString)
                                    .font(.system(
                                        size: 10,
                                        design: .monospaced
                                    ))
                                    .foregroundStyle(
                                        LurewakeTheme.mutedText
                                    )
                                    .textSelection(.enabled)

                                HStack(spacing: 8) {
                                    Image(systemName: "circle.dotted")

                                    Text("DRAFT → ARCHIVED")
                                }
                                .font(.system(
                                    size: 12,
                                    weight: .semibold,
                                    design: .monospaced
                                ))
                                .foregroundStyle(LurewakeTheme.gold)
                                .padding(.top, 5)
                            }
                        }

                        LurewakePanel {
                            VStack(alignment: .leading, spacing: 12) {

                                Label(
                                    "Lifecycle transition",
                                    systemImage: "archivebox"
                                )
                                .font(.headline)
                                .foregroundStyle(
                                    LurewakeTheme.parchment
                                )

                                Text(
                                    "This action changes only the " +
                                    "stored status. It does not " +
                                    "deploy or remove any live lure."
                                )
                                .font(.subheadline)
                                .foregroundStyle(
                                    LurewakeTheme.mutedText
                                )

                                Text(
                                    "Under the current lifecycle " +
                                    "policy, archived drafts cannot " +
                                    "be reopened."
                                )
                                .font(.caption)
                                .foregroundStyle(
                                    LurewakeTheme.gold
                                )
                            }
                        }

                        LurewakePanel {
                            VStack(alignment: .leading, spacing: 12) {

                                Text("LOCAL OPERATOR CREDENTIAL")
                                    .font(LurewakeTheme.eyebrowFont)
                                    .tracking(1)
                                    .foregroundStyle(LurewakeTheme.gold)

                                SecureField(
                                    "Paste development token",
                                    text: $operatorToken
                                )
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .padding(14)
                                .foregroundStyle(
                                    LurewakeTheme.parchment
                                )
                                .background(
                                    LurewakeTheme.ink,
                                    in: RoundedRectangle(
                                        cornerRadius: 12
                                    )
                                )

                                Text(
                                    "Required for this protected " +
                                    "operation. Not saved by the app."
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
                                await archiveDraft()
                            }
                        } label: {
                            HStack(spacing: 12) {
                                if isArchiving {
                                    ProgressView()
                                        .tint(LurewakeTheme.ink)
                                } else {
                                    Image(systemName: "archivebox.fill")
                                }

                                Text(
                                    isArchiving
                                    ? "ARCHIVING DRAFT"
                                    : "CONFIRM ARCHIVE"
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
                                canArchive
                                ? LurewakeTheme.gold
                                : LurewakeTheme.mist,
                                in: RoundedRectangle(cornerRadius: 16)
                            )
                        }
                        .buttonStyle(.plain)
                        .disabled(!canArchive)

                        Text("ARCHIVE METADATA ONLY")
                            .font(.caption.monospaced())
                            .foregroundStyle(LurewakeTheme.mutedText)
                            .frame(maxWidth: .infinity)
                    }
                    .padding(LurewakeTheme.screenPadding)
                }
            }
            .navigationTitle("Archive draft")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isArchiving)
                }
            }
        }
        .tint(LurewakeTheme.gold)
        .preferredColorScheme(.dark)
        .interactiveDismissDisabled(isArchiving)
        .onDisappear {
            operatorToken = ""
        }
    }

    @MainActor
    private func archiveDraft() async {
        guard canArchive else { return }

        isArchiving = true
        errorMessage = nil

        defer { isArchiving = false }

        guard let url = URL(
            string:
                "http://127.0.0.1:8080/api/v1/lures/" +
                lureID.uuidString +
                "/archive"
        ) else {
            errorMessage = "Invalid local API address."
            return
        }

        do {
            var request = URLRequest(url: url)
            request.httpMethod = "PATCH"
            request.timeoutInterval = 10

            request.setValue(
                "Bearer " + operatorToken.trimmingCharacters(
                    in: .whitespacesAndNewlines
                ),
                forHTTPHeaderField: "Authorization"
            )

            let (_, response) = try await URLSession.shared.data(
                for: request
            )

            guard let http = response as? HTTPURLResponse else {
                errorMessage = "No HTTP response received."
                return
            }

            switch http.statusCode {
            case 200:
                operatorToken = ""
                onArchived()
                dismiss()

            case 400:
                errorMessage = "Invalid lure identifier."

            case 401:
                errorMessage = "Operator credential was rejected."

            case 404:
                errorMessage = "This lure no longer exists."

            case 409:
                errorMessage = "This lure is no longer a draft."

            case 503:
                errorMessage = "The database is unavailable."

            default:
                errorMessage =
                    "Unable to archive (HTTP \(http.statusCode))."
            }

        } catch {
            errorMessage =
                "Cannot reach the local API. Check that Vapor is running."
        }
    }
}
