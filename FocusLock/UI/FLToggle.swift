//
//  FLToggle.swift — custom Switch
//

import SwiftUI

struct FLToggle: View {
    @Binding var isOn: Bool
    var color: Color = .green
    @Environment(\.fl) private var fl

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.7)) {
                isOn.toggle()
            }
        } label: {
            ZStack(alignment: isOn ? .trailing : .leading) {
                Capsule().fill(isOn ? color : fl.surface3)
                    .frame(width: 50, height: 30)
                Circle().fill(.white)
                    .frame(width: 24, height: 24)
                    .shadow(color: .black.opacity(0.2), radius: 2.5, y: 1)
                    .padding(.horizontal, 3)
            }
        }
        .buttonStyle(.plain)
    }
}
