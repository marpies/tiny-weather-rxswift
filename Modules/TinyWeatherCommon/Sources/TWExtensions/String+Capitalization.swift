//
//  String+Capitalization.swift
//  TinyWeather
//
//  Created by Marcel Piešťanský.
//  Copyright © 2022 Marcel Piestansky. All rights reserved.
//  
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//  

import Foundation

public extension String {
    
    func capitalizeFirstLetter() -> String {
        return self.prefix(1).uppercased() + self.dropFirst().lowercased()
    }
    
}
