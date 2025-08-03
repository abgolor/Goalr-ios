import SwiftUI
import Combine

class GoalrViewModel: ObservableObject {
    @Published var user: User?
    @Published var dailyProgress: [DailyProgress] = []
    @Published var currentSteps: Int = 0
    @Published var streak: Int = 0

    private let userDefaults = UserDefaults.standard
    private var cancellables = Set<AnyCancellable>()
    
    init(stepManager: StepCounterManager = StepCounterManager.shared) {
        loadUserData()
        loadProgress()
        resetStepsIfNeeded()
        updateStreak()
        
        // Subscribe to step updates
        stepManager.$stepsToday
            .sink { [weak self] steps in
                self?.addSteps(steps)
            }
            .store(in: &cancellables)
        
        // Start live tracking (foreground)
        stepManager.startLiveTracking()
    }

    func saveUser(_ user: User) {
        self.user = user
        if let encoded = try? JSONEncoder().encode(user) {
            userDefaults.set(encoded, forKey: "user")
        }
    }

    private func loadUserData() {
        if let data = userDefaults.data(forKey: "user"),
           let decoded = try? JSONDecoder().decode(User.self, from: data) {
            self.user = decoded
        }
    }

    func addSteps(_ steps: Int) {
        currentSteps = steps
        saveTodayProgress()
        updateStreak()
    }

    private func saveTodayProgress() {
        guard let user = user else { return }
        let today = Calendar.current.startOfDay(for: Date())
        
        if let index = dailyProgress.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
            dailyProgress[index].steps = currentSteps
            dailyProgress[index].goalMet = currentSteps >= user.dailyGoal
        } else {
            dailyProgress.append(DailyProgress(date: today, steps: currentSteps, goalMet: currentSteps >= user.dailyGoal))
        }
        
        dailyProgress = Array(dailyProgress.suffix(30))
        
        if let encoded = try? JSONEncoder().encode(dailyProgress) {
            userDefaults.set(encoded, forKey: "progress")
        }
    }

    private func loadProgress() {
        if let data = userDefaults.data(forKey: "progress"),
           let decoded = try? JSONDecoder().decode([DailyProgress].self, from: data) {
            self.dailyProgress = decoded
        }
    }

    private func resetStepsIfNeeded() {
        let today = Calendar.current.startOfDay(for: Date())
        if let lastProgress = dailyProgress.last {
            currentSteps = Calendar.current.isDate(lastProgress.date, inSameDayAs: today) ? lastProgress.steps : 0
        } else {
            currentSteps = 0
        }
    }

    private func updateStreak() {
        let sortedProgress = dailyProgress.sorted { $0.date > $1.date }
        var streakCount = 0
        var currentDate = Calendar.current.startOfDay(for: Date())
        
        for progress in sortedProgress {
            if Calendar.current.isDate(progress.date, inSameDayAs: currentDate), progress.goalMet {
                streakCount += 1
                currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate)!
            } else if !progress.goalMet {
                break
            }
        }
        
        streak = streakCount
    }
}
