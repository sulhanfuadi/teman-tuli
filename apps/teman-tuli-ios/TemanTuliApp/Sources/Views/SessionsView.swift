import SwiftUI

struct SessionsView: View {
    let apiClient: APIClient
    @EnvironmentObject private var session: AppSession
    @StateObject private var viewModel: SessionsViewModel

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
                    ContentUnavailableView("Belum ada transkrip", systemImage: "captions.bubble", description: Text("Simpan transkrip dari Live Caption untuk melihat arsip privat di sini."))
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
                    }
                }
            }
            .navigationTitle("Transkrip Privat")
            .toolbar {
                Button("Refresh") {
                    guard let token = session.token else { return }
                    Task { await viewModel.load(token: token) }
                }
            }
            .task {
                guard let token = session.token else { return }
                await viewModel.load(token: token)
            }
        }
    }
}
