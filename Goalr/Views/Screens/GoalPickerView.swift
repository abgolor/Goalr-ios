import SwiftUI

struct GoalPickerView: View {
    @Binding var dailyGoal: Int
    @Binding var showGoalPicker: Bool
    
    @State private var selectedGoal: Int = 6000
    @State private var animateAppear = false
    @State private var showConfirmation = false
    @State private var dragOffset: CGFloat = 0
    
    private let brandPrimary = Color(red: 0/255, green: 185/255, blue: 190/255)
    private let brandSecondary = Color(red: 0/255, green: 150/255, blue: 155/255)
    
    // Predefined goal options with descriptions
    private let goalPresets = [
        GoalPreset(steps: 3000, title: "Getting Started", description: "Perfect for beginners", color: .green, icon: "figure.walk"),
        GoalPreset(steps: 5000, title: "Recommended", description: "Health experts' choice", color: Color(red: 0/255, green: 185/255, blue: 190/255), icon: "heart.fill"),
        GoalPreset(steps: 8000, title: "Active", description: "For fitness enthusiasts", color: .orange, icon: "flame.fill"),
        GoalPreset(steps: 10000, title: "Challenging", description: "Push your limits", color: .red, icon: "bolt.fill"),
        GoalPreset(steps: 12000, title: "Elite", description: "For champions", color: .purple, icon: "crown.fill")
    ]
    
    var body: some View {
        ZStack {
            backgroundOverlay
            mainContentView
        }
        .onAppear(perform: setupView)
    }
    
    // MARK: - Background Overlay
    private var backgroundOverlay: some View {
        Color.black.opacity(0.7)
            .ignoresSafeArea()
            .onTapGesture {
                dismissPicker()
            }
    }
    
    // MARK: - Main Content
    private var mainContentView: some View {
        VStack(spacing: 0) {
            Spacer()
            modalContent
        }
    }
    
    private var modalContent: some View {
        VStack(spacing: 24) {
            headerSection
            currentGoalDisplay
            presetGoalsSection
            customGoalSection
            actionButtons
        }
        .background(modalBackground)
        .offset(y: dragOffset)
        .gesture(dismissDragGesture)
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            dragHandle
            titleAndCloseButton
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
    }
    
