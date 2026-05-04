import SwiftUI

struct SessionsView: View {
    let apiClient: APIClient
    @EnvironmentObject private var session: AppSession
    @StateObject private var viewModel: SessionsViewModel
    @State private var pendingDeleteItem: TranscriptSession?

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
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                pendingDeleteItem = item
                            } label: {
                                Label("Hapus", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Transkrip Privat")
            .toolbar {
                Button("Refresh") {
                    guard let token = session.token else { return }
                    Task { await viewModel.load(token: token, session: session) }
                }
            }
            .task {
                guard let token = session.token else { return }
                await viewModel.load(token: token, session: session)
            }
            .confirmationDialog(
                "Hapus transkrip ini?",
                item: $pendingDeleteItem,
                titleVisibility: .visible
            ) { selected in
                Button("Hapus", role: .destructive) {
                    guard let token = session.token else { return }
                    Task { await viewModel.deleteSession(id: selected.id, token: token, session: session) }
                }
                Button("Batal", role: .cancel) {}
            } message: { selected in
                Text("Tindakan ini tidak bisa dibatalkan untuk \"\(selected.title)\".")
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
                    }

                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(.white)
                            .padding(10)
                            .background(Color.red)
                            .clipShape(Capsule())
                    }
                }
                .padding(.bottom, 8)
            }
        }
    }
}

