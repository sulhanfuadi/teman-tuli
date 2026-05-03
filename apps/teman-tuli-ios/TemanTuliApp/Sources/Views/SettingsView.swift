import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var session: AppSession

    var body: some View {
        NavigationStack {
            Form {
                Section("Aksesibilitas") {
                    Label("Caption besar dan kontras tinggi untuk ruang kelas", systemImage: "textformat.size")
                    Label("Bahasa utama: Indonesia (id-ID)", systemImage: "globe")
                    Label("Transkrip privat secara default", systemImage: "lock")
                }

                Section("Akun") {
                    Button("Keluar") { session.signOut() }
                        .foregroundStyle(.red)
                }
            }
            .navigationTitle("Pengaturan")
        }
    }
}