    private var dragHandle: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(Color.white.opacity(0.3))
            .frame(width: 36, height: 6)
            .opacity(animateAppear ? 1 : 0)
    }
    
    private var titleAndCloseButton: some View {
        HStack {
            titleText
            Spacer()
            closeButton
        }
        .opacity(animateAppear ? 1 : 0)
        .offset(y: animateAppear ? 0 : -20)
    }
    
    private var titleText: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Set Your Daily Goal")
                .font(.custom("Montserrat-Bold", size: 24))
                .foregroundColor(.white)
            
            Text("Choose a goal that challenges you")
                .font(.custom("Inter-Regular", size: 16))
                .foregroundColor(.white.opacity(0.7))
        }
    }
    
    private var closeButton: some View {
        Button(action: dismissPicker) {
            Image(systemName: "xmark")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white.opacity(0.7))
                .frame(width: 32, height: 32)
                .background(closeButtonBackground)
        }
    }
    
    private var closeButtonBackground: some View {
        Circle()
            .fill(Color.white.opacity(0.1))
    }
    
    // MARK: - Current Goal Display
    private var currentGoalDisplay: some View {
        VStack(spacing: 12) {
            goalCircleView
            GoalLevelBadge(goal: selectedGoal)
        }
        .opacity(animateAppear ? 1 : 0)
        .scaleEffect(animateAppear ? 1 : 0.8)
        .animation(.spring(response: 1, dampingFraction: 0.8).delay(0.2), value: animateAppear)
    }
    
    private var goalCircleView: some View {
        ZStack {
            backgroundCircle
            progressRing
            goalNumberText
        }
    }
    
    private var backgroundCircle: some View {
        Circle()
            .stroke(Color.white.opacity(0.1), lineWidth: 3)
            .frame(width: 120, height: 120)
    }
    
    private var progressRing: some View {
        Circle()
            .trim(from: 0, to: progressForGoal(selectedGoal))
            .stroke(progressGradient, style: progressStrokeStyle)
            .rotationEffect(.degrees(-90))
            .frame(width: 120, height: 120)
            .animation(.spring(response: 0.8, dampingFraction: 0.7), value: selectedGoal)
    }
    
    private var progressGradient: LinearGradient {
        LinearGradient(
            colors: [brandPrimary, brandSecondary],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var progressStrokeStyle: StrokeStyle {
        StrokeStyle(lineWidth: 6, lineCap: .round)
    }
    
    private var goalNumberText: some View {
        VStack(spacing: 4) {
            Text("\(selectedGoal)")
                .font(.custom("Montserrat-Bold", size: 28))
                .foregroundColor(.white)
                .contentTransition(.numericText())
            
            Text("steps")
                .font(.custom("Inter-Medium", size: 14))
                .foregroundColor(.white.opacity(0.7))
        }
    }
    
    // MARK: - Preset Goals Section
    private var presetGoalsSection: some View {
        VStack(spacing: 16) {
            quickSelectTitle
            presetScrollView
        }
    }
    
    private var quickSelectTitle: some View {
        Text("Quick Select")
            .font(.custom("Inter-SemiBold", size: 18))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .opacity(animateAppear ? 1 : 0)
            .offset(x: animateAppear ? 0 : -30)
    }
    
    private var presetScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            presetCardsHStack
        }
    }
    
    private var presetCardsHStack: some View {
        HStack(spacing: 16) {
            ForEach(Array(goalPresets.enumerated()), id: \.element.steps) { index, preset in
                presetCard(for: preset, at: index)
            }
        }
        .padding(.horizontal, 24)
    }
    
    private func presetCard(for preset: GoalPreset, at index: Int) -> some View {
        GoalPresetCard(
            preset: preset,
            isSelected: selectedGoal == preset.steps,
            onTap: {
                selectPresetGoal(preset.steps)
            }
        )
        .opacity(animateAppear ? 1 : 0)
        .offset(y: animateAppear ? 0 : 50)
        .animation(presetCardAnimation(for: index), value: animateAppear)
    }
    
    private func presetCardAnimation(for index: Int) -> Animation {
        .spring(response: 0.8, dampingFraction: 0.8)
        .delay(0.3 + Double(index) * 0.1)
    }
    
    // MARK: - Custom Goal Section
    private var customGoalSection: some View {
        VStack(spacing: 16) {
            customizeTitle
            sliderSection
        }
        .opacity(animateAppear ? 1 : 0)
        .offset(y: animateAppear ? 0 : 30)
        .animation(.spring(response: 1, dampingFraction: 0.8).delay(0.5), value: animateAppear)
    }
    
    private var customizeTitle: some View {
        Text("Or customize")
            .font(.custom("Inter-SemiBold", size: 16))
            .foregroundColor(.white.opacity(0.8))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
    }
    
    private var sliderSection: some View {
        VStack(spacing: 12) {
            sliderLabels
            customSlider
        }
    }
    
    private var sliderLabels: some View {
        HStack {
            Text("3,000")
                .font(.custom("Inter-Medium", size: 14))
                .foregroundColor(.white.opacity(0.6))
            
            Spacer()
            
            Text("15,000")
                .font(.custom("Inter-Medium", size: 14))
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(.horizontal, 24)
    }
    
    private var customSlider: some View {
        CustomSlider(
            value: Binding(
                get: { Double(selectedGoal) },
                set: { selectedGoal = Int($0) }
            ),
            range: 3000...15000,
            step: 100
        )
        .padding(.horizontal, 24)
    }
    
    // MARK: - Action Buttons
    private var actionButtons: some View {
        VStack(spacing: 12) {
            confirmButton
            cancelButton
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 32)
        .opacity(animateAppear ? 1 : 0)
        .offset(y: animateAppear ? 0 : 50)
        .animation(.spring(response: 1, dampingFraction: 0.8).delay(0.6), value: animateAppear)
    }
    
    private var confirmButton: some View {
        Button(action: confirmGoal) {
            confirmButtonContent
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(confirmButtonBackground)
        }
        .scaleEffect(showConfirmation ? 0.95 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: showConfirmation)
    }
    
    private var confirmButtonContent: some View {
        HStack(spacing: 12) {
            if showConfirmation {
                Image(systemName: "checkmark")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
            } else {
                Text("Set Goal")
                    .font(.custom("Montserrat-SemiBold", size: 18))
                    .foregroundColor(.black)
            }
        }
    }
    
    private var confirmButtonBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(brandPrimary)
            .shadow(color: brandPrimary.opacity(0.4), radius: 12, y: 6)
    }
    
    private var cancelButton: some View {
        Button(action: dismissPicker) {
            Text("Cancel")
                .font(.custom("Inter-SemiBold", size: 16))
                .foregroundColor(.white.opacity(0.8))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
        }
    }
    
    // MARK: - Modal Background
    private var modalBackground: some View {
        RoundedRectangle(cornerRadius: 28)
            .fill(backgroundGradient)
            .overlay(modalBorder)
    }
    
    private var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(hex: "#0f0f0f"),
                Color(hex: "#080808")
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private var modalBorder: some View {
        RoundedRectangle(cornerRadius: 28)
            .stroke(Color.white.opacity(0.1), lineWidth: 1)
    }
    
    // MARK: - Gestures
    private var dismissDragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                if value.translation.height > 0 {
                    dragOffset = value.translation.height
                }
            }
            .onEnded { value in
                if value.translation.height > 100 {
                    dismissPicker()
                } else {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        dragOffset = 0
                    }
                }
            }
    }
    
    // MARK: - Helper Functions
    private func setupView() {
        selectedGoal = dailyGoal
        
        // Dismiss keyboard when goal picker appears
        dismissKeyboard()
        
        withAnimation(.spring(response: 1, dampingFraction: 0.8)) {
            animateAppear = true
        }
    }
    
    private func dismissPicker() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            showGoalPicker = false
        }
    }
    
    private func selectPresetGoal(_ steps: Int) {
        // Dismiss keyboard when selecting a goal
        dismissKeyboard()
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            selectedGoal = steps
        }
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    private func confirmGoal() {
        showConfirmation = true
        
        // Success haptic
        let successFeedback = UINotificationFeedbackGenerator()
        successFeedback.notificationOccurred(.success)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            dailyGoal = selectedGoal
            dismissPicker()
        }
    }
    
    private func progressForGoal(_ goal: Int) -> Double {
        return min(Double(goal) / 15000.0, 1.0)
    }
    
    // MARK: - Keyboard Dismissal
    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Goal Preset Model
