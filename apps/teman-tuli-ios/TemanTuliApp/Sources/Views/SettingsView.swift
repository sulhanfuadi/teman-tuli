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
                        .accessibilityIdentifier("settings_api_base_url_field")

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
                    .accessibilityIdentifier("settings_save_endpoint_button")

                    Text("Aktif: \(APIEndpointConfig.currentBaseURLString())")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .accessibilityIdentifier("settings_active_endpoint_label")

                    if let endpointNotice {
                        Text(endpointNotice)
                            .font(.caption)
                            .foregroundStyle(.green)
                            .accessibilityIdentifier("settings_endpoint_notice")
                    }

                    if let endpointError {
                        Text(endpointError)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .accessibilityIdentifier("settings_endpoint_error")
                    }
                }

                Section("Akun") {
                    Button("Keluar") { session.signOut() }
                        .foregroundStyle(.red)
                        .accessibilityIdentifier("settings_signout_button")
                }
            }
            .navigationTitle("Pengaturan")
            .onAppear {
                draftBaseURL = APIEndpointConfig.currentBaseURLString()
            }
        }
    }
}
