//
//  SetupViewModel.swift
//  TinyWeather
//
//  Created Marcel Piešťanský on 17.02.2022.
//  Copyright © 2022 Marcel Piestansky. All rights reserved.
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
    
    let theme: Theme

    var inputs: SetupViewModelInputs { return self }
    var outputs: SetupViewModelOutputs { return self }
    
    // Inputs
    let viewDidLoad: PublishRelay<Void> = PublishRelay()
    
    init(theme: Theme, router: WeakRouter<AppRoute>) {
        self.theme = theme
        
        self.viewDidLoad
            .take(1)
            .subscribe(onNext: {
                router.route(to: .search(nil))
            })
            .disposed(by: self.disposeBag)
    }

}
