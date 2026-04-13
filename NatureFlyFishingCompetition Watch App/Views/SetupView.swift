import SwiftUI

struct SetupView: View {
    @EnvironmentObject var viewModel: WorkoutViewModel
    @ObservedObject private var store = WorkoutHistoryStore.shared

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {

                // Header
                VStack(spacing: 2) {
                    Text("🎣")
                        .font(.title2)
                    Text("Nature Fly")
                        .font(.headline)
                        .foregroundStyle(.teal)
                    Text("Fishing Competition")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 4)

                Divider()

                // Time picker
                VStack(spacing: 4) {
                    Text("Duración")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 0) {
                        Picker("Horas", selection: $viewModel.selectedHours) {
                            ForEach(0...5, id: \.self) { h in
                                Text("\(h)h").tag(h)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 60)

                        Picker("Min", selection: $viewModel.selectedMinutes) {
                            ForEach([0, 5, 10, 15, 20, 30, 45], id: \.self) { m in
                                Text("\(m)m").tag(m)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 60)
                    }
                    .frame(height: 80)
                }

                // Start button
                Button(action: viewModel.startWorkout) {
                    Label("Iniciar", systemImage: "play.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.teal)
                .disabled(viewModel.selectedHours == 0 && viewModel.selectedMinutes == 0)

                // Historial
                NavigationLink(destination: HistoryView()) {
                    HStack {
                        Image(systemName: "clock.arrow.circlepath")
                            .foregroundStyle(.orange)
                        Text("Historial")
                            .font(.footnote)
                        Spacer()
                        if store.totalSessions > 0 {
                            Text("\(store.totalSessions)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .buttonStyle(.bordered)
                .tint(.orange)

                // Strava status
                HStack(spacing: 4) {
                    Circle()
                        .fill(viewModel.stravaAuthenticated ? Color.orange : Color.gray)
                        .frame(width: 6, height: 6)
                    Text(viewModel.stravaAuthenticated ? "Strava conectado" : "Strava no conectado")
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 8)
        }
        .navigationTitle("Inicio")
        .navigationBarTitleDisplayMode(.inline)
    }
}
