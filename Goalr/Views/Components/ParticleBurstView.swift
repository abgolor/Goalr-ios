//
//  ParticleBurstView.swift
//  Goalr
//
//  Created by Golor Abraham AjiriOghene on 30/07/2025.
//


import SwiftUI

// MARK: - Enhanced Particle Burst View
struct ParticleBurstView: View {
    let color: Color
    @State private var animate = false
    
    var body: some View {
        ZStack {
            ForEach(0..<12) { index in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [color, color.opacity(0.3), Color.clear],
                            center: .center,
                            startRadius: 2,
                            endRadius: 8
                        )
                    )
                    .frame(width: 8, height: 8)
                    .offset(y: animate ? -80 : -40)
                    .rotationEffect(.degrees(Double(index) * 30))
                    .opacity(animate ? 0 : 1)
                    .scaleEffect(animate ? 2 : 0.5)
            }
            
            // Central burst
            Circle()
                .fill(
                    RadialGradient(
                        colors: [color.opacity(0.8), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 60
                    )
                )
                .frame(width: 120, height: 120)
                .opacity(animate ? 0 : 0.6)
                .scaleEffect(animate ? 2 : 0)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 2.0)) {
                animate = true
            }
        }
    }
}


struct ParticleBurstView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            ParticleBurstView(color: .cyan)
        }
        .preferredColorScheme(.dark)
    }
}
