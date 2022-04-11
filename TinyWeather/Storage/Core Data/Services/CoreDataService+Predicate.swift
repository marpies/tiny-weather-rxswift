//
//  CoreDataService+Predicate.swift
//  TinyWeather
//
//  Created by Marcel Piešťanský.
//  Copyright © 2022 Marcel Piestansky. All rights reserved.
//  
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//  

import Foundation

extension CoreDataService {
    
    func getPredicate(latitude: Double, longitude: Double) -> NSPredicate {
        let e: Double = 0.0001
        return NSPredicate(format: "(lat > %lf AND lat < %lf) AND (lon > %lf AND lon < %lf)", latitude - e, latitude + e, longitude - e, longitude + e)
    }
    
}
