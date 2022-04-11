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
                
                // Update existing model or create a new one
                let model: DefaultLocationDb = results.first ?? DefaultLocationDb(context: ctx)
                
                self.updateModel(model, with: location)
                
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
    
    private func updateModel(_ model: DefaultLocationDb, with source: WeatherLocation) {
        model.name = source.name
        model.country = source.country
        model.state = source.state
        model.lon = source.lon
        model.lat = source.lat
    }
    
}
