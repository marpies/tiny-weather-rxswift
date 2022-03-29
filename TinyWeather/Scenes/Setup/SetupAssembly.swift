//
//  SetupAssembly.swift
//  TinyWeather
//
//  Created by Marcel Piešťanský on 17.02.2022.
//  Copyright (c) 2022 Marcel Piestansky. All rights reserved.
//

import Foundation
import Swinject

struct SetupAssembly: Assembly {
    
    func assemble(container: Container) {
        container.register(SetupViewModelProtocol.self) { (r: Resolver, router: WeakRouter<AppRoute>) in
            let theme: Theme = r.resolve(Theme.self)!
            return SetupViewModel(theme: theme, router: router)
        }
        container.register(SetupViewController.self) { (r: Resolver, viewModel: SetupViewModelProtocol) in
            return SetupViewController(viewModel: viewModel)
        }
    }
    
}
