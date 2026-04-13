import SwiftUI

struct WorkoutView: View {
    @EnvironmentObject var viewModel: WorkoutViewModel

    var body: some View {
        TabView {
            TimerPageView()
                .tag(0)

            CountersPageView()
                .tag(1)
        }
        .tabViewStyle(.page)
    }
}
