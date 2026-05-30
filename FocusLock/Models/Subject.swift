//
//  Subject.swift
//

import SwiftUI

enum Subject: String, CaseIterable, Codable, Hashable, Identifiable {
    case math = "數學"
    case english = "英文"
    case chinese = "國文"
    case history = "歷史"

    var id: String { rawValue }

    var glyph: String {
        switch self {
        case .math:    return "÷"
        case .english: return "A"
        case .chinese: return "文"
        case .history: return "卷"
        }
    }
    var color: Color {
        switch self {
        case .math:    return Color(hex: 0x7FA7E6)
        case .english: return Color(hex: 0x6FBE9C)
        case .chinese: return Color(hex: 0xE07B92)
        case .history: return Color(hex: 0xE0A24C)
        }
    }
    var soft: Color {
        switch self {
        case .math:    return Color(hex: 0xE2ECFB)
        case .english: return Color(hex: 0xDCF1E8)
        case .chinese: return Color(hex: 0xFBDDE4)
        case .history: return Color(hex: 0xFAEDD3)
        }
    }
}
