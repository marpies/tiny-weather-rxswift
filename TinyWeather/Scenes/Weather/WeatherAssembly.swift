//
//  WeatherAssembly.swift
//  TinyWeather
//
//  Created by Marcel Piešťanský.
//  Copyright © 2022 Marcel Piestansky. All rights reserved.
//
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//

import Foundation
import Swinject

struct WeatherAssembly: Assembly {
    
    func assemble(container: Container) {
        container.register(WeatherViewModelProtocol.self) { (r: Resolver, router: WeakRouter<AppRoute>) in
            let theme: Theme = r.resolve(Theme.self)!
            let apiService: RequestExecuting = r.resolve(RequestExecuting.self)!
            let storage: DefaultLocationStorageManaging = r.resolve(DefaultLocationStorageManaging.self)!
            return WeatherViewModel(theme: theme, apiService: apiService, router: router, storage: storage)
        }
        container.register(WeatherViewController.self) { (r: Resolver, viewModel: WeatherViewModelProtocol) in
            return WeatherViewController(viewModel: viewModel)
        }
    }
    
}
