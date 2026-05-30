//
//  AppCatalog.swift  — mock category/app list for the Block screen
//  (Real FamilyActivityPicker tokens are opaque; this is for visual demo.)
//

import SwiftUI

struct CatalogApp: Identifiable, Hashable {
    let id = UUID()
    let name: String
    var on: Bool
}

struct CatalogCategory: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let color: Color
    var apps: [CatalogApp]
}

extension CatalogCategory {
    static let samples: [CatalogCategory] = [
        CatalogCategory(name: "社群", color: Color(hex: 0xE07B92), apps: [
            CatalogApp(name: "Instagram", on: true),
            CatalogApp(name: "Threads",   on: true),
            CatalogApp(name: "X",         on: false),
            CatalogApp(name: "Facebook",  on: false),
        ]),
        CatalogCategory(name: "短影音", color: Color(hex: 0x7FA7E6), apps: [
            CatalogApp(name: "TikTok",  on: true),
            CatalogApp(name: "YouTube", on: true),
            CatalogApp(name: "Reels",   on: true),
        ]),
        CatalogCategory(name: "遊戲", color: Color(hex: 0x6FBE9C), apps: [
            CatalogApp(name: "原神",       on: true),
            CatalogApp(name: "傳說對決",   on: false),
            CatalogApp(name: "Candy Crush", on: false),
        ]),
    ]
}
