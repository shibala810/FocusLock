//
//  FLStepper.swift
//

import SwiftUI

struct FLStepper: View {
    @Binding var value: Int
    var range: ClosedRange<Int> = 0...10
    var step: Int = 1
    var suffix: String = ""
    @Environment(\.fl) private var fl

    var body: some View {
        HStack(spacing: 10) {
            btn("−") { value = max(range.lowerBound, value - step) } disabled: { value <= range.lowerBound }
            Text("\(value)\(suffix)")
                .font(.system(size: 17, weight: .heavy).monospacedDigit())
                .foregroundStyle(fl.ink)
                .frame(minWidth: 52)
            btn("+") { value = min(range.upperBound, value + step) } disabled: { value >= range.upperBound }
        }
    }

    @ViewBuilder
    private func btn(_ label: String, action: @escaping () -> Void,
                     disabled: () -> Bool) -> some View {
        let isDisabled = disabled()
        Button(action: action) {
            Text(label)
                .font(.system(size: 20, weight: .heavy))
                .foregroundStyle(isDisabled ? fl.inkFaint : fl.primaryDeep)
                .frame(width: 34, height: 34)
                .background(Capsule().fill(fl.surface3))
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }
}
