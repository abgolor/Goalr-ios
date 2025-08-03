import SwiftUI

struct SplashView: View {
    @StateObject var viewModel: GoalrViewModel
    @State private var isActive = false
    @State private var logoScale: CGFloat = 0.5
    @State private var logoRotation: Double = 0
    @State private var opacity: Double = 0.0
    @State private var pulse = false
    @State private var showParticles = false
    @State private var backgroundOffset: CGFloat = 0
    
    private let brandPrimary = Color(red: 0/255, green: 185/255, blue: 190/255)
    private let brandSecondary = Color(red: 0/255, green: 150/255, blue: 155/255)

    var body: some View {
        ZStack {
            // MARK: - Animated Background
            LinearGradient(
                colors: [
                    Color("#000000"),
                    Color("#0a0a0a"),
                    Color("#080808"),
                    Color("#000000")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .offset(x: backgroundOffset)
            .animation(.easeInOut(duration: 8).repeatForever(autoreverses: true), value: backgroundOffset)
            
            // MARK: - Floating Orbs
            ForEach(0..<5) { index in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                brandPrimary.opacity(0.1),
                                brandSecondary.opacity(0.05),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 10,
                            endRadius: 100
                        )
                    )
                    .frame(width: CGFloat(60 + index * 40), height: CGFloat(60 + index * 40))
                    .offset(
                        x: CGFloat(cos(Double(index) * 2)) * 150,
                        y: CGFloat(sin(Double(index) * 1.5)) * 200
                    )
                    .opacity(pulse ? 0.3 : 0.1)
                    .blur(radius: 40)
                    .animation(
                        .easeInOut(duration: Double(3 + index))
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.5),
                        value: pulse
                    )
            }
            
            // MARK: - Main Content
            VStack(spacing: 0) {
                Spacer()
                
                // MARK: - Logo Section
                ZStack {
                    // Outer Glow Ring
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [brandPrimary.opacity(0.3), brandSecondary.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                        .frame(width: 180, height: 180)
                        .scaleEffect(pulse ? 1.2 : 1.0)
                        .opacity(pulse ? 0.3 : 0.6)
                    
                    // Inner Rotating Ring
                    Circle()
                        .trim(from: 0, to: 0.8)
                        .stroke(
                            AngularGradient(
                                colors: [brandPrimary, brandSecondary, brandPrimary.opacity(0.3)],
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 3, lineCap: .round)
                        )
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(logoRotation))
                    
                    // App Icon/Logo
                    VStack(spacing: 8) {
                        
                        Image("goalr_logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .shadow(color: brandPrimary.opacity(0.8), radius: 15)
                    }
                }
                .scaleEffect(logoScale)
                .opacity(opacity)
                
                Spacer().frame(height: 60)
                
                // MARK: - Brand Text
                VStack(spacing: 16) {
                    Text("Goalr")
                        .font(.custom("Montserrat-ExtraBold", size: 56))
                        .foregroundColor(.white)
                        .shadow(color: brandPrimary.opacity(0.6), radius: 20)
                        .opacity(opacity)
                        .scaleEffect(logoScale * 0.9)
                    
                    Text("Greatness is Earned")
                        .font(.custom("Inter-Medium", size: 18))
                        .foregroundColor(.white.opacity(0.8))
                        .italic()
                        .opacity(opacity * 0.8)
                        .scaleEffect(logoScale * 0.8)
                }
                
                Spacer()
                
                // MARK: - Loading Indicator
                VStack(spacing: 20) {
                    // Animated Dots
                    HStack(spacing: 8) {
                        ForEach(0..<3) { index in
                            Circle()
                                .fill(brandPrimary)
                                .frame(width: 8, height: 8)
                                .scaleEffect(pulse ? 1.2 : 0.8)
                                .opacity(pulse ? 1.0 : 0.5)
                                .animation(
                                    .easeInOut(duration: 0.8)
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(index) * 0.2),
                                    value: pulse
                                )
                        }
                    }
                    
                    Text("Preparing your journey...")
                        .font(.custom("Inter-Regular", size: 14))
                        .foregroundColor(.white.opacity(0.6))
                        .opacity(opacity * 0.7)
                }
                .padding(.bottom, 60)
            }
            
            // MARK: - Particle Effects
            if showParticles {
                ForEach(0..<20) { index in
                    Circle()
                        .fill(brandPrimary.opacity(0.6))
                        .frame(width: 3, height: 3)
                        .offset(
                            x: CGFloat.random(in: -200...200),
                            y: CGFloat.random(in: -400...400)
                        )
                        .opacity(showParticles ? 0 : 1)
                        .scaleEffect(showParticles ? 2 : 0.5)
                        .animation(
                            .easeOut(duration: Double.random(in: 1...3))
                            .delay(Double(index) * 0.1),
                            value: showParticles
                        )
                }
            }
        }
        .onAppear {
            startAnimations()
        }
        .fullScreenCover(isPresented: .constant(viewModel.user == nil && isActive)) {
            RegistrationView(viewModel: viewModel)
        }
    }
    
    // MARK: - Animation Sequence
    private func startAnimations() {
        // Start background animation
        backgroundOffset = 20
        
        // Start pulse
        pulse = true
        
        // Logo entrance animation
        withAnimation(.spring(response: 1.2, dampingFraction: 0.7).delay(0.3)) {
            logoScale = 1.0
            opacity = 1.0
        }
        
        // Start logo rotation
        withAnimation(.linear(duration: 10).repeatForever(autoreverses: false).delay(0.5)) {
            logoRotation = 360
        }
        
        // Show particles
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showParticles = true
        }
        
        // Navigate to registration after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            withAnimation(.easeInOut(duration: 0.8)) {
                isActive = true
            }
        }
    }
}

// MARK: - Preview
struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView(viewModel: GoalrViewModel())
            .preferredColorScheme(.dark)
    }
}
