//
//  SubjectIcon.swift
//

import SwiftUI

struct SubjectIcon: View {
    let subject: Subject
    var size: CGFloat = 38
    var body: some View {
        RoundedRectangle(cornerRadius: size * 0.32, style: .continuous)
            .fill(subject.soft)
            .frame(width: size, height: size)
            .overlay(
                Text(subject.glyph)
                    .font(.system(size: size * 0.5, weight: .heavy))
                    .foregroundStyle(subject.color)
            )
    }
}
