import SwiftUI

struct ProgressCircleView: View {
    let steps: Int
    let goal: Int
    let date: Date
    let isSelectedToday: Bool
    @Binding var animatePulse: Bool

    @State private var showBurst = false
    @State private var showStepCount = false

    private let brandPrimary = Color(red: 0/255, green: 185/255, blue: 190/255)
    private let brandSecondary = Color(red: 0/255, green: 150/255, blue: 155/255)

    var progressFraction: Double {
        min(Double(steps) / Double(goal), 1.0)
    }

    var remainingSteps: Int {
        max(goal - steps, 0)
    }

    var body: some View {
        ZStack {
            // MARK: - Outer Glow Ring
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [brandPrimary.opacity(0.1), brandPrimary.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
                .frame(width: 280, height: 280)
                .opacity(animatePulse ? 0.8 : 0.3)

            // MARK: - Background Circle
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.04), Color.white.opacity(0.08)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 28
                )
                .frame(width: 240, height: 240)

            // MARK: - Progress Circle with Gradient
            Circle()
                .trim(from: 0, to: progressFraction) // directly bind progressFraction
                .stroke(
                    AngularGradient(
                        colors: [
                            brandPrimary,
                            brandSecondary,
                            brandPrimary.opacity(0.8),
                            brandPrimary
                        ],
                        center: .center,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(270)
                    ),
                    style: StrokeStyle(lineWidth: 28, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .frame(width: 240, height: 240)
                .shadow(
                    color: brandPrimary.opacity(progressFraction > 0 ? 0.4 : 0),
                    radius: animatePulse ? 20 : 8
                )
                .scaleEffect(animatePulse ? 1.02 : 1.0)
                .animation(.easeInOut(duration: 0.8), value: progressFraction) // animate whenever progress changes




            // MARK: - Center Content
            VStack(spacing: 6) {
                Text(isSelectedToday ? "Today" : dateFormatter.string(from: date))
                    .font(.custom("Inter-Medium", size: 14))
                    .foregroundColor(.white.opacity(0.6))
                    .opacity(showStepCount ? 1 : 0)

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(steps)")
                        .font(.custom("Montserrat-Bold", size: 48))
                        .foregroundColor(.white)
                        .contentTransition(.numericText())

                    Text("steps")
                        .font(.custom("Inter-Medium", size: 16))
                        .foregroundColor(.white.opacity(0.7))
                        .offset(y: -4)
                }
                .opacity(showStepCount ? 1 : 0)
                .scaleEffect(showStepCount ? 1 : 0.8)

                // Goal Status
                if isSelectedToday {
                    if steps >= goal {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(brandPrimary)
                                .font(.system(size: 16, weight: .semibold))

                            Text("Goal Achieved!")
                                .font(.custom("Inter-SemiBold", size: 16))
                                .foregroundColor(brandPrimary)
                        }
                        .opacity(showStepCount ? 1 : 0)
                    } else {
                        VStack(spacing: 2) {
                            Text("\(remainingSteps) to go")
                                .font(.custom("Inter-Medium", size: 16))
                                .foregroundColor(.white.opacity(0.8))

                            Text("Goal: \(formatNumber(goal))")
                                .font(.custom("Inter-Regular", size: 14))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        .opacity(showStepCount ? 1 : 0)
                    }
                } else {
                    HStack(spacing: 6) {
                        Image(systemName: steps >= goal ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(steps >= goal ? brandPrimary : .red.opacity(0.7))
                            .font(.system(size: 16, weight: .semibold))

                        Text(steps >= goal ? "Goal Achieved" : "Goal Missed")
                            .font(.custom("Inter-SemiBold", size: 16))
                            .foregroundColor(steps >= goal ? brandPrimary : .red.opacity(0.7))
                    }
                    .opacity(showStepCount ? 1 : 0)
                }

                // Progress Percentage (small)
                if progressFraction > 0 && progressFraction < 1 {
                    Text("\(Int(progressFraction * 100))%")
                        .font(.custom("Inter-Medium", size: 12))
                        .foregroundColor(.white.opacity(0.4))
                        .opacity(showStepCount ? 1 : 0)
                }
            }

            // MARK: - Particle Burst Effect
            if showBurst {
                ParticleBurstView(color: brandPrimary)
                    .frame(width: 320, height: 320)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8).delay(0.3)) {
                showStepCount = true
            }
        }
        .onChange(of: steps) { newSteps in
            if newSteps >= goal && !showBurst {
                showBurst = true
                let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
                impactFeedback.impactOccurred()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    showBurst = false
                }
            }
        }
        .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true), value: animatePulse)
    }

    private var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "MMM d"
        return df
    }

    private func formatNumber(_ number: Int) -> String {
        if number >= 1000 {
            return String(format: "%.1fk", Double(number) / 1000.0)
        }
        return "\(number)"
    }
}



// MARK: - Preview
struct ProgressCircleView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 40) {
                ProgressCircleView(
                    steps: 3200,
                    goal: 4000,
                    date: Date(),
                    isSelectedToday: true,
                    animatePulse: .constant(true)
                )
                
                ProgressCircleView(
                    steps: 4500,
                    goal: 4000,
                    date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
                    isSelectedToday: false,
                    animatePulse: .constant(true)
                )
            }
        }
        .preferredColorScheme(.dark)
    }
}
