//
//  SearchViewModel.swift
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
import RxCocoa

enum SearchAnimationState {
    case hidden, visible
}

protocol SearchViewModelInputs {
    var animationDidComplete: PublishRelay<Void> { get }
    
    var searchValue: BehaviorRelay<String?> { get }
    var performSearch: PublishSubject<Void> { get }
}

protocol SearchViewModelOutputs {
    var searchPlaceholder: BehaviorRelay<String> { get }
    var animationState: BehaviorRelay<SearchAnimationState> { get }
}

protocol SearchViewModelProtocol: ThemeProviding {
    var inputs: SearchViewModelInputs { get }
    var outputs: SearchViewModelOutputs { get }
}

class SearchViewModel: SearchViewModelProtocol, SearchViewModelInputs, SearchViewModelOutputs {

    let theme: Theme
    
    var inputs: SearchViewModelInputs { return self }
    var outputs: SearchViewModelOutputs { return self }
    
    // Inputs
    let searchValue: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    let performSearch: PublishSubject<Void> = PublishSubject()
    let animationDidComplete: PublishRelay<Void> = PublishRelay()
    
    // Outputs
    let searchPlaceholder: BehaviorRelay<String> = BehaviorRelay(value: NSLocalizedString("searchInputPlaceholder", comment: ""))
    let animationState: BehaviorRelay<SearchAnimationState> = BehaviorRelay(value: .hidden)
    
    private let disposeBag: DisposeBag = DisposeBag()
    
    init(theme: Theme) {
        self.theme = theme
        
        self.animationDidComplete
            .subscribe(onNext: {
                switch self.animationState.value {
                case .hidden:
                    self.animationState.accept(.visible)
                    
                case .visible:
                    self.animationState.accept(.hidden)
                }
            })
            .disposed(by: self.disposeBag)
    }

}
