import SwiftUI

struct RegistrationView: View {
    @StateObject var viewModel: GoalrViewModel
    @State private var name = ""
    @State private var username = ""
    @State private var dailyGoal = 6000
    @State private var showGoalPicker = false
    @State private var currentStep = 0
    @State private var animateElements = false
    @State private var showSuccess = false
    @FocusState private var focusedField: String?
    
    private let brandPrimary = Color(red: 0/255, green: 185/255, blue: 190/255)
    private let brandSecondary = Color(red: 0/255, green: 150/255, blue: 155/255)
    
    private let totalSteps = 3

    var body: some View {
        ZStack {
            // MARK: - Background
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
            
            // Background Particles
            ForEach(0..<8) { index in
                Circle()
                    .fill(brandPrimary.opacity(0.05))
                    .frame(width: CGFloat(30 + index * 10))
                    .offset(
                        x: CGFloat.random(in: -200...200),
                        y: CGFloat.random(in: -400...400)
                    )
                    .blur(radius: 20)
                    .opacity(animateElements ? 0.3 : 0.1)
                    .animation(
                        .easeInOut(duration: Double(4 + index))
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.5),
                        value: animateElements
                    )
            }
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // MARK: - Header Section
                    VStack(spacing: 24) {
                        // Progress Indicator
                        HStack(spacing: 8) {
                            ForEach(0..<totalSteps, id: \.self) { step in
                                Capsule()
                                    .fill(step <= currentStep ? brandPrimary : Color.white.opacity(0.2))
                                    .frame(width: step <= currentStep ? 40 : 20, height: 4)
                                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: currentStep)
                            }
                        }
                        .padding(.top, 20)
                        
                        // Welcome Text
                        VStack(spacing: 12) {
                            Text("Welcome to")
                                .font(.custom("Inter-Medium", size: 20))
                                .foregroundColor(.white.opacity(0.7))
                                .opacity(animateElements ? 1 : 0)
                                .offset(y: animateElements ? 0 : -20)
                            
                            Text("Goalr")
                                .font(.custom("Montserrat-ExtraBold", size: 48))
                                .foregroundColor(.white)
                                .shadow(color: brandPrimary.opacity(0.6), radius: 15)
                                .opacity(animateElements ? 1 : 0)
                                .scaleEffect(animateElements ? 1 : 0.8)
                            
                            Text("Greatness is Earned")
                                .font(.custom("Inter-Regular", size: 16))
                                .italic()
                                .foregroundColor(.white.opacity(0.6))
                                .opacity(animateElements ? 1 : 0)
                                .offset(y: animateElements ? 0 : 20)
                        }
                        .animation(.spring(response: 1, dampingFraction: 0.8).delay(0.2), value: animateElements)
                    }
                    .padding(.top, 40)
                    
                    Spacer().frame(height: 60)
                    
                    // MARK: - Form Content
                    VStack(spacing: 32) {
                        if currentStep >= 0 {
                            // Name Step
                            FormStepView(
                                title: "What's your name?",
                                subtitle: "Let's personalize your experience",
                                isVisible: currentStep >= 0
                            ) {
                                ModernTextField(
                                    title: "Full Name",
                                    text: $name,
                                    focusedField: _focusedField,
                                    fieldName: "name",
                                    icon: "person.fill"
                                )
                            }
                        }
                        
                        if currentStep >= 1 {
                            // Username Step
                            FormStepView(
                                title: "Choose a username",
                                subtitle: "This is how others will find you",
                                isVisible: currentStep >= 1
                            ) {
                                ModernTextField(
                                    title: "Username",
                                    text: $username,
                                    focusedField: _focusedField,
                                    fieldName: "username",
                                    icon: "at"
                                )
                            }
                        }
                        
                        if currentStep >= 2 {
                            // Goal Step
                            FormStepView(
                                title: "Set your daily goal",
                                subtitle: "Challenge yourself to grow every day",
                                isVisible: currentStep >= 2
                            ) {
                                GoalSelectionCard(
                                    dailyGoal: $dailyGoal,
                                    showGoalPicker: $showGoalPicker
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer().frame(height: 60)
                    
                    // MARK: - Action Buttons
                    VStack(spacing: 16) {
                        if currentStep < totalSteps - 1 {
                            // Next Button
                            ActionButton(
                                title: "Continue",
                                isPrimary: true,
                                isEnabled: canProceed
                            ) {
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    currentStep += 1
                                }
                                
                                // Haptic feedback
                                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                impactFeedback.impactOccurred()
                            }
                        } else {
                            // Complete Registration Button
                            ActionButton(
                                title: "Enter Greatness",
                                isPrimary: true,
                                isEnabled: canComplete,
                                showSuccessState: showSuccess
                            ) {
                                completeRegistration()
                            }
                        }
                        
                        if currentStep > 0 {
                            // Back Button
                            ActionButton(
                                title: "Back",
                                isPrimary: false,
                                isEnabled: true
                            ) {
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    currentStep -= 1
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
            
            // MARK: - Goal Picker Modal
            if showGoalPicker {
                GoalPickerView(dailyGoal: $dailyGoal, showGoalPicker: $showGoalPicker)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(1)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1).delay(0.3)) {
                animateElements = true
            }
        }
    }
    
    // MARK: - Helper Properties
    private var canProceed: Bool {
        switch currentStep {
        case 0: return !name.isEmpty
        case 1: return !username.isEmpty
        default: return true
        }
    }
    
    private var canComplete: Bool {
        !name.isEmpty && !username.isEmpty
    }
    
    // MARK: - Helper Functions
    private func completeRegistration() {
        showSuccess = true
        
        // Success haptic
        let successFeedback = UINotificationFeedbackGenerator()
        successFeedback.notificationOccurred(.success)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            viewModel.saveUser(User(name: name, username: username, dailyGoal: dailyGoal))
        }
    }
}

// MARK: - Form Step View
struct FormStepView<Content: View>: View {
    let title: String
    let subtitle: String
    let isVisible: Bool
    let content: Content
    
    init(title: String, subtitle: String, isVisible: Bool, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.isVisible = isVisible
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.custom("Montserrat-SemiBold", size: 24))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(subtitle)
                    .font(.custom("Inter-Regular", size: 16))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : -30)
            .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.1), value: isVisible)
            
            content
                .opacity(isVisible ? 1 : 0)
                .offset(y: isVisible ? 0 : 30)
                .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.3), value: isVisible)
        }
    }
}