struct GoalPreset {
    let steps: Int
    let title: String
    let description: String
    let color: Color
    let icon: String
}

// MARK: - Goal Preset Card
struct GoalPresetCard: View {
    let preset: GoalPreset
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            cardContent
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isSelected)
    }
    
    private var cardContent: some View {
        VStack(spacing: 12) {
            iconSection
            textContent
        }
        .frame(width: 120)
        .padding(.vertical, 16)
        .background(cardBackground)
        .shadow(color: shadowColor, radius: shadowRadius)
        .scaleEffect(isSelected ? 1.05 : 1.0)
    }
    
    private var iconSection: some View {
        ZStack {
            Circle()
                .fill(preset.color.opacity(isSelected ? 0.3 : 0.15))
                .frame(width: 48, height: 48)
            
            Image(systemName: preset.icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(preset.color)
        }
    }
    
    private var textContent: some View {
        VStack(spacing: 4) {
            Text("\(preset.steps)")
                .font(.custom("Montserrat-Bold", size: 18))
                .foregroundColor(.white)
            
            Text(preset.title)
                .font(.custom("Inter-SemiBold", size: 14))
                .foregroundColor(titleColor)
            
            Text(preset.description)
                .font(.custom("Inter-Regular", size: 12))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
        }
    }
    
    private var titleColor: Color {
        isSelected ? preset.color : .white.opacity(0.8)
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.white.opacity(isSelected ? 0.08 : 0.03))
            .overlay(cardBorder)
    }
    
    private var cardBorder: some View {
        RoundedRectangle(cornerRadius: 16)
            .stroke(
                isSelected ? preset.color.opacity(0.6) : Color.white.opacity(0.1),
                lineWidth: isSelected ? 2 : 1
            )
    }
    
    private var shadowColor: Color {
        isSelected ? preset.color.opacity(0.3) : Color.clear
    }
    
    private var shadowRadius: CGFloat {
        isSelected ? 8 : 0
    }
}

