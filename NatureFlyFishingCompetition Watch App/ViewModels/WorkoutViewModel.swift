import Foundation
import Combine
import WatchKit

enum WorkoutState {
    case idle, running, paused, finished
}

@MainActor
final class WorkoutViewModel: ObservableObject {

    // MARK: - Published State

    @Published var workoutState: WorkoutState = .idle

    // Timer setup (editables antes del inicio)
    @Published var selectedHours: Int   = 1
    @Published var selectedMinutes: Int = 0

    // Tiempo restante en segundos
    @Published var remainingTime: TimeInterval = 3600

    // Contadores
    @Published var pecesT: Int = 0
    @Published var pecesM: Int = 0

    // Post-workout
    @Published var lastSession: WorkoutSession?
    @Published var isSyncing: Bool = false
    @Published var healthKitSaved: Bool = false
    @Published var stravaSaved: Bool = false
    @Published var syncError: String?

    // MARK: - Private

    private let healthKit = HealthKitService()
    private let strava    = StravaService()

    private var startDate: Date?
    private var pauseDate: Date?
    private var accumulatedPause: TimeInterval = 0

    private var timer: Timer?

    private var totalDuration: TimeInterval {
        TimeInterval(selectedHours * 3600 + selectedMinutes * 60)
    }

    // MARK: - Computed

    var formattedRemaining: String {
        let total  = Int(max(0, remainingTime))
        let h = total / 3600
        let m = total / 60 % 60
        let s = total % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }

    var stravaAuthenticated: Bool { strava.isAuthenticated }

    // MARK: - Timer Controls

    func startWorkout() {
        guard workoutState == .idle || workoutState == .paused else { return }

        if workoutState == .idle {
            remainingTime   = totalDuration
            startDate       = Date()
            accumulatedPause = 0
            pecesT = 0
            pecesM = 0
            syncError = nil
            healthKitSaved = false
            stravaSaved    = false

            // Iniciar sesión HealthKit
            healthKit.requestPermissions { [weak self] success, _ in
                guard let self, success, let start = self.startDate else { return }
                self.healthKit.startSession(startDate: start)
            }
        }

        if workoutState == .paused, let pd = pauseDate {
            accumulatedPause += Date().timeIntervalSince(pd)
            pauseDate = nil
        }

        workoutState = .running
        WKInterfaceDevice.current().play(.start)
        scheduleTimer()
    }

    func pauseWorkout() {
        guard workoutState == .running else { return }
        timer?.invalidate()
        timer = nil
        pauseDate = Date()
        workoutState = .paused
        WKInterfaceDevice.current().play(.stop)
    }

    func resetWorkout() {
        timer?.invalidate()
        timer = nil
        workoutState  = .idle
        remainingTime = totalDuration
        startDate     = nil
        pauseDate     = nil
        accumulatedPause = 0
        pecesT = 0
        pecesM = 0
        syncError = nil
    }

    func finishManually() {
        completeWorkout()
    }

    // MARK: - Counters

    func incrementPecesT() { pecesT += 1; haptic() }
    func decrementPecesT() { if pecesT > 0 { pecesT -= 1; haptic() } }
    func incrementPecesM() { pecesM += 1; haptic() }
    func decrementPecesM() { if pecesM > 0 { pecesM -= 1; haptic() } }

    // MARK: - Private

    private func scheduleTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in self?.tick() }
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    private func tick() {
        guard let start = startDate else { return }

        let elapsed = Date().timeIntervalSince(start) - accumulatedPause
        remainingTime = max(0, totalDuration - elapsed)

        if remainingTime <= 0 {
            timer?.invalidate()
            timer = nil
            completeWorkout()
        }
    }

    private func completeWorkout() {
        let endDate  = Date()
        let start    = startDate ?? endDate.addingTimeInterval(-totalDuration)
        let elapsed  = endDate.timeIntervalSince(start) - accumulatedPause

        let session = WorkoutSession(
            startDate: start,
            endDate:   endDate,
            duration:  min(elapsed, totalDuration),
            pecesT:    pecesT,
            pecesM:    pecesM
        )
        lastSession  = session
        workoutState = .finished
        WKInterfaceDevice.current().play(.success)

        // Guardar en historial local
        WorkoutHistoryStore.shared.add(session)

        syncWorkout(session: session)
    }

    private func syncWorkout(session: WorkoutSession) {
        isSyncing = true

        // HealthKit
        healthKit.endSession(endDate: session.endDate) { [weak self] success, _ in
            Task { @MainActor [weak self] in
                self?.healthKitSaved = success
            }
        }

        // Strava
        Task {
            do {
                try await strava.uploadActivity(session: session)
                stravaSaved = true
            } catch {
                syncError = error.localizedDescription
            }
            isSyncing = false
        }
    }

    private func haptic() {
        WKInterfaceDevice.current().play(.click)
    }
}
