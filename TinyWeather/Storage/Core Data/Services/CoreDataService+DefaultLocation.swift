//
//  CoreDataService+DefaultLocation.swift
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
import RxSwift

extension CoreDataService: DefaultLocationStorageManaging {
    
    var defaultLocation: Single<WeatherLocation?> {
        return Single.create { single in
            self.backgroundContext.performWith { ctx in
                let request = NSFetchRequest<DefaultLocationDb>(entityName: DefaultLocationDb.Attributes.entityName)
                request.fetchLimit = 1
                
                do {
                    let results: [DefaultLocationDb] = try ctx.fetch(request)
                    let model: DefaultLocationDb.Model? = results.first?.model
                    
                    DispatchQueue.main.async {
                        single(.success(model))
                    }
                } catch {
                    DispatchQueue.main.async {
                        single(.success(nil))
                    }
                }
            }
            return Disposables.create()
        }
    }
    
    func saveDefaultLocation(_ location: WeatherLocation) {
        self.backgroundContext.performWith { ctx in
            let request = NSFetchRequest<DefaultLocationDb>(entityName: DefaultLocationDb.Attributes.entityName)
            request.fetchLimit = 1
            
            do {
                let results: [DefaultLocationDb] = try ctx.fetch(request)
                
                // Update existing model
                if let model = results.first {
                    model.name = location.name
                    model.country = location.country
                    model.state = location.state
                    model.lon = location.lon
                    model.lat = location.lat
                }
                // Create a new model
                else {
                    let model: DefaultLocationDb = DefaultLocationDb(context: ctx)
                    model.name = location.name
                    model.country = location.country
                    model.state = location.state
                    model.lon = location.lon
                    model.lat = location.lat
                }
                
                try ctx.save()
            } catch {
                // Ignored
                print("Error saving default location: \(error)")
            }
        }
    }
    
}
