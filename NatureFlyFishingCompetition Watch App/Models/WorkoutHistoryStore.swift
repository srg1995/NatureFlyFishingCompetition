import Foundation

final class WorkoutHistoryStore: ObservableObject {

    static let shared = WorkoutHistoryStore()

    @Published private(set) var sessions: [WorkoutSession] = []

    private let key = "com.natureflyfish.history"
    private let maxEntries = 100

    private init() {
        load()
    }

    // MARK: - Public

    func add(_ session: WorkoutSession) {
        sessions.insert(session, at: 0) // más reciente primero
        if sessions.count > maxEntries {
            sessions = Array(sessions.prefix(maxEntries))
        }
        save()
    }

    func delete(at offsets: IndexSet) {
        sessions.remove(atOffsets: offsets)
        save()
    }

    func deleteAll() {
        sessions.removeAll()
        save()
    }

    // MARK: - Stats

    var totalSessions: Int { sessions.count }

    var bestSession: WorkoutSession? {
        sessions.max(by: { $0.totalPeces < $1.totalPeces })
    }

    var totalPeces: Int {
        sessions.reduce(0) { $0 + $1.totalPeces }
    }

    var averagePeces: Double {
        guard !sessions.isEmpty else { return 0 }
        return Double(totalPeces) / Double(sessions.count)
    }

    // MARK: - Persistence

    private func save() {
        guard let data = try? JSONEncoder().encode(sessions) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([WorkoutSession].self, from: data)
        else { return }
        sessions = decoded
    }
}
