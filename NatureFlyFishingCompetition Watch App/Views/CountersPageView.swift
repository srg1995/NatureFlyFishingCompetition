import SwiftUI

struct CountersPageView: View {
    @EnvironmentObject var viewModel: WorkoutViewModel

    var body: some View {
        VStack(spacing: 14) {

            Text("Peces")
                .font(.caption2)
                .foregroundStyle(.secondary)

            // Peces T
            CounterRow(
                label: "🐟 T",
                value: viewModel.pecesT,
                onIncrement: viewModel.incrementPecesT,
                onDecrement: viewModel.decrementPecesT,
                color: .red
            )

            Divider()

            // Peces M
            CounterRow(
                label: "🐟 M",
                value: viewModel.pecesM,
                onIncrement: viewModel.incrementPecesM,
                onDecrement: viewModel.decrementPecesM,
                color: .blue
            )

            // Total
            HStack {
                Text("Total:")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text("\(viewModel.pecesT + viewModel.pecesM)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
            }
        }
        .padding(.horizontal, 6)
    }
}

// MARK: - CounterRow

private struct CounterRow: View {
    let label: String
    let value: Int
    let onIncrement: () -> Void
    let onDecrement: () -> Void
    let color: Color

    var body: some View {
        HStack(spacing: 10) {
            // Label
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .frame(width: 42, alignment: .leading)

            // Minus
            Button(action: onDecrement) {
                Image(systemName: "minus")
                    .font(.system(size: 14, weight: .bold))
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.bordered)
            .tint(value > 0 ? color : .gray)
            .disabled(value == 0)

            // Count
            Text("\(value)")
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundStyle(color)
                .frame(minWidth: 28)

            // Plus
            Button(action: onIncrement) {
                Image(systemName: "plus")
                    .font(.system(size: 14, weight: .bold))
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.bordered)
            .tint(color)
        }
    }
}
