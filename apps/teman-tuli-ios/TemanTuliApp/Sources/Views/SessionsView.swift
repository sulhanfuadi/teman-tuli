import SwiftUI
import UIKit

struct SessionsView: View {
    let apiClient: APIClient
    @EnvironmentObject private var session: AppSession
    @StateObject private var viewModel: SessionsViewModel
    @State private var pendingDeleteItem: TranscriptSession?
    @State private var isDeleteConfirmationPresented: Bool = false

    init(apiClient: APIClient) {
        self.apiClient = apiClient
        _viewModel = StateObject(wrappedValue: SessionsViewModel(apiClient: apiClient))
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView(L10n.tr("sessions.loading"))
                } else if viewModel.sessions.isEmpty {
                    ContentUnavailableView(
                        L10n.tr("sessions.empty.title"),
                        systemImage: "captions.bubble",
                        description: Text(L10n.tr("sessions.empty.description"))
                    )
                } else {
                    List(viewModel.sessions) { item in
                        NavigationLink(destination: SessionDetailView(apiClient: apiClient, sessionId: item.id)) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.title).font(.headline)
                                Text(item.className ?? L10n.tr("sessions.class_name_fallback"))
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Text(item.fullText)
                                    .font(.caption)
                                    .lineLimit(2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .accessibilityIdentifier("session_row_\(item.id)")
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                pendingDeleteItem = item
                                isDeleteConfirmationPresented = true
                            } label: {
                                Label(L10n.tr("common.delete"), systemImage: "trash")
                            }
                        }
                    }
                    .accessibilityIdentifier("sessions_list")
                }
            }
            .navigationTitle(L10n.tr("sessions.nav_title"))
            .toolbar {
                Button(L10n.tr("common.refresh")) {
                    guard let token = session.token else { return }
                    Task { await viewModel.load(token: token, session: session) }
                }
                .disabled(viewModel.isLoading || viewModel.isDeletingSession)
                .accessibilityIdentifier("sessions_refresh_button")
            }
            .task {
                guard let token = session.token else { return }
                await viewModel.load(token: token, session: session)
            }
            .confirmationDialog(
                L10n.tr("sessions.delete.confirm_title"),
                isPresented: $isDeleteConfirmationPresented,
                titleVisibility: .visible
            ) {
                Button(L10n.tr("common.delete"), role: .destructive) {
                    guard let selected = pendingDeleteItem else { return }
                    guard let token = session.token else { return }
                    Task { await viewModel.deleteSession(id: selected.id, token: token, session: session) }
                    pendingDeleteItem = nil
                }
                .disabled(viewModel.isDeletingSession)
                Button(L10n.tr("common.cancel"), role: .cancel) {
                    pendingDeleteItem = nil
                }
            } message: {
                Text(
                    String(
                        format: L10n.tr("sessions.delete.message"),
                        pendingDeleteItem?.title ?? L10n.tr("sessions.delete.fallback_title")
                    )
                )
            }
            .overlay(alignment: .bottom) {
                VStack(spacing: 8) {
                    if let successMessage = viewModel.successMessage {
                        Text(successMessage)
                            .font(.caption)
                            .foregroundStyle(.white)
                            .padding(10)
                            .background(Color.green)
                            .clipShape(Capsule())
                            .accessibilityIdentifier("sessions_success_message")
                    }

                    if let errorMessage = viewModel.errorMessage {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundStyle(.white)
                            if let ref = viewModel.errorRequestReference {
                                HStack {
                                    Text(String(format: L10n.tr("common.ref"), ref))
                                        .font(.caption2)
                                        .foregroundStyle(.white.opacity(0.9))
                                    Spacer()
                                    Button(L10n.tr("common.copy_ref")) {
                                        UIPasteboard.general.string = ref
                                    }
                                    .font(.caption2)
                                    .foregroundStyle(.white)
                                }
                            }
                        }
                        .padding(10)
                        .background(Color.red)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .accessibilityIdentifier("sessions_error_card")
                    }
                }
                .padding(.bottom, 8)
            }
        }
    }
}
