import Foundation
import HealthKit

class HealthKitService: NSObject, ObservableObject {

    private let healthStore = HKHealthStore()
    private var workoutSession: HKWorkoutSession?
    private var liveBuilder: HKLiveWorkoutBuilder?

    private var endCompletion: ((Bool, Error?) -> Void)?

    // MARK: - Permissions

    func requestPermissions(completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, nil)
            return
        }

        let share: Set<HKSampleType> = [HKObjectType.workoutType()]
        let read: Set<HKObjectType> = [HKObjectType.workoutType()]

        healthStore.requestAuthorization(toShare: share, read: read) { success, error in
            DispatchQueue.main.async { completion(success, error) }
        }
    }

    // MARK: - Session Lifecycle

    func startSession(startDate: Date) {
        let config = HKWorkoutConfiguration()
        config.activityType = .other
        config.locationType = .outdoor

        do {
            let session = try HKWorkoutSession(healthStore: healthStore, configuration: config)
            session.delegate = self

            let builder = session.associatedWorkoutBuilder()
            builder.delegate = self
            builder.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore,
                                                          workoutConfiguration: config)

            workoutSession = session
            liveBuilder = builder

            session.startActivity(with: startDate)
            builder.beginCollection(withStart: startDate) { _, _ in }

        } catch {
            print("[HealthKit] Failed to start session: \(error)")
        }
    }

    func endSession(endDate: Date, completion: @escaping (Bool, Error?) -> Void) {
        endCompletion = completion
        workoutSession?.end()

        liveBuilder?.endCollection(withEnd: endDate) { [weak self] success, error in
            guard success else {
                DispatchQueue.main.async { completion(false, error) }
                return
            }
            self?.liveBuilder?.finishWorkout { workout, error in
                DispatchQueue.main.async { completion(workout != nil, error) }
            }
        }
    }
}

// MARK: - HKWorkoutSessionDelegate

extension HealthKitService: HKWorkoutSessionDelegate {
    func workoutSession(_ workoutSession: HKWorkoutSession,
                        didChangeTo toState: HKWorkoutSessionState,
                        from fromState: HKWorkoutSessionState,
                        date: Date) {
        print("[HealthKit] Session state: \(fromState.rawValue) → \(toState.rawValue)")
    }

    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print("[HealthKit] Session error: \(error)")
        DispatchQueue.main.async {
            self.endCompletion?(false, error)
        }
    }
}

// MARK: - HKLiveWorkoutBuilderDelegate

extension HealthKitService: HKLiveWorkoutBuilderDelegate {
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {}

    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder,
                        didCollectDataOf collectedTypes: Set<HKSampleType>) {}
}
