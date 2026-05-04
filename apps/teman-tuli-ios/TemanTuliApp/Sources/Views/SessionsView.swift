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
                    ProgressView("Memuat transkrip...")
                } else if viewModel.sessions.isEmpty {
                    ContentUnavailableView(
                        "Belum ada transkrip",
                        systemImage: "captions.bubble",
                        description: Text("Simpan transkrip dari Live Caption untuk melihat arsip privat di sini.")
                    )
                } else {
                    List(viewModel.sessions) { item in
                        NavigationLink(destination: SessionDetailView(apiClient: apiClient, sessionId: item.id)) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.title).font(.headline)
                                Text(item.className ?? "Tanpa nama kelas")
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
                                Label("Hapus", systemImage: "trash")
                            }
                        }
                    }
                    .accessibilityIdentifier("sessions_list")
                }
            }
            .navigationTitle("Transkrip Privat")
            .toolbar {
                Button("Refresh") {
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
                "Hapus transkrip ini?",
                isPresented: $isDeleteConfirmationPresented,
                titleVisibility: .visible
            ) {
                Button("Hapus", role: .destructive) {
                    guard let selected = pendingDeleteItem else { return }
                    guard let token = session.token else { return }
                    Task { await viewModel.deleteSession(id: selected.id, token: token, session: session) }
                    pendingDeleteItem = nil
                }
                .disabled(viewModel.isDeletingSession)
                Button("Batal", role: .cancel) {
                    pendingDeleteItem = nil
                }
            } message: {
                Text("Tindakan ini tidak bisa dibatalkan untuk \"\(pendingDeleteItem?.title ?? "transkrip ini")\".")
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
                                    Text("Ref: \(ref)")
                                        .font(.caption2)
                                        .foregroundStyle(.white.opacity(0.9))
                                    Spacer()
                                    Button("Copy Ref") {
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
