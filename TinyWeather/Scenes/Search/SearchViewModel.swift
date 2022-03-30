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
import UIKit

protocol SearchViewModelInputs {
    var animationDidStart: PublishRelay<Void> { get }
    var animationDidComplete: PublishRelay<Bool> { get }
    var viewDidDisappear: PublishRelay<Void> { get }
    
    var searchValue: BehaviorRelay<String?> { get }
    var performSearch: PublishSubject<Void> { get }
    var cityHintTap: PublishRelay<Int> { get }
}

protocol SearchViewModelOutputs {
    var searchPlaceholder: Observable<String> { get }
    var animationState: Search.AnimationState { get }
    var searchHints: Observable<Search.SearchHints?> { get }
    var sceneDidHide: Observable<Void> { get }
}

protocol SearchViewModelProtocol: ThemeProviding {
    var inputs: SearchViewModelInputs { get }
    var outputs: SearchViewModelOutputs { get }
}

class SearchViewModel: SearchViewModelProtocol, SearchViewModelInputs, SearchViewModelOutputs {
    
    private let disposeBag: DisposeBag = DisposeBag()
    
    private var model: Search.Model = Search.Model()

    let theme: Theme
    let apiService: RequestExecuting
    
    var inputs: SearchViewModelInputs { return self }
    var outputs: SearchViewModelOutputs { return self }
    
    // Inputs
    let searchValue: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    let performSearch: PublishSubject<Void> = PublishSubject()
    let animationDidStart: PublishRelay<Void> = PublishRelay()
    let animationDidComplete: PublishRelay<Bool> = PublishRelay()
    let cityHintTap: PublishRelay<Int> = PublishRelay()
    let viewDidDisappear: PublishRelay<Void> = PublishRelay()
    
    // Outputs
    private let _searchPlaceholder: BehaviorRelay<String> = BehaviorRelay(value: NSLocalizedString("searchInputPlaceholder", comment: ""))
    var searchPlaceholder: Observable<String> {
        return _searchPlaceholder.asObservable()
    }
    
    private let _animationState: BehaviorRelay<Search.AnimationState> = BehaviorRelay(value: .hidden)
    var animationState: Search.AnimationState {
        return _animationState.value
    }
    
    private let _searchHints: PublishRelay<Search.SearchHints?> = PublishRelay()
    var searchHints: Observable<Search.SearchHints?> {
        return _searchHints.asObservable()
    }
    
    private let _sceneDidHide: PublishRelay<Void> = PublishRelay()
    var sceneDidHide: Observable<Void> {
        return _sceneDidHide.asObservable()
    }
    
    init(apiService: RequestExecuting, theme: Theme) {
        self.theme = theme
        self.apiService = apiService
        
        self.performSearch.withLatestFrom(self.searchValue)
            .subscribe(onNext: { [weak self] (searchTerm) in
                if let term = searchTerm, term.isEmpty == false {
                    self?._searchHints.accept(.loading)
                } else {
                    self?._searchHints.accept(nil)
                }
            })
            .disposed(by: self.disposeBag)

        let searchResults = self.performSearch.withLatestFrom(self.searchValue)
            .compactMap({ $0 })
            .filter({ !$0.isEmpty })
            .flatMapLatest({ searchTerm in
                apiService.execute(request: APIResource.geo(location: searchTerm))
            })
            .map({ try $0.map(to: [Search.City.Response].self) })
            .share()

        searchResults
            .catchAndReturn([])
            .bind(to: self.model.hintCities)
            .disposed(by: self.disposeBag)

        searchResults
            .map({ [weak self] in
                $0.compactMap {
                    self?.getCity(response: $0)
                }
            })
            .map({ (cities) -> Search.SearchHints in
                if cities.isEmpty {
                    return Search.SearchHints.empty(message: NSLocalizedString("searchHintsNoResultsMessage", comment: ""))
                }
                return Search.SearchHints.results(cities: cities)
            })
            .catchAndReturn(.error(message: NSLocalizedString("searchHintsErrorMessage", comment: "")))
            .observe(on: MainScheduler.instance)
            .bind(to: self._searchHints)
            .disposed(by: self.disposeBag)

        self.animationDidComplete
            .subscribe(onNext: { [weak self] (finished) in
                self?.updateAnimationState(finished: finished)
            })
            .disposed(by: self.disposeBag)

        self.cityHintTap
            .asObservable()
            .compactMap({ [weak self] in
                self?.model.getCity(at: $0)
            })
            .subscribe(onNext: { city in
                // todo process tap
            })
            .disposed(by: self.disposeBag)

        self._animationState
            .skip(1)
            .filter({ $0 == .hidden })
            .subscribe(onNext: { [weak self] _ in
                self?._sceneDidHide.accept(())
            })
            .disposed(by: self.disposeBag)
        
        self.viewDidDisappear
            .bind(to: self._sceneDidHide)
            .disposed(by: self.disposeBag)
    }
    
    private func getCity(response: Search.City.Response) -> Search.City.ViewModel {
        var title: String = response.name
        if let state = response.state, state.isEmpty == false {
            title = "\(title), \(state)"
        }
        
        let subtitle: String = self.getCoords(lat: response.lat, lon: response.lon)
        return Search.City.ViewModel(flag: UIImage(named: response.country), title: title, subtitle: subtitle)
    }
    
    private func getCoords(lat: Double, lon: Double) -> String {
        let latAbbr: String
        let lonAbbr: String
        var latValue: Double = lat
        var lonValue: Double = lon
        
        if lat < 0 {
            latValue = abs(latValue)
            latAbbr = NSLocalizedString("latitudeSouthAbbreviation", comment: "")
        } else {
            latAbbr = NSLocalizedString("latitudeNorthAbbreviation", comment: "")
        }
        
        if lon < 0 {
            lonValue = abs(lonValue)
            lonAbbr = NSLocalizedString("longitudeWestAbbreviation", comment: "")
        } else {
            lonAbbr = NSLocalizedString("longitudeEastAbbreviation", comment: "")
        }
        
        let latFormat: String = String(format: "%.2f", latValue).replacingOccurrences(of: ".", with: "°")
        let lonFormat: String = String(format: "%.2f", lonValue).replacingOccurrences(of: ".", with: "°")
        
        return "\(latFormat)'\(latAbbr) \(lonFormat)'\(lonAbbr)"
    }
    
    private func updateAnimationState(finished: Bool) {
        let newState: Search.AnimationState = finished ? self.animationState.opposite : self.animationState
        self._animationState.accept(newState)
    }

}
