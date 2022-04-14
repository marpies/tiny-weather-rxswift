//
//  CoreDataService+FavoriteLocation.swift
//  TinyWeather
//
//  Created by Marcel Piešťanský.
//  Copyright © 2022 Marcel Piestansky. All rights reserved.
//  
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//  

import Foundation
import RxSwift
import TWModels

extension CoreDataService: FavoriteLocationStorageManaging {
    
    func loadLocationFavoriteStatus(_ location: WeatherLocation) -> Single<Bool> {
        Single.create { single in
            self.backgroundContext.performWith { ctx in
                do {
                    let model: LocationDb? = try self.loadLocation(latitude: location.lat, longitude: location.lon, context: ctx)
                    let isFavorite: Bool = model?.isFavorite ?? false
                    single(.success(isFavorite))
                } catch {
                    single(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
    
    func saveLocationFavoriteStatus(_ location: WeatherLocation, isFavorite: Bool) -> Single<Bool> {
        Single.create { single in
            self.backgroundContext.performWith { ctx in
                do {
                    if let model = try self.loadLocation(latitude: location.lat, longitude: location.lon, context: ctx) {
                        model.isFavorite = isFavorite
                        
                        try ctx.saveIfNeeded()
                        
                        single(.success(isFavorite))
                    } else {
                        single(.success(false))
                    }
                } catch {
                    single(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
    
}
