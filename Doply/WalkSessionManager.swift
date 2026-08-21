import Foundation
import CoreMotion
import Combine

/// Placeholder reward formula — swap this out later without touching any view code.
func coinsEarned(forSteps steps: Int) -> Int {
    steps / 100
}

/// Drives a single walk session: live step count, distance and elapsed time.
/// Create a fresh instance per session — it is not meant to be shared globally.
@MainActor
final class WalkSessionManager: ObservableObject {
    @Published var steps: Int = 0
    @Published var distanceMeters: Double = 0
    @Published var elapsedSeconds: Int = 0
    @Published var isMotionAccessDenied: Bool = false

    private let pedometer = CMPedometer()
    private var startDate: Date?
    private var clockTimer: Timer?

    #if targetEnvironment(simulator)
    private var fakeStepsTimer: Timer?
    #endif

    var isStepCountingAvailable: Bool {
        CMPedometer.isStepCountingAvailable()
    }

    func start() {
        reset()
        startDate = Date()

        clockTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self, let start = self.startDate else { return }
            self.elapsedSeconds = Int(Date().timeIntervalSince(start))
        }

        #if targetEnvironment(simulator)
        // CMPedometer reports no real data in the simulator, so fake a walking pace.
        fakeStepsTimer = Timer.scheduledTimer(withTimeInterval: 1.2, repeats: true) { [weak self] _ in
            guard let self else { return }
            let increment = Int.random(in: 3...9)
            self.steps += increment
            self.distanceMeters += Double(increment) * 0.75
        }
        #else
        guard CMPedometer.isStepCountingAvailable() else {
            isMotionAccessDenied = true
            return
        }
        pedometer.startUpdates(from: Date()) { [weak self] data, error in
            guard let self else { return }
            Task { @MainActor in
                if error != nil {
                    self.isMotionAccessDenied = true
                    return
                }
                guard let data else { return }
                self.steps = data.numberOfSteps.intValue
                self.distanceMeters = data.distance?.doubleValue ?? self.distanceMeters
            }
        }
        #endif
    }

    func stop() {
        pedometer.stopUpdates()
        clockTimer?.invalidate()
        clockTimer = nil
        #if targetEnvironment(simulator)
        fakeStepsTimer?.invalidate()
        fakeStepsTimer = nil
        #endif
    }

    func reset() {
        stop()
        steps = 0
        distanceMeters = 0
        elapsedSeconds = 0
        isMotionAccessDenied = false
        startDate = nil
    }
}
