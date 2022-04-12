//
//  FontIcon.swift
//  TinyWeather
//
//  Created by Marcel Piešťanský.
//  Copyright © 2022 Marcel Piestansky. All rights reserved.
//  
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//  

import Foundation

public enum FontIcon: UInt32 {
    case clock = 0xf017
    case cloud = 0xf0c2
    case cloudDrizzle = 0xf738
    case cloudHail = 0xf739
    case cloudHailMixed = 0xf73a
    case cloudMoon = 0xf6c3
    case cloudMoonRain = 0xf73c
    case cloudRain = 0xf73d
    case cloudRainbow = 0xf73e
    case cloudShowers = 0xf73f
    case cloudShowersHeavy = 0xf740
    case cloudSleet = 0xf741
    case cloudSnow = 0xf742
    case cloudSun = 0xf6c4
    case cloudSunRain = 0xf743
    case clouds = 0xf744
    case cloudsMoon = 0xf745
    case cloudsSun = 0xf746
    case fog = 0xf74e
    case handPointUp = 0xf0a6
    case handPointer = 0xf25a
    case heart = 0xf004
    case location = 0xf601
    case locationArrow = 0xf124
    case moonCloud = 0xf754
    case moonStars = 0xf755
    case raindrops = 0xf75c
    case search = 0xf002
    case searchLocation = 0xf689
    case smog = 0xf75f
    case snowBlowing = 0xf761
    case snowflake = 0xf2dc
    case snowflakes = 0xf7cf
    case sun = 0xf185
    case sunCloud = 0xf763
    case sunHaze = 0xf765
    case sunrise = 0xf766
    case sunset = 0xf767
    case thunderstorm = 0xf76c
    case thunderstormMoon = 0xf76d
    case thunderstormSun = 0xf76e
    case wind = 0xf72e
    
    public var primary: String {
        let scalar: UnicodeScalar = UnicodeScalar(self.rawValue)!
        return scalar.escaped(asASCII: false)
    }
    
    public var secondary: String {
        let scalar: UnicodeScalar = UnicodeScalar(0x100000 | self.rawValue)!
        return scalar.escaped(asASCII: false)
    }
}