// MARK: - Modern TextField
struct ModernTextField: View {
    var title: String
    @Binding var text: String
    @FocusState var focusedField: String?
    var fieldName: String
    var icon: String
    
    private let brandPrimary = Color(red: 0/255, green: 185/255, blue: 190/255)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.custom("Inter-Medium", size: 14))
                .foregroundColor(.white.opacity(0.8))
            
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(focusedField == fieldName ? brandPrimary : .white.opacity(0.6))
                    .frame(width: 20)
                
                TextField("Enter \(title.lowercased())", text: $text)
                    .font(.custom("Inter-Regular", size: 16))
                    .foregroundColor(.white)
                    .focused($focusedField, equals: fieldName)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                focusedField == fieldName ? brandPrimary : Color.white.opacity(0.1),
                                lineWidth: focusedField == fieldName ? 2 : 1
                            )
                    )
            )
            .shadow(
                color: focusedField == fieldName ? brandPrimary.opacity(0.2) : Color.clear,
                radius: focusedField == fieldName ? 8 : 0
            )
        }
        .animation(.easeInOut(duration: 0.2), value: focusedField)
    }
}

// MARK: - Goal Selection Card
struct GoalSelectionCard: View {
    @Binding var dailyGoal: Int
    @Binding var showGoalPicker: Bool
    
    private let brandPrimary = Color(red: 0/255, green: 185/255, blue: 190/255)
    
    var body: some View {
        Button(action: { showGoalPicker = true }) {
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: "target")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(brandPrimary)
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(dailyGoal)")
                            .font(.custom("Montserrat-Bold", size: 28))
                            .foregroundColor(.white)
                        
                        Text("steps daily")
                            .font(.custom("Inter-Medium", size: 14))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(goalLevelText)
                            .font(.custom("Inter-SemiBold", size: 16))
                            .foregroundColor(goalLevelColor)
                        
                        Text("Tap to customize")
                            .font(.custom("Inter-Regular", size: 12))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(brandPrimary.opacity(0.3), lineWidth: 1)
                    )
            )
            .shadow(color: brandPrimary.opacity(0.15), radius: 12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var goalLevelText: String {
        switch dailyGoal {
        case 3000...4900: return "Easier Goal"
        case 5000: return "Recommended"
        case 5100...12000: return "Challenging"
        case 12001...: return "Elite Level"
        default: return "Custom Goal"
        }
    }
    
    private var goalLevelColor: Color {
        switch dailyGoal {
        case 3000...4900: return .green
        case 5000: return brandPrimary
        case 5100...12000: return .orange
        case 12001...: return .red
        default: return .white
        }
    }
}

// MARK: - Action Button
struct ActionButton: View {
    let title: String
    let isPrimary: Bool
    let isEnabled: Bool
    var showSuccessState: Bool = false
    let action: () -> Void
    
    private let brandPrimary = Color(red: 0/255, green: 185/255, blue: 190/255)
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if showSuccessState {
                    Image(systemName: "checkmark")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(isPrimary ? .black : brandPrimary)
                } else {
                    Text(title)
                        .font(.custom("Montserrat-SemiBold", size: 18))
                        .foregroundColor(isPrimary ? .black : brandPrimary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isPrimary ? brandPrimary : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(brandPrimary, lineWidth: isPrimary ? 0 : 2)
                    )
            )
            .shadow(
                color: isPrimary ? brandPrimary.opacity(0.4) : Color.clear,
                radius: isPrimary ? 12 : 0,
                y: isPrimary ? 6 : 0
            )
            .scaleEffect(isEnabled ? 1 : 0.95)
            .opacity(isEnabled ? 1 : 0.6)
        }
        .disabled(!isEnabled)
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showSuccessState)
        .animation(.easeInOut(duration: 0.2), value: isEnabled)
    }
}

// MARK: - Extensions
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Preview
struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationView(viewModel: GoalrViewModel())
            .preferredColorScheme(.dark)
    }
}
