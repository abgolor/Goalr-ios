import SwiftUI

struct HomeView: View {
    @StateObject var viewModel: GoalrViewModel
    @StateObject var stepManager = StepCounterManager()
    
    @State private var selectedDate = Date()
    @State private var animatePulse = false
    @State private var showDetails = false
    
    private let brandPrimary = Color(red: 0/255, green: 185/255, blue: 190/255)
    private let brandSecondary = Color(red: 0/255, green: 150/255, blue: 155/255)
    
    var selectedProgress: DailyProgress? {
        viewModel.dailyProgress.first { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
    }
    
    var stepsToday: Int {
        Calendar.current.isDateInToday(selectedDate)
        ? stepManager.stepsToday
        : (selectedProgress?.steps ?? 0)
    }
    
    var progressPercentage: Int {
        let goal = viewModel.user?.dailyGoal ?? 4000
        return min(Int((Double(stepsToday) / Double(goal)) * 100), 100)
    }
    
    var body: some View {
        ZStack {
            // Enhanced gradient background
            LinearGradient(
                colors: [
                    Color(hex: "#000000"),
                    Color(hex: "#0a0a0a"),
                    Color(hex: "#080808")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // MARK: - Header Section
                    VStack(spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(greetingText())
                                    .font(.custom("Inter-Medium", size: 16))
                                    .foregroundColor(.white.opacity(0.7))
                                
                                Text(viewModel.user?.name ?? "Welcome")
                                    .font(.custom("Montserrat-Bold", size: 24))
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                            
                            // Notification/Profile Button
                            Button(action: {}) {
                                ZStack {
                                    Circle()
                                        .fill(Color.white.opacity(0.05))
                                        .frame(width: 44, height: 44)
                                    
                                    Image(systemName: "person.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(brandPrimary)
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                    }
                    
                    // MARK: - Main Progress Section
                    VStack(spacing: 32) {
                        // Enhanced Progress Circle
                        ZStack {
                            // Subtle outer glow
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [brandPrimary.opacity(0.1), Color.clear],
                                        center: .center,
                                        startRadius: 120,
                                        endRadius: 160
                                    )
                                )
                                .frame(width: 320, height: 320)
                                .opacity(animatePulse ? 0.8 : 0.4)
                            
                            ProgressCircleView(
                                steps: stepsToday,
                                goal: viewModel.user?.dailyGoal ?? 4000,
                                date: selectedDate,
                                isSelectedToday: Calendar.current.isDateInToday(selectedDate),
                                animatePulse: $animatePulse
                            )
                        }
                        .padding(.top, 40)
                        
                        // MARK: - Stats Cards
                        HStack(spacing: 16) {
                            StatCard(
                                icon: "flame.fill",
                                iconColor: .orange,
                                title: "Streak",
                                value: "\(viewModel.streak)",
                                subtitle: "days"
                            )
                            
                            StatCard(
                                icon: "target",
                                iconColor: brandPrimary,
                                title: "Progress",
                                value: "\(progressPercentage)%",
                                subtitle: "complete"
                            )
                            
                            StatCard(
                                icon: "calendar",
                                iconColor: .purple,
                                title: "Weekly",
                                value: "\(weeklyAverage)",
                                subtitle: "avg steps"
                            )
                        }
                        .padding(.horizontal, 24)
                        
                        // MARK: - Weekly Progress
                        VStack(spacing: 20) {
                            HStack {
                                Text("This Week")
                                    .font(.custom("Montserrat-SemiBold", size: 20))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Button(action: { showDetails.toggle() }) {
                                    Text("Details")
                                        .font(.custom("Inter-Medium", size: 14))
                                        .foregroundColor(brandPrimary)
                                }
                            }
                            .padding(.horizontal, 24)
                            
                            WeeklyProgressView(
                                progress: viewModel.dailyProgress,
                                goal: viewModel.user?.dailyGoal ?? 4000,
                                selectedDate: $selectedDate,
                                animatePulse: $animatePulse
                            )
                            .padding(.horizontal, 16)
                        }
                        
                        // MARK: - Quick Actions
                        VStack(spacing: 16) {
                            HStack {
                                Text("Quick Actions")
                                    .font(.custom("Montserrat-SemiBold", size: 18))
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .padding(.horizontal, 24)
                            
                            HStack(spacing: 12) {
                                HomeActionButton(
                                    icon: "target",
                                    title: "Set Goal",
                                    color: brandPrimary
                                ) {}
                                
                                HomeActionButton(
                                    icon: "chart.bar.fill",
                                    title: "Analytics",
                                    color: .purple
                                ) {}
                                
                                HomeActionButton(
                                    icon: "person.2.fill",
                                    title: "Friends",
                                    color: .orange
                                ) {}
                            }
                            .padding(.horizontal, 24)
                        }
                        
                        Spacer(minLength: 100)
                    }
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                animatePulse = true
            }
        }
    }
    
    // MARK: - Helper Functions
    private func greetingText() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        case 17..<22: return "Good Evening"
        default: return "Good Night"
        }
    }
    
    private var weeklyAverage: String {
        let total = viewModel.dailyProgress.reduce(0) { $0 + $1.steps }
        let average = total / max(viewModel.dailyProgress.count, 1)
        return formatSteps(average)
    }
    
    private func formatSteps(_ steps: Int) -> String {
        if steps >= 1000 {
            return String(format: "%.1fk", Double(steps) / 1000.0)
        }
        return "\(steps)"
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(iconColor)
            }
            
            VStack(spacing: 2) {
                Text(value)
                    .font(.custom("Montserrat-Bold", size: 20))
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.custom("Inter-Medium", size: 12))
                    .foregroundColor(.white.opacity(0.6))
                
                Text(subtitle)
                    .font(.custom("Inter-Regular", size: 10))
                    .foregroundColor(.white.opacity(0.4))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }
}

struct HomeActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(color.opacity(0.15))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(.custom("Inter-Medium", size: 12))
                    .foregroundColor(.white.opacity(0.8))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.03))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(viewModel: mockGoalrViewModel())
            .preferredColorScheme(.dark)
    }
}

// MARK: - Mock Data for Preview
private func mockGoalrViewModel() -> GoalrViewModel {
    let vm = GoalrViewModel()
    vm.user = User(name: "Abraham", username: "goalr", dailyGoal: 4000)
    vm.dailyProgress = [
        DailyProgress(date: Date(), steps: 3200, goalMet: false),
        DailyProgress(date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, steps: 4500, goalMet: true),
        DailyProgress(date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, steps: 1800, goalMet: false),
        DailyProgress(date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!, steps: 4000, goalMet: true),
        DailyProgress(date: Calendar.current.date(byAdding: .day, value: -4, to: Date())!, steps: 2200, goalMet: false),
        DailyProgress(date: Calendar.current.date(byAdding: .day, value: -5, to: Date())!, steps: 3800, goalMet: false),
        DailyProgress(date: Calendar.current.date(byAdding: .day, value: -6, to: Date())!, steps: 4200, goalMet: true)
    ]
    vm.streak = 2
    return vm
}
