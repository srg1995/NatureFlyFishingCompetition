import SwiftUI

struct TimerPageView: View {
    @EnvironmentObject var viewModel: WorkoutViewModel

    private var isRunning: Bool { viewModel.workoutState == .running }
    private var isFree:    Bool { viewModel.workoutMode  == .free }

    var body: some View {
        VStack(spacing: 4) {

            // Estado + modo
            stateIndicator

            Spacer(minLength: 2)

            // Tiempo principal
            Text(viewModel.formattedDisplay)
                .font(.system(size: 40, weight: .bold, design: .monospaced))
                .foregroundStyle(timerColor)
                .minimumScaleFactor(0.6)
                .lineLimit(1)

            // Label contextual
            Text(isFree ? "transcurrido" : "restante")
                .font(.system(size: 10))
                .foregroundStyle(.secondary)

            Spacer(minLength: 6)

            // Botón principal — Pause / Resume (ocupa todo el ancho)
            Button(action: isRunning ? viewModel.pauseWorkout : viewModel.startWorkout) {
                Label(
                    isRunning ? "Pausa" : "Reanudar",
                    systemImage: isRunning ? "pause.fill" : "play.fill"
                )
                .font(.system(size: 15, weight: .semibold))
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(isRunning ? .yellow : .teal)

            // Botones secundarios
            HStack(spacing: 8) {
                // Finalizar
                Button(action: viewModel.finishManually) {
                    Label("Fin", systemImage: "flag.checkered")
                        .font(.system(size: 13, weight: .medium))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.red)

                // Reset
                Button(action: viewModel.resetWorkout) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 13, weight: .medium))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.gray)
            }
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 4)
    }

    // MARK: - Helpers

    private var timerColor: Color {
        guard viewModel.workoutMode == .timed else { return .teal }
        let total = Double(viewModel.selectedHours * 3600 + viewModel.selectedMinutes * 60)
        let ratio = viewModel.remainingTime / max(1, total)
        switch ratio {
        case 0.3...:    return .white
        case 0.1..<0.3: return .yellow
        default:         return .red
        }
    }

    private var stateIndicator: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(isRunning ? Color.green : Color.yellow)
                .frame(width: 7, height: 7)

            Text(isRunning ? "En curso" : "Pausado")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(isRunning ? .green : .yellow)

            Text("·")
                .foregroundStyle(.secondary)
                .font(.system(size: 11))

            Text(isFree ? "Libre" : "Tiempo")
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
        }
    }
}

#Preview("En curso") {
    let vm = WorkoutViewModel()
    vm.workoutMode = .timed
    return TimerPageView()
        .environmentObject(vm)
}

#Preview("Modo libre") {
    let vm = WorkoutViewModel()
    vm.workoutMode = .free
    return TimerPageView()
        .environmentObject(vm)
}
