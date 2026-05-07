//
//  SplashView.swift
//  ConnectIn
//

import SwiftUI

struct SplashView: View {
    @State private var isPulsing = false

    var body: some View {
        splashContent
        .onAppear {
            isPulsing = true
        }
    }

    private var splashContent: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "052259"), Color(hex: "0A3066")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 12) {
                Image(systemName: "person.2.fill")
                    .font(.system(size: 72, weight: .bold))
                    .foregroundStyle(.white)
                    .scaleEffect(isPulsing ? 1.08 : 0.92)
                    .animation(
                        .easeInOut(duration: 1.2).repeatForever(autoreverses: true),
                        value: isPulsing
                    )

                Text("ConnectIn")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)

                Text("Find Your Guide")
                    .font(.caption)
                    .foregroundStyle(.cyan)
            }
        }
    }
}

#Preview {
    SplashView()
}
