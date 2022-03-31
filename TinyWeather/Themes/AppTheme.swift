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
