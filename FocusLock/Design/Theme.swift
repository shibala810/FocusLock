//
//  Theme.swift
//  FocusLock — design tokens (light "貓窩" + dark "專注結界")
//

import SwiftUI

// MARK: - Hex helper
extension Color {
    init(hex: UInt32, opacity: Double = 1) {
        let r = Double((hex >> 16) & 0xFF) / 255
        let g = Double((hex >> 8) & 0xFF) / 255
        let b = Double(hex & 0xFF) / 255
        self.init(.sRGB, red: r, green: g, blue: b, opacity: opacity)
    }
}

// MARK: - Palette
struct FLPalette {
    var bg, bgTop, bgBlob: Color
    var surface, surface2, surface3: Color
    var ink, inkSoft, inkFaint, hairline: Color
    var primary, primaryDeep, primarySoft, onPrimary: Color
    var blonde, hoodie, paw: Color
    var focus, focusSoft: Color
    var amber, amberSoft: Color
    var danger, dangerSoft: Color
    var ballCream, ballPink, ballDark: Color
    var cardShadow, cardShadowSmall, pop: Color
    var bezelChrome: Color

    static let light = FLPalette(
        bg:          Color(hex: 0xFBE3E9),
        bgTop:       Color(hex: 0xFDEFF2),
        bgBlob:      Color(hex: 0xFBD3DC),
        surface:     Color(hex: 0xFFFFFF),
        surface2:    Color(hex: 0xFFF4F7),
        surface3:    Color(hex: 0xFCE9EE),
        ink:         Color(hex: 0x4B2B35),
        inkSoft:     Color(hex: 0x8C6571),
        inkFaint:    Color(hex: 0xC0A0AA),
        hairline:    Color(hex: 0x4B2B35, opacity: 0.10),
        primary:     Color(hex: 0xED7B92),
        primaryDeep: Color(hex: 0xD85872),
        primarySoft: Color(hex: 0xFBDCE3),
        onPrimary:   Color(hex: 0xFFFFFF),
        blonde:      Color(hex: 0xE8B259),
        hoodie:      Color(hex: 0xCF5A53),
        paw:         Color(hex: 0xE893A5),
        focus:       Color(hex: 0x5FB58A),
        focusSoft:   Color(hex: 0xDBF0E5),
        amber:       Color(hex: 0xE8A23F),
        amberSoft:   Color(hex: 0xFBEACB),
        danger:      Color(hex: 0xE15B57),
        dangerSoft:  Color(hex: 0xFADEDC),
        ballCream:   Color(hex: 0xFBF1E4),
        ballPink:    Color(hex: 0xED7B92),
        ballDark:    Color(hex: 0x3C2A30),
        cardShadow:      Color(hex: 0xD85872, opacity: 0.34),
        cardShadowSmall: Color(hex: 0xD85872, opacity: 0.28),
        pop:             Color(hex: 0xD85872, opacity: 0.45),
        bezelChrome:     Color(hex: 0x2A1F2A)
    )

    static let dark = FLPalette(
        bg:          Color(hex: 0x1B1521),
        bgTop:       Color(hex: 0x241A2D),
        bgBlob:      Color(hex: 0x2C2036),
        surface:     Color(hex: 0x2A2031),
        surface2:    Color(hex: 0x322640),
        surface3:    Color(hex: 0x3A2C49),
        ink:         Color(hex: 0xF6E9EF),
        inkSoft:     Color(hex: 0xC4AAB7),
        inkFaint:    Color(hex: 0x8A7283),
        hairline:    Color.white.opacity(0.09),
        primary:     Color(hex: 0xF38BA1),
        primaryDeep: Color(hex: 0xEE6E89),
        primarySoft: Color(hex: 0x46303C),
        onPrimary:   Color(hex: 0x2A1620),
        blonde:      Color(hex: 0xEFC06A),
        hoodie:      Color(hex: 0xD96A63),
        paw:         Color(hex: 0xC77E91),
        focus:       Color(hex: 0x6FC79A),
        focusSoft:   Color(hex: 0x243A30),
        amber:       Color(hex: 0xF0B257),
        amberSoft:   Color(hex: 0x3C3020),
        danger:      Color(hex: 0xF0726C),
        dangerSoft:  Color(hex: 0x3D2426),
        ballCream:   Color(hex: 0xF3E6D6),
        ballPink:    Color(hex: 0xF38BA1),
        ballDark:    Color(hex: 0x221820),
        cardShadow:      Color.black.opacity(0.60),
        cardShadowSmall: Color.black.opacity(0.55),
        pop:             Color.black.opacity(0.70),
        bezelChrome:     Color(hex: 0x0B0810)
    )
}

// MARK: - Environment
private struct FLPaletteKey: EnvironmentKey {
    static let defaultValue: FLPalette = .light
}

extension EnvironmentValues {
    var fl: FLPalette {
        get { self[FLPaletteKey.self] }
        set { self[FLPaletteKey.self] = newValue }
    }
}

// MARK: - View modifier
struct FLThemeModifier: ViewModifier {
    @Environment(\.colorScheme) private var cs
    @Environment(AppState.self) private var app

    func body(content: Content) -> some View {
        let useDark: Bool = {
            switch app.theme {
            case .light: return false
            case .dark:  return true
            case .system: return cs == .dark
            }
        }()
        let palette: FLPalette = useDark ? .dark : .light
        content.environment(\.fl, palette)
    }
}

extension View {
    func flTheme() -> some View { modifier(FLThemeModifier()) }
}

// MARK: - Shadow presets matching --card-sh / --card-sh-sm / --pop
struct FLShadow {
    static func card(_ fl: FLPalette) -> some ViewModifier {
        ShadowMod(color: fl.cardShadow, radius: 14, y: 10)
    }
    static func cardSmall(_ fl: FLPalette) -> some ViewModifier {
        ShadowMod(color: fl.cardShadowSmall, radius: 7, y: 4)
    }
    static func pop(_ fl: FLPalette) -> some ViewModifier {
        ShadowMod(color: fl.pop, radius: 25, y: 18)
    }
}

struct ShadowMod: ViewModifier {
    let color: Color; let radius: CGFloat; let y: CGFloat
    func body(content: Content) -> some View {
        content.shadow(color: color, radius: radius, x: 0, y: y)
    }
}
