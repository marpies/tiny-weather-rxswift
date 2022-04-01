//
//  AppTheme.swift
//  TinyWeather
//
//  Created by Marcel Piešťanský.
//  Copyright © 2022 Marcel Piestansky. All rights reserved.
//  
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//  

import Foundation
import UIKit

struct AppTheme: Theme {
    let colors: ThemeColors = AppColors()
    let fonts: ThemeFonts = AppFonts()
}

struct AppColors: ThemeColors {
    let background: UIColor = UIColor { trait in
        if trait.userInterfaceStyle == .dark {
            return UIColor(rgb: 0x1F2533)
        }
        return UIColor(rgb: 0xFFF2E7)
    }
    
    let secondaryBackground: UIColor = UIColor { trait in
        if trait.userInterfaceStyle == .dark {
            return UIColor(rgb: 0x30384A)
        }
        return UIColor(rgb: 0xFFF6EE)
    }
    
    let label: UIColor = UIColor { trait in
        if trait.userInterfaceStyle == .dark {
            return UIColor(rgb: 0xA2B7CB)
        }
        return UIColor(rgb: 0x735D4A)
    }
    
    let secondaryLabel: UIColor = UIColor { trait in
        if trait.userInterfaceStyle == .dark {
            return UIColor(rgb: 0x6F7D8A)
        }
        return UIColor(rgb: 0xC0AF9F)
    }
    
    let separator: UIColor = UIColor { trait in
        if trait.userInterfaceStyle == .dark {
            return UIColor(rgb: 0x2D384D)
        }
        return UIColor(rgb: 0xF1E1D3)
    }
    
    let shadow: UIColor = UIColor { trait in
        if trait.userInterfaceStyle == .dark {
            return UIColor(rgb: 0x0)
        }
        return UIColor(rgb: 0x3A1B00)
    }
    
    let weather: WeatherColors = AppWeatherColors()
}

struct AppWeatherColors: WeatherColors {
    let rain: UIColor = UIColor { trait in
        if trait.userInterfaceStyle == .dark {
            return UIColor(rgb: 0x6FAEE9)
        }
        return UIColor(rgb: 0x67C1F3)
    }
    
    let wind: UIColor = UIColor { trait in
        if trait.userInterfaceStyle == .dark {
            return UIColor(rgb: 0x727272)
        }
        return UIColor(rgb: 0x8D8D8D)
    }
    
    let sun: UIColor = UIColor { trait in
        if trait.userInterfaceStyle == .dark {
            return UIColor(rgb: 0xFFB199)
        }
        return UIColor(rgb: 0xFF9776)
    }
    
    let moon: UIColor = UIColor { trait in
        if trait.userInterfaceStyle == .dark {
            return UIColor(rgb: 0xFFDCA7)
        }
        return UIColor(rgb: 0xFFDEAC)
    }
    
    let stars: UIColor = UIColor { trait in
        if trait.userInterfaceStyle == .dark {
            return UIColor(rgb: 0x6FAEE9)
        }
        return UIColor(rgb: 0xC1DDFE)
    }
    
    let cloud: UIColor = UIColor { trait in
        if trait.userInterfaceStyle == .dark {
            return UIColor(rgb: 0x607596)
        }
        return UIColor(rgb: 0xE8D2BF)
    }
    
    let bolt: UIColor = UIColor { trait in
        if trait.userInterfaceStyle == .dark {
            return UIColor(rgb: 0xFCE098)
        }
        return UIColor(rgb: 0xFFD390)
    }
    
    let fog: UIColor = UIColor { trait in
        if trait.userInterfaceStyle == .dark {
            return UIColor(rgb: 0x8B8B8B)
        }
        return UIColor(rgb: 0xA9A9A9)
    }
    
    let snow: UIColor = UIColor { trait in
        if trait.userInterfaceStyle == .dark {
            return UIColor(rgb: 0x8DBDE0)
        }
        return UIColor(rgb: 0x9DC7E7)
    }
}

struct AppFonts: ThemeFonts {
    
    private let iconsDuotone: ScaledFont
    private let iconsSolid: ScaledFont
    private let iconsLight: ScaledFont
    
    init() {
        self.iconsDuotone = ScaledFont(fontName: "icons_duotone")
        self.iconsSolid = ScaledFont(fontName: "icons_solid")
        self.iconsLight = ScaledFont(fontName: "icons_light")
    }
    
    func primary(style: UIFont.TextStyle) -> UIFont {
        if let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: style).withDesign(.rounded) {
            return UIFont(descriptor: descriptor, size: 0)
        }
        return UIFont.preferredFont(forTextStyle: style)
    }
    
    func primaryBold(style: UIFont.TextStyle) -> UIFont {
        if let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: style).withDesign(.rounded)?.withSymbolicTraits(.traitBold) {
            return UIFont(descriptor: descriptor, size: 0)
        }
        return UIFont.preferredFont(forTextStyle: style)
    }
    
    func primary(size: CGFloat) -> UIFont {
        if let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body).withDesign(.rounded) {
            return UIFont(descriptor: descriptor, size: size)
        }
        return UIFont.systemFont(ofSize: size)
    }
    
    func primaryBold(size: CGFloat) -> UIFont {
        if let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body).withDesign(.rounded)?.withSymbolicTraits(.traitBold) {
            return UIFont(descriptor: descriptor, size: size)
        }
        return UIFont.systemFont(ofSize: size, weight: .bold)
    }
    
    func iconLight(style: UIFont.TextStyle) -> UIFont {
        return self.iconsLight.font(forTextStyle: style)
    }
    
    func iconSolid(style: UIFont.TextStyle) -> UIFont {
        return self.iconsSolid.font(forTextStyle: style)
    }
    
    func iconDuotone(style: UIFont.TextStyle) -> UIFont {
        return self.iconsDuotone.font(forTextStyle: style)
    }
    
    func iconLight(size: CGFloat) -> UIFont {
        return self.iconsLight.font(forSize: size)
    }
    
    func iconSolid(size: CGFloat) -> UIFont {
        return self.iconsSolid.font(forSize: size)
    }
    
    func iconDuotone(size: CGFloat) -> UIFont {
        return self.iconsDuotone.font(forSize: size)
    }
    
}
