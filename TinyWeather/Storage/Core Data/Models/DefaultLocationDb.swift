//
//  DefaultLocationDb.swift
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

class DefaultLocationDb: NSManagedObject {
    
    enum Attributes {
        static let entityName: String = "DefaultLocationDb"
    }
    
    struct Model: WeatherLocation {
        let name: String
        let state: String?
        let country: String
        let lon: Double
        let lat: Double
    }

    @NSManaged var name: String
    @NSManaged var country: String
    @NSManaged var state: String?
    @NSManaged var lon: Double
    @NSManaged var lat: Double
    
    var model: DefaultLocationDb.Model {
        return DefaultLocationDb.Model(name: self.name, state: self.state, country: self.country, lon: self.lon, lat: self.lat)
    }

}
