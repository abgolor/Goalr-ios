import SwiftUI

struct WeeklyProgressView: View {
    let progress: [DailyProgress]
    let goal: Int
    @Binding var selectedDate: Date
    @Binding var animatePulse: Bool
    
    @State private var animateAppear = false
    
    private var weekDates: [Date] {
        (0..<7)
            .compactMap { Calendar.current.date(byAdding: .day, value: -$0, to: Date()) }
            .reversed()
    }
    
    private let brandPrimary = Color(red: 0/255, green: 185/255, blue: 190/255)
    private let brandSecondary = Color(red: 0/255, green: 150/255, blue: 155/255)
    
    var body: some View {
        VStack(spacing: 20) {
            // MARK: - Week Navigation Header
            HStack {
                Button(action: {}) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white.opacity(0.6))
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.05))
                        )
                }
                
                Spacer()
                
                Text("This Week")
                    .font(.custom("Inter-SemiBold", size: 16))
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white.opacity(0.6))
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.05))
                        )
                }
            }
            .padding(.horizontal, 8)
            
            // MARK: - Week Progress Circles
            HStack(spacing: 12) {
                ForEach(Array(weekDates.enumerated()), id: \.element) { index, day in
                    let dayProgress = progress.first { Calendar.current.isDate($0.date, inSameDayAs: day) }
                    let steps = dayProgress?.steps ?? 0
                    let goalMet = dayProgress?.goalMet ?? false
                    let progressFraction = min(Double(steps) / Double(goal), 1.0)
                    let isToday = Calendar.current.isDateInToday(day)
                    let isSelected = Calendar.current.isDate(selectedDate, inSameDayAs: day)
                    
                    WeeklyProgressDayView(
                        day: day,
                        steps: steps,
                        progressFraction: progressFraction,
                        goalMet: goalMet,
                        isToday: isToday,
                        isSelected: isSelected,
                        animatePulse: animatePulse,
                        brandPrimary: brandPrimary,
                        onTap: {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                selectedDate = day
                            }
                            
                            // Haptic feedback
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                        }
                    )
                    .scaleEffect(animateAppear ? 1 : 0.3)
                    .opacity(animateAppear ? 1 : 0)
                    .animation(
                        .spring(response: 0.6, dampingFraction: 0.8)
                        .delay(Double(index) * 0.1),
                        value: animateAppear
                    )
                }
            }
            .padding(.horizontal, 8)
            
            // MARK: - Week Summary Stats
            HStack(spacing: 20) {
                WeekSummaryItem(
                    title: "Completed",
                    value: "\(completedDays)",
                    subtitle: "days",
                    color: brandPrimary
                )
                
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 1, height: 30)
                
                WeekSummaryItem(
                    title: "Total Steps",
                    value: formatSteps(totalSteps),
                    subtitle: "this week",
                    color: .orange
                )
                
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 1, height: 30)
                
                WeekSummaryItem(
                    title: "Average",
                    value: formatSteps(averageSteps),
                    subtitle: "per day",
                    color: .purple
                )
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.02))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.05), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 8)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8).delay(0.5)) {
                animateAppear = true
            }
        }
    }
    
    // MARK: - Computed Properties
    private var completedDays: Int {
        progress.filter { $0.goalMet }.count
    }
    
    private var totalSteps: Int {
        progress.reduce(0) { $0 + $1.steps }
    }
    
    private var averageSteps: Int {
        guard !progress.isEmpty else { return 0 }
        return totalSteps / progress.count
    }
    
    private func formatSteps(_ steps: Int) -> String {
        if steps >= 1000 {
            return String(format: "%.1fk", Double(steps) / 1000.0)
        }
        return "\(steps)"
    }
}

// MARK: - Individual Day Progress View
struct WeeklyProgressDayView: View {
    let day: Date
    let steps: Int
    let progressFraction: Double
    let goalMet: Bool
    let isToday: Bool
    let isSelected: Bool
    let animatePulse: Bool
    let brandPrimary: Color
    let onTap: () -> Void
    
