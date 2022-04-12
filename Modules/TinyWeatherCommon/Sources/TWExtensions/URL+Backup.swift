//
//  URL+Backup.swift
//  TinyWeather
//
//  Created by Marcel Piešťanský.
//  Copyright © 2022 Marcel Piestansky. All rights reserved.
//  
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//  

import Foundation

public extension URL {
    
    mutating func excludeFromBackup() {
        do {
            var resourceValues: URLResourceValues = URLResourceValues()
            resourceValues.isExcludedFromBackup = true
            try setResourceValues(resourceValues)
        } catch {
            assert(false, "ExcludeFromBackup error: \(error)")
        }
    }
    
}
