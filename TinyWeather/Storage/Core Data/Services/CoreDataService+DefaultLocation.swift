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
                let request = NSFetchRequest<WeatherLocationDb>(entityName: WeatherLocationDb.Attributes.entityName)
                request.predicate = NSPredicate(format: "isDefault == true")
                request.fetchLimit = 1
                
                do {
                    let results: [WeatherLocationDb] = try ctx.fetch(request)
                    let model: WeatherLocationDb.Model? = results.first?.model
                    
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
            do {
                // Remove default flag from existing default location model
                try self.clearDefaultLocation(context: ctx)
                
                // Set the default flag on the new location
                let request = NSFetchRequest<WeatherLocationDb>(entityName: WeatherLocationDb.Attributes.entityName)
                request.predicate = self.getPredicate(latitude: location.lat, longitude: location.lon)
                request.fetchLimit = 1
                
                let results: [WeatherLocationDb] = try ctx.fetch(request)
                
                // Update existing model or create a new one
                let model: WeatherLocationDb = results.first ?? WeatherLocationDb(context: ctx)
                
                model.name = location.name
                model.country = location.country
                model.state = location.state
                model.lon = location.lon
                model.lat = location.lat
                model.isDefault = true
                
                try ctx.save()
            } catch {
                // Ignored
                print("Error saving default location: \(error)")
            }
        }
    }
    
    //
    // MARK: - Private
    //
    
    private func clearDefaultLocation(context: NSManagedObjectContext) throws {
        let request = NSFetchRequest<WeatherLocationDb>(entityName: WeatherLocationDb.Attributes.entityName)
        request.predicate = NSPredicate(format: "isDefault == true")
        
        let results: [WeatherLocationDb] = try context.fetch(request)
        
        results.forEach { location in
            location.isDefault = false
        }
    }
    
}