    private var dayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter
    }
    
    private var dayNumberFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Day Label
            Text(dayFormatter.string(from: day))
                .font(.custom("Inter-Medium", size: 11))
                .foregroundColor(isToday ? brandPrimary : .white.opacity(0.6))
                .fontWeight(isToday ? .semibold : .medium)
            
            // Progress Circle
            ZStack {
                // Background Circle
                Circle()
                    .stroke(
                        Color.white.opacity(isSelected ? 0.15 : 0.08),
                        lineWidth: isSelected ? 6 : 4
                    )
                    .frame(width: 44, height: 44)
                
                // Progress Arc
                Circle()
                    .trim(from: 0, to: progressFraction)
                    .stroke(
                        LinearGradient(
                            colors: goalMet ?
                                [brandPrimary, brandPrimary.opacity(0.8)] :
                                [brandPrimary.opacity(0.8), brandPrimary.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: isSelected ? 6 : 4, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 44, height: 44)
                    .shadow(
                        color: brandPrimary.opacity(progressFraction > 0 ? 0.4 : 0),
                        radius: isToday && animatePulse ? 8 : 0
                    )
                
                // Goal Achievement Checkmark
                if goalMet {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(brandPrimary)
                        .scaleEffect(isSelected ? 1.1 : 1.0)
                } else if steps > 0 {
                    // Step count for incomplete days
                    Text(formatMiniSteps(steps))
                        .font(.custom("Inter-Bold", size: 8))
                        .foregroundColor(.white.opacity(0.8))
                        .scaleEffect(isSelected ? 1.1 : 1.0)
                }
                
                // Selection Ring
                if isSelected {
                    Circle()
                        .stroke(brandPrimary.opacity(0.3), lineWidth: 2)
                        .frame(width: 52, height: 52)
                        .scaleEffect(animatePulse ? 1.1 : 1.0)
                        .opacity(animatePulse ? 0.3 : 0.6)
                }
                
                // Today Pulse Ring
                if isToday && !isSelected {
                    Circle()
                        .stroke(brandPrimary.opacity(0.2), lineWidth: 1)
                        .frame(width: 56, height: 56)
                        .scaleEffect(animatePulse ? 1.3 : 1.0)
                        .opacity(animatePulse ? 0.0 : 0.4)
                }
            }
            .onTapGesture(perform: onTap)
            
            // Day Number
            Text(dayNumberFormatter.string(from: day))
                .font(.custom("Inter-Medium", size: 10))
                .foregroundColor(isSelected ? brandPrimary : .white.opacity(0.5))
                .fontWeight(isSelected ? .semibold : .medium)
        }
        .frame(maxWidth: .infinity)
        .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: animatePulse)
    }
    
    private func formatMiniSteps(_ steps: Int) -> String {
        if steps >= 1000 {
            return "\(steps / 1000)k"
        }
        return "\(steps)"
    }
}

// MARK: - Week Summary Item
struct WeekSummaryItem: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.custom("Inter-Medium", size: 11))
                .foregroundColor(.white.opacity(0.6))
            
            Text(value)
                .font(.custom("Montserrat-Bold", size: 18))
                .foregroundColor(color)
            
            Text(subtitle)
                .font(.custom("Inter-Regular", size: 9))
                .foregroundColor(.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview
struct WeeklyProgressView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 20) {
                WeeklyProgressView(
                    progress: [
                        DailyProgress(date: Calendar.current.date(byAdding: .day, value: -6, to: Date())!, steps: 4200, goalMet: true),
                        DailyProgress(date: Calendar.current.date(byAdding: .day, value: -5, to: Date())!, steps: 3800, goalMet: false),
                        DailyProgress(date: Calendar.current.date(byAdding: .day, value: -4, to: Date())!, steps: 1500, goalMet: false),
                        DailyProgress(date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!, steps: 4000, goalMet: true),
                        DailyProgress(date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, steps: 2200, goalMet: false),
                        DailyProgress(date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, steps: 4500, goalMet: true),
                        DailyProgress(date: Date(), steps: 3200, goalMet: false)
                    ],
                    goal: 4000,
                    selectedDate: .constant(Date()),
                    animatePulse: .constant(true)
                )
            }
            .padding()
        }
        .preferredColorScheme(.dark)
    }
}
