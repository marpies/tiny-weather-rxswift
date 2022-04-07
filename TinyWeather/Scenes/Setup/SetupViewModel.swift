//
//  SetupViewModel.swift
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
import CoreGraphics
import RxCocoa

protocol SetupViewModelInputs {
    var viewDidLoad: PublishRelay<Void> { get }
}

protocol SetupViewModelOutputs {
    
}

protocol SetupViewModelProtocol {
    var theme: Theme { get }
    var inputs: SetupViewModelInputs { get }
    var outputs: SetupViewModelOutputs { get }
}

class SetupViewModel: SetupViewModelProtocol, SetupViewModelInputs, SetupViewModelOutputs {
    
    private let disposeBag: DisposeBag = DisposeBag()
    private let storage: StorageService
    private let router: WeakRouter<AppRoute>
    
    let theme: Theme

    var inputs: SetupViewModelInputs { return self }
    var outputs: SetupViewModelOutputs { return self }
    
    // Inputs
    let viewDidLoad: PublishRelay<Void> = PublishRelay()
    
    init(theme: Theme, router: WeakRouter<AppRoute>, storage: StorageService) {
        self.theme = theme
        self.storage = storage
        self.router = router
        
        self.viewDidLoad
            .take(1)
            .subscribe(onNext: { [weak self] in
                self?.initialize()
            })
            .disposed(by: self.disposeBag)
    }
    
    //
    // MARK: - Private
    //
    
    private func initialize() {
        self.storage.initialize
            .subscribe(onCompleted: { [weak self] in
                self?.loadDefaultLocation()
            }, onError: { error in
                print(" Init error \(error)")
                // todo show alert
            })
            .disposed(by: self.disposeBag)
    }
    
    private func loadDefaultLocation() {
        self.storage.defaultLocation
            .subscribe(onSuccess: { [weak self] (location) in
                if let location = location {
                    self?.router.route(to: .weather(location))
                } else {
                    self?.router.route(to: .search(nil))
                }
            })
            .disposed(by: self.disposeBag)
    }

}
