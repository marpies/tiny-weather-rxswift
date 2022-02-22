//
//  SearchAssembly.swift
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

struct SearchAssembly: Assembly {
    
    func assemble(container: Container) {
        container.register(SearchViewModelProtocol.self) { r in
            let theme: Theme = r.resolve(Theme.self)!
            return SearchViewModel(theme: theme)
        }
        container.register(SearchViewController.self) { (r: Resolver, viewModel: SearchViewModelProtocol) in
            return SearchViewController(viewModel: viewModel)
        }
    }
    
}
