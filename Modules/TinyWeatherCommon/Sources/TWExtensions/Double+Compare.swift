//
//  Double+Compare.swift
//  TinyWeather
//
//  Created by Marcel Piešťanský.
//  Copyright © 2022 Marcel Piestansky. All rights reserved.
//
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//

import Foundation

public extension Double {
    
    func isNearEqual(to other: Double, epsilon: Double = 0.0001) -> Bool {
        let min: Double = other - epsilon
        let max: Double = other + epsilon
        return (self > min) && (self < max)
    }
    
}
