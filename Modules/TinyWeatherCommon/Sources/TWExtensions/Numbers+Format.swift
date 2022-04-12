//
//  Numbers+Format.swift
//  TinyWeather
//
//  Created by Marcel Piešťanský.
//  Copyright © 2022 Marcel Piestansky. All rights reserved.
//  
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//  

import Foundation

public extension Int {
    
    func format(_ f: String) -> String {
        return String(format: "%\(f)d", self)
    }
    
}

public extension Double {
    
    func format(_ f: String, dropZero: Bool = false) -> String {
        let value = String(format: "%\(f)f", self)
        if dropZero && value.starts(with: "0.") {
            return String(value[value.index(after: value.startIndex)..<value.endIndex])
        }
        return value
    }
    
}

public extension Float {
    
    func format(_ f: String, dropZero: Bool = false) -> String {
        let value = String(format: "%\(f)f", self)
        if dropZero && value.starts(with: "0.") {
            return String(value[value.index(after: value.startIndex)..<value.endIndex])
        }
        return value
    }
    
}
