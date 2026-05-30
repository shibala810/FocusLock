//
//  Volleyball.swift — uses the bundled ball.png asset.
//
//  The view keeps the same `size` / `spin` API as the previous
//  SwiftUI-drawn version so every caller continues to work unchanged.
//

import SwiftUI

struct Volleyball: View {
    var size: CGFloat = 120
    var spin: Bool = false
    @State private var angle: Double = 0

    var body: some View {
        Image("Volleyball")
            .resizable()
            .interpolation(.high)
            .scaledToFit()
            .frame(width: size, height: size)
            .rotationEffect(.degrees(angle))
            .onAppear { startSpin() }
            .onChange(of: spin) { _, _ in startSpin() }
    }

    private func startSpin() {
        guard spin else { angle = 0; return }
        withAnimation(.linear(duration: 22).repeatForever(autoreverses: false)) {
            angle = 360
        }
    }
}

#Preview {
    HStack {
        Volleyball(size: 180, spin: false)
        Volleyball(size: 120, spin: true)
        Volleyball(size: 60, spin: false)
    }
    .padding()
    .background(Color(hex: 0xFBE3E9))
}