// MARK: - Goal Level Badge
struct GoalLevelBadge: View {
    let goal: Int
    
    private var goalLevel: (text: String, color: Color) {
        switch goal {
        case 3000...4900: return ("Getting Started", .green)
        case 5000...7000: return ("Recommended", Color(red: 0/255, green: 185/255, blue: 190/255))
        case 7001...10000: return ("Active", .orange)
        case 10001...12000: return ("Challenging", .red)
        case 12001...: return ("Elite", .purple)
        default: return ("Custom", .white)
        }
    }
    
    var body: some View {
        HStack(spacing: 8) {
            statusDot
            statusText
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(badgeBackground)
        .animation(.easeInOut(duration: 0.3), value: goal)
    }
    
    private var statusDot: some View {
        Circle()
            .fill(goalLevel.color)
            .frame(width: 8, height: 8)
    }
    
    private var statusText: some View {
        Text(goalLevel.text)
            .font(.custom("Inter-SemiBold", size: 14))
            .foregroundColor(goalLevel.color)
    }
    
    private var badgeBackground: some View {
        Capsule()
            .fill(goalLevel.color.opacity(0.15))
            .overlay(badgeBorder)
    }
    
    private var badgeBorder: some View {
        Capsule()
            .stroke(goalLevel.color.opacity(0.3), lineWidth: 1)
    }
}

// MARK: - Custom Slider
struct CustomSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    
    @State private var isDragging = false
    
    private let brandPrimary = Color(red: 0/255, green: 185/255, blue: 190/255)
    
    var body: some View {
        GeometryReader { geometry in
            let sliderWidth = geometry.size.width
            let thumbPosition = calculateThumbPosition(sliderWidth: sliderWidth)
            
            ZStack(alignment: .leading) {
                trackView
                progressView(width: thumbPosition)
                thumbView(position: thumbPosition, sliderWidth: sliderWidth)
            }
        }
        .frame(height: 24)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isDragging)
    }
    
    private var trackView: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(Color.white.opacity(0.2))
            .frame(height: 6)
    }
    
    private func progressView(width: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(progressGradient)
            .frame(width: width, height: 6)
    }
    
    private var progressGradient: LinearGradient {
        LinearGradient(
            colors: [brandPrimary, brandPrimary.opacity(0.8)],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    private func thumbView(position: CGFloat, sliderWidth: CGFloat) -> some View {
        Circle()
            .fill(brandPrimary)
            .frame(width: 24, height: 24)
            .overlay(thumbInner)
            .shadow(color: brandPrimary.opacity(0.4), radius: isDragging ? 8 : 4)
            .scaleEffect(isDragging ? 1.2 : 1.0)
            .offset(x: position - 12)
            .gesture(sliderDragGesture(sliderWidth: sliderWidth))
    }
    
    private var thumbInner: some View {
        Circle()
            .fill(Color.white)
            .frame(width: 12, height: 12)
    }
    
    private func calculateThumbPosition(sliderWidth: CGFloat) -> CGFloat {
        CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound)) * sliderWidth
    }
    
    private func sliderDragGesture(sliderWidth: CGFloat) -> some Gesture {
        DragGesture()
            .onChanged { gesture in
                isDragging = true
                updateSliderValue(gesture: gesture, sliderWidth: sliderWidth)
                
                // Light haptic feedback
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
            }
            .onEnded { _ in
                isDragging = false
            }
    }
    
    private func updateSliderValue(gesture: DragGesture.Value, sliderWidth: CGFloat) {
        let newPosition = max(0, min(sliderWidth, gesture.location.x))
        let percentage = newPosition / sliderWidth
        let newValue = range.lowerBound + percentage * (range.upperBound - range.lowerBound)
        let steppedValue = round(newValue / step) * step
        value = max(range.lowerBound, min(range.upperBound, steppedValue))
    }
}

// MARK: - Preview
struct GoalPickerView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            GoalPickerView(dailyGoal: .constant(6000), showGoalPicker: .constant(true))
        }
        .preferredColorScheme(.dark)
    }
}
