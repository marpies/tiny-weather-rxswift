//
//  WeatherAssembly.swift
//  TinyWeather
//
//  Created by Marcel Piešťanský on 30.03.2022.
//  Copyright (c) 2022 Marcel Piestansky. All rights reserved.
//

import Foundation
import Swinject

struct WeatherAssembly: Assembly {
    
    func assemble(container: Container) {
        container.register(WeatherViewModelProtocol.self) { (r: Resolver, router: WeakRouter<AppRoute>) in
            let theme: Theme = r.resolve(Theme.self)!
            let apiService: RequestExecuting = r.resolve(RequestExecuting.self)!
            return WeatherViewModel(theme: theme, apiService: apiService, router: router)
        }
        container.register(WeatherViewController.self) { (r: Resolver, viewModel: WeatherViewModelProtocol) in
            return WeatherViewController(viewModel: viewModel)
        }
    }
    
}
