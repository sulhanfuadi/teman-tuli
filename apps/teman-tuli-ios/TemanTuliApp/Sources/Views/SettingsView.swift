import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var session: AppSession
    @AppStorage(APIEndpointConfig.storageKey) private var storedBaseURL: String = APIEndpointConfig.defaultBaseURLString
    @State private var draftBaseURL: String = ""
    @State private var endpointNotice: String?
    @State private var endpointError: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Aksesibilitas") {
                    Label("Caption besar dan kontras tinggi untuk ruang kelas", systemImage: "textformat.size")
                    Label("Bahasa utama: Indonesia (id-ID)", systemImage: "globe")
                    Label("Transkrip privat secara default", systemImage: "lock")
                }

                Section("Server API") {
                    TextField("Base URL API", text: $draftBaseURL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .keyboardType(.URL)

                    Button("Simpan Endpoint") {
                        let saved = APIEndpointConfig.saveBaseURL(draftBaseURL)
                        if saved {
                            storedBaseURL = APIEndpointConfig.currentBaseURLString()
                            draftBaseURL = storedBaseURL
                            endpointError = nil
                            endpointNotice = "Endpoint API berhasil diperbarui."
                        } else {
                            endpointNotice = nil
                            endpointError = "URL tidak valid. Gunakan format lengkap, misalnya http://localhost:3000/api/v1"
                        }
                    }

                    Text("Aktif: \(APIEndpointConfig.currentBaseURLString())")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if let endpointNotice {
                        Text(endpointNotice)
                            .font(.caption)
                            .foregroundStyle(.green)
                    }

                    if let endpointError {
                        Text(endpointError)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }

                Section("Akun") {
                    Button("Keluar") { session.signOut() }
                        .foregroundStyle(.red)
                }
            }
            .navigationTitle("Pengaturan")
            .onAppear {
                draftBaseURL = APIEndpointConfig.currentBaseURLString()
            }
        }
    }
}
