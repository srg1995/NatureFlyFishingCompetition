import SwiftUI

struct TimerPageView: View {
    @EnvironmentObject var viewModel: WorkoutViewModel

    private var isRunning: Bool { viewModel.workoutState == .running }
    private var isFree:    Bool { viewModel.workoutMode  == .free }

    var body: some View {
        VStack(spacing: 8) {

            // Estado + modo
            stateIndicator

            // Tiempo principal
            Text(viewModel.formattedDisplay)
                .font(.system(size: 36, weight: .semibold, design: .monospaced))
                .foregroundStyle(timerColor)
                .minimumScaleFactor(0.6)
                .lineLimit(1)

            // Label contextual
            Text(isFree ? "transcurrido" : "restante")
                .font(.system(size: 9))
                .foregroundStyle(.secondary)

            // Controles
            HStack(spacing: 10) {
                // Pause / Resume
                Button(action: isRunning ? viewModel.pauseWorkout : viewModel.startWorkout) {
                    Image(systemName: isRunning ? "pause.fill" : "play.fill")
                        .font(.title3)
                }
                .buttonStyle(.bordered)
                .tint(isRunning ? .yellow : .teal)

                // Finish manual
                Button(action: viewModel.finishManually) {
                    Image(systemName: "flag.checkered")
                        .font(.title3)
                }
                .buttonStyle(.bordered)
                .tint(.red)

                // Reset
                Button(action: viewModel.resetWorkout) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.title3)
                }
                .buttonStyle(.bordered)
                .tint(.gray)
            }

            // Hint swipe
            Text("← Peces")
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 6)
    }

    // MARK: - Helpers

    private var timerColor: Color {
        guard viewModel.workoutMode == .timed else { return .teal }
        let total = Double(viewModel.selectedHours * 3600 + viewModel.selectedMinutes * 60)
        let ratio = viewModel.remainingTime / max(1, total)
        switch ratio {
        case 0.3...:      return .white
        case 0.1..<0.3:   return .yellow
        default:           return .red
        }
    }

    private var stateIndicator: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(isRunning ? Color.green : Color.yellow)
                .frame(width: 6, height: 6)

            Text(isRunning ? "En curso" : "Pausado")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.secondary)

            Text("·")
                .foregroundStyle(.secondary)
                .font(.system(size: 10))

            Text(isFree ? "🆓 Libre" : "⏱ Tiempo")
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
        }
    }
}

#Preview("En curso") {
    let vm = WorkoutViewModel()
    vm.workoutMode   = .timed
    return TimerPageView()
        .environmentObject(vm)
}

#Preview("Modo libre") {
    let vm = WorkoutViewModel()
    vm.workoutMode = .free
    return TimerPageView()
        .environmentObject(vm)
}
