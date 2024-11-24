//
//  ColorView.swift
//  ContainerValues
//
//  Created by 今末 翔太 on 2024/10/22.
//

import SwiftUI

struct ColorView: View {
    let colors: [ColorPalette]
    
    init(colors: [ColorPalette] = ColorPalette.allCases) {
        self.colors = colors
    }
    
    var body: some View {
        ColorBoard {
            Section("Red") {
                Rectangle()
            }
            .colorType(ColorType.red)
            .showColors(colors.filter({ $0.colorType == ColorType.red }))
            
            Section("Blue") {
                Rectangle()
            }
            .colorType(ColorType.blue)
            
            Section("Green") {
                Rectangle()
            }
            .colorType(ColorType.green)
            .isHidden(true)
        }
    }
}

extension ContainerValues {
    @Entry var isHidden: Bool = false
    @Entry var showColors: [ColorPalette] = ColorPalette.allCases
    @Entry var colorType: ColorType?
}

extension View {
    func isHidden(_ isHidden: Bool) -> some View {
        containerValue(\.isHidden, isHidden)
    }
    
    func showColors(_ colors: [ColorPalette]) -> some View {
        containerValue(\.showColors, colors)
    }
    
    func colorType(_ type: ColorType) -> some View {
        containerValue(\.colorType, type)
    }
}

struct ColorBoard<Content: View>: View {
    @ViewBuilder var content: Content
    
    var body: some View {
        ScrollView {
            ForEach(sections: content) { section in
                if !section.containerValues.isHidden {
                    VStack(alignment: .leading) {
                        let colorType = section.containerValues.colorType
                        ColorHeader(
                            description: colorType?.description,
                            hex: colorType?.hex
                        ) { section.header }
                        
                        ColorContent { section.content }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
    }
}

struct ColorHeader<Content: View>: View {
    let description: String?
    let hex: String?
    @ViewBuilder var content: Content
    
    var body: some View {
        HStack {
            if let hex = hex, let color = Color(hex: hex) {
                Rectangle()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(color)
            } else {
                EmptyView()
                    .frame(width: 20, height: 20)
            }
            
            VStack(alignment: .leading) {
                HStack {
                    content
                        .bold()
                        .font(.title3)
                    
                    Text(hex ?? "")
                        .bold()
                        .font(.title3)
                }
                
                if let description = description {
                    Text(description)
                        .font(.caption)
                }
            }
        }
    }
}

struct ColorContent<Content: View>: View {
    @ViewBuilder var content: Content
    
    var body: some View {
        Group(subviews: content) { subviews in
            let _ = print(subviews.first?.containerValues.showColors)
            ForEach(subviews: subviews) { subview in
                let colorType = subview.containerValues.colorType
                let showColors = subview.containerValues.showColors.filter {
                    $0.colorType == colorType
                }
                
                ForEach(showColors) { color in
                    ColorCard(colorPalette: color) {
                        subview
                    }
                }
                
            }
        }
    }
}

struct ColorCard<Content: View>: View {
    let colorPalette: ColorPalette
    @ViewBuilder var content: Content
    
    @State private var isShowName: Bool = false
    
    var body: some View {
        HStack(spacing: 40) {
            if let color = Color(hex: colorPalette.hex) {
                Button {
                    isShowName.toggle()
                } label: {
                    ZStack(alignment: .center) {
                        content
                            .frame(height: 60)
                            .foregroundStyle(color)
                        Text(isShowName ? colorPalette.name : colorPalette.hex)
                            .tint(.white)
                    }
                }
            } else {
                EmptyView()
            }
        }
    }
}

enum ColorType: String, CaseIterable, Identifiable {
    case red = "Red"
    case blue = "Blue"
    case green = "Green"
    
    var description: String {
        switch self {
            case .red:
                "鮮やかな赤/光の三原色のひとつ"
            case .blue:
                "鮮やかな青/光の三原色のひとつ"
            case .green:
                "鮮やかな緑/光の三原色のひとつ。grass（草）と同じ語源"
        }
    }
    
    var name: String {
        switch self {
            case .red: "レッド"
            case .blue: "ブルー"
            case .green: "グリーン"
        }
    }
    
    var hex: String {
        switch self {
            case .red: "#E8383D"
            case .blue: "#0075C2"
            case .green: "#00A760"
        }
    }
    
    var id: Self { self }
}

enum ColorPalette: CaseIterable, Identifiable {
    case vermilion
    case wineRed
    case scarlet
    
    case aquaMarine
    case indigo
    case lapisLazuli
    
    case appleGreen
    case cobaltGreen
    case oliveGreen
    
    var name: String {
        switch self {
            case .vermilion: "ヴァーミリオン"
            case .wineRed: "ワインレッド"
            case .scarlet: "スカーレット"
            case .aquaMarine: "アクアマリン"
            case .indigo: "インディゴ"
            case .lapisLazuli: "ラピスラズリ"
            case .appleGreen: "アップルグリーン"
            case .cobaltGreen: "コバルトグリーン"
            case .oliveGreen: "オリーブグリーン"
        }
    }
    
    var hex: String {
        switch self {
            case .vermilion: "#E34234"
            case .wineRed: "#722F37"
            case .scarlet: "#FF2400"
            case .aquaMarine: "#006F86"
            case .indigo: "#074770"
            case .lapisLazuli: "#426AB3"
            case .appleGreen: "#96C78C"
            case .cobaltGreen: "#40BA8D"
            case .oliveGreen: "#576128"
        }
    }
    
    var colorType: ColorType {
        switch self {
            case .vermilion, .wineRed, .scarlet: .red
            case .aquaMarine, .indigo, .lapisLazuli: .blue
            case .appleGreen, .cobaltGreen, .oliveGreen: .green
        }
    }
    
    var id: Self { self }
}

extension Color {
    /// create new object with hex string
    init?(hex: String, opacity: Double = 1.0) {
        // delete "#" prefix
        let hexNorm = hex.hasPrefix("#") ? String(hex.dropFirst(1)) : hex
        
        // scan each byte of RGB respectively
        let scanner = Scanner(string: hexNorm)
        var color: UInt64 = 0
        if scanner.scanHexInt64(&color) {
            let red = CGFloat((color & 0xFF0000) >> 16) / 255.0
            let green = CGFloat((color & 0x00FF00) >> 8) / 255.0
            let blue = CGFloat(color & 0x0000FF) / 255.0
            self.init(red: red, green: green, blue: blue, opacity: opacity)
        } else {
            // invalid format
            return nil
        }
    }
}
