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
import TWExtensions

public struct AppTheme: Theme {
    public let colors: ThemeColors = AppColors()
    public let fonts: ThemeFonts = AppFonts()
    
    public init() { }
}

public struct AppColors: ThemeColors {
    public let background: UIColor = UIColor { trait in
        if trait.userInterfaceStyle == .dark {
            return UIColor(rgb: 0x1F2533)
        }
        return UIColor(rgb: 0xFFF2E7)
    }
    
    public let secondaryBackground: UIColor = UIColor { trait in
        if trait.userInterfaceStyle == .dark {
            return UIColor(rgb: 0x30384A)
        }
        return UIColor(rgb: 0xFFF6EE)
    }
    
    public let label: UIColor = UIColor { trait in
        if trait.userInterfaceStyle == .dark {
            return UIColor(rgb: 0xA2B7CB)
        }
        return UIColor(rgb: 0x735D4A)
    }
    
    public let secondaryLabel: UIColor = UIColor { trait in
        if trait.userInterfaceStyle == .dark {
            return UIColor(rgb: 0x6F7D8A)
        }
        return UIColor(rgb: 0xC0AF9F)
    }
    
    public let separator: UIColor = UIColor { trait in
        if trait.userInterfaceStyle == .dark {
            return UIColor(rgb: 0x2D384D)
        }
        return UIColor(rgb: 0xF1E1D3)
    }
    
    public let shadow: UIColor = UIColor { trait in
        if trait.userInterfaceStyle == .dark {
            return UIColor(rgb: 0x0)
        }
        return UIColor(rgb: 0x3A1B00)
    }
    
    public let weather: WeatherColors = AppWeatherColors()
    public let temperatures: TemperatureColors = AppTemperatureColors()
}

public struct AppWeatherColors: WeatherColors {
    public let rain: UIColor = UIColor { trait in
        if trait.userInterfaceStyle == .dark {
            return UIColor(rgb: 0x6FAEE9)
        }
        return UIColor(rgb: 0x67C1F3)
    }
    
    public let wind: UIColor = UIColor { trait in
        if trait.userInterfaceStyle == .dark {
            return UIColor(rgb: 0x727272)
        }
        return UIColor(rgb: 0x8D8D8D)
    }
    
    public let sun: UIColor = UIColor { trait in
        if trait.userInterfaceStyle == .dark {
            return UIColor(rgb: 0xFFB199)
        }
        return UIColor(rgb: 0xFF9776)
    }
    
    public let moon: UIColor = UIColor { trait in
        if trait.userInterfaceStyle == .dark {
            return UIColor(rgb: 0xFFDCA7)
        }
        return UIColor(rgb: 0xFFDEAC)
    }
    
    public let stars: UIColor = UIColor { trait in
        if trait.userInterfaceStyle == .dark {
            return UIColor(rgb: 0x6FAEE9)
        }
        return UIColor(rgb: 0xC1DDFE)
    }
    
    public let cloud: UIColor = UIColor { trait in
        if trait.userInterfaceStyle == .dark {
            return UIColor(rgb: 0x607596)
        }
        return UIColor(rgb: 0xE8D2BF)
    }
    
    public let bolt: UIColor = UIColor { trait in
        if trait.userInterfaceStyle == .dark {
            return UIColor(rgb: 0xFCE098)
        }
        return UIColor(rgb: 0xFFD390)
    }
    
    public let fog: UIColor = UIColor { trait in
        if trait.userInterfaceStyle == .dark {
            return UIColor(rgb: 0x8B8B8B)
        }
        return UIColor(rgb: 0xA9A9A9)
    }
    
    public let snow: UIColor = UIColor { trait in
        if trait.userInterfaceStyle == .dark {
            return UIColor(rgb: 0x8DBDE0)
        }
        return UIColor(rgb: 0x9DC7E7)
    }
}

public struct AppTemperatureColors: TemperatureColors {
    public let superHot: DynamicColor = DynamicColor(lightColor: UIColor(rgb: 0xE85E5E), darkColor: UIColor(rgb: 0xE85E5E))
    public let hot: DynamicColor = DynamicColor(lightColor: UIColor(rgb: 0xE4A80C), darkColor: UIColor(rgb: 0xE2C374))
    public let warm: DynamicColor = DynamicColor(lightColor: UIColor(rgb: 0x4DB958), darkColor: UIColor(rgb: 0x8BF896))
    public let neutral: DynamicColor = DynamicColor(lightColor: UIColor(rgb: 0x78B199), darkColor: UIColor(rgb: 0x90D6B8))
    public let zero: DynamicColor = DynamicColor(lightColor: UIColor(rgb: 0x39B4DB), darkColor: UIColor(rgb: 0x78C6DF))
    public let cold: DynamicColor = DynamicColor(lightColor: UIColor(rgb: 0x4696F5), darkColor: UIColor(rgb: 0x6A8FEF))
    public let superCold: DynamicColor = DynamicColor(lightColor: UIColor(rgb: 0x6764E7), darkColor: UIColor(rgb: 0x5956F9))
}

public struct AppFonts: ThemeFonts {
    
    private let iconsDuotone: ScaledFont
    private let iconsSolid: ScaledFont
    private let iconsLight: ScaledFont
    
    public init() {
        self.iconsDuotone = ScaledFont(fontName: "icons_duotone")
        self.iconsSolid = ScaledFont(fontName: "icons_solid")
        self.iconsLight = ScaledFont(fontName: "icons_light")
    }
    
    public func primary(style: UIFont.TextStyle) -> UIFont {
        if let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: style).withDesign(.rounded) {
            return UIFont(descriptor: descriptor, size: 0)
        }
        return UIFont.preferredFont(forTextStyle: style)
    }
    
    public func primaryBold(style: UIFont.TextStyle) -> UIFont {
        if let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: style).withDesign(.rounded)?.withSymbolicTraits(.traitBold) {
            return UIFont(descriptor: descriptor, size: 0)
        }
        return UIFont.preferredFont(forTextStyle: style)
    }
    
    public func primary(size: CGFloat) -> UIFont {
        if let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body).withDesign(.rounded) {
            return UIFont(descriptor: descriptor, size: size)
        }
        return UIFont.systemFont(ofSize: size)
    }
    
    public func primaryBold(size: CGFloat) -> UIFont {
        if let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body).withDesign(.rounded)?.withSymbolicTraits(.traitBold) {
            return UIFont(descriptor: descriptor, size: size)
        }
        return UIFont.systemFont(ofSize: size, weight: .bold)
    }
    
    public func iconLight(style: UIFont.TextStyle) -> UIFont {
        return self.iconsLight.font(forTextStyle: style)
    }
    
    public func iconSolid(style: UIFont.TextStyle) -> UIFont {
        return self.iconsSolid.font(forTextStyle: style)
    }
    
    public func iconDuotone(style: UIFont.TextStyle) -> UIFont {
        return self.iconsDuotone.font(forTextStyle: style)
    }
    
    public func iconLight(size: CGFloat) -> UIFont {
        return self.iconsLight.font(forSize: size)
    }
    
    public func iconSolid(size: CGFloat) -> UIFont {
        return self.iconsSolid.font(forSize: size)
    }
    
    public func iconDuotone(size: CGFloat) -> UIFont {
        return self.iconsDuotone.font(forSize: size)
    }
    
}
