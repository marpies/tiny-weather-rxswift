//
//  WeatherLocationDb.swift
//  TinyWeather
//
//  Created by Marcel Piešťanský.
//  Copyright © 2022 Marcel Piestansky. All rights reserved.
//  
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//  

import Foundation
import CoreData

class WeatherLocationDb: NSManagedObject {
    
    enum Attributes {
        static let entityName: String = "WeatherLocationDb"
    }
    
    struct Model: WeatherLocation {
        let name: String
        let state: String?
        let country: String
        let lon: Double
        let lat: Double
        let isDefault: Bool
    }

    @NSManaged var name: String
    @NSManaged var country: String
    @NSManaged var state: String?
    @NSManaged var lon: Double
    @NSManaged var lat: Double
    @NSManaged var isDefault: Bool
    @NSManaged var weather: LocationWeatherDb?
    
    var model: WeatherLocationDb.Model {
        return WeatherLocationDb.Model(name: name, state: state, country: country, lon: lon, lat: lat, isDefault: isDefault)
    }

}
