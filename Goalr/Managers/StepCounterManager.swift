import Foundation
import CoreMotion
import HealthKit
import Combine

class StepCounterManager: ObservableObject {
    static let shared = StepCounterManager()
    
    @Published var stepsToday: Int = 0
    @Published var tracking: Bool = false
    
    private let pedometer = CMPedometer()
    private let healthStore = HKHealthStore()
    private let calendar = Calendar.current
    private var cancellables = Set<AnyCancellable>()
    
    private let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
    
    init() {
        requestAuthorization()
        fetchStepsToday() // Load steps immediately on launch
    }
    
    // MARK: - HealthKit Authorization
    private func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        
        let toRead: Set = [stepType]
        healthStore.requestAuthorization(toShare: [], read: toRead) { success, error in
            if success {
                self.startObservingSteps()
            } else {
                print("HealthKit authorization failed: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    // MARK: - Background Delivery
    private func startObservingSteps() {
        let observerQuery = HKObserverQuery(sampleType: stepType, predicate: nil) { [weak self] _, _, error in
            guard let self = self, error == nil else { return }
            self.fetchStepsToday()
        }
        
        healthStore.execute(observerQuery)
        
        healthStore.enableBackgroundDelivery(for: stepType, frequency: .immediate) { success, error in
            if success {
                print("✅ Background delivery enabled")
            } else {
                print("❌ Failed to enable background delivery: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    // MARK: - Fetch Steps from HealthKit
    func fetchStepsToday() {
        let startOfDay = calendar.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { [weak self] _, result, _ in
            guard let self = self, let sum = result?.sumQuantity() else { return }
            DispatchQueue.main.async {
                self.stepsToday = Int(sum.doubleValue(for: HKUnit.count()))
            }
        }
        
        healthStore.execute(query)
    }
    
    // MARK: - Live Tracking with CMPedometer
    func startLiveTracking() {
        guard CMPedometer.isStepCountingAvailable() else {
            print("Step counting not available.")
            return
        }
        
        tracking = true
        let startOfDay = calendar.startOfDay(for: Date())
        
        pedometer.startUpdates(from: startOfDay) { [weak self] data, error in
            guard let self = self, let data = data, error == nil else { return }
            DispatchQueue.main.async {
                self.stepsToday = data.numberOfSteps.intValue
            }
        }
    }
    
    func stopTracking() {
        pedometer.stopUpdates()
        tracking = false
    }
}
