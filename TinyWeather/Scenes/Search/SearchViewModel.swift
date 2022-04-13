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
import TWThemes
import TWRoutes
import TWModels
import CoreLocation

protocol SearchViewModelInputs {
    var animationDidStart: PublishRelay<Void> { get }
    var animationDidComplete: PublishRelay<Bool> { get }
    var viewDidDisappear: PublishRelay<Void> { get }
    var searchFieldDidBeginEditing: PublishRelay<Void> { get }
    
    var searchValue: BehaviorRelay<String?> { get }
    var performSearch: PublishSubject<Void> { get }
    var cityHintTap: PublishRelay<Int> { get }
    var searchByLocation: PublishRelay<Void> { get }
}

protocol SearchViewModelOutputs {
    var searchPlaceholder: Observable<String> { get }
    var locationButtonTitle: Observable<IconButton.ViewModel> { get }
    var animationState: Search.AnimationState { get }
    var searchHints: Observable<Search.SearchHints?> { get }
    var sceneDidHide: Observable<Void> { get }
    var sceneWillHide: Observable<Void> { get }
    var isInteractiveAnimationEnabled: Bool { get }
}

protocol SearchViewModelProtocol: ThemeProviding {
    var inputs: SearchViewModelInputs { get }
    var outputs: SearchViewModelOutputs { get }
}

class SearchViewModel: SearchViewModelProtocol, SearchViewModelInputs, SearchViewModelOutputs, CoordinatesPresenting {
    
    private let disposeBag: DisposeBag = DisposeBag()
    private let locationManager: CLLocationManager = CLLocationManager()
    
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
    let searchByLocation: PublishRelay<Void> = PublishRelay()
    let searchFieldDidBeginEditing: PublishRelay<Void> = PublishRelay()
    
    // Outputs
    let isInteractiveAnimationEnabled: Bool
    
    private let _searchPlaceholder: BehaviorRelay<String> = BehaviorRelay(value: NSLocalizedString("searchInputPlaceholder", comment: ""))
    var searchPlaceholder: Observable<String> {
        return _searchPlaceholder.asObservable()
    }
    
    private let _locationButtonTitle: BehaviorRelay<IconButton.ViewModel> = BehaviorRelay(value: IconButton.ViewModel(icon: .location, title: NSLocalizedString("searchDeviceLocationButton", comment: "")))
    var locationButtonTitle: Observable<IconButton.ViewModel> {
        return _locationButtonTitle.asObservable()
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
    
    private let _sceneWillHide: PublishRelay<Void> = PublishRelay()
    var sceneWillHide: Observable<Void> {
        return _sceneWillHide.asObservable()
    }
    
    init(apiService: RequestExecuting, theme: Theme, router: WeakRouter<AppRoute>, isInteractiveAnimationEnabled: Bool) {
        self.theme = theme
        self.apiService = apiService
        self.isInteractiveAnimationEnabled = isInteractiveAnimationEnabled
        
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
            .map({ try $0.map(to: [Search.Location.Response].self) })
            .share()

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
            .subscribe(onNext: { [weak self] (location) in
                self?._sceneWillHide.accept(())
                
                router.route(to: .weather(location))
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
        
        // Look up locations based on the device location
        let searchByLocation = self.searchByLocation
            .flatMapLatest({
                self.locationManager.rx.getCurrentLocation()
            })
            .do(onNext: { [weak self] _ in
                self?._searchHints.accept(.loading)
            })
            .flatMapLatest({ location in
                apiService.execute(request: APIResource.reverseGeo(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude))
            })
            .map({ try $0.map(to: [Search.Location.Response].self) })
            .share()
        
        
        // Single location found for the device location, show weather right away
        searchByLocation
            .catchAndReturn([])
            .filter({ $0.count == 1 })
            .compactMap({ $0.first })
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (location) in
                self?._searchHints.accept(nil)
                self?._sceneWillHide.accept(())
                
                router.route(to: .weather(location))
            })
            .disposed(by: self.disposeBag)
        
        // Multiple locations found for the device location, show them in the search hints
        let multipleLocations = searchByLocation.filter({ $0.count > 1 })
        
        // Merge search results (via text input) and multiple locations found for device location, showing search hints
        Observable.merge(searchResults, multipleLocations)
            .map({ [weak self] in
                $0.compactMap {
                    self?.getLocation(response: $0)
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
        
        // Update model with the found locations
        Observable.merge(searchResults, searchByLocation)
            .catchAndReturn([])
            .bind(to: self.model.hintCities)
            .disposed(by: self.disposeBag)
        
        // Clear search hints if showing error message and we focus into the search field
        self.searchFieldDidBeginEditing.withLatestFrom(self._searchHints)
                .compactMap({ $0 })
                .filter({ val in
                    if case Search.SearchHints.error = val {
                        return true
                    }
                    return false
                })
                .subscribe(onNext: { [weak self] _ in
                    self?._searchHints.accept(nil)
                })
                .disposed(by: self.disposeBag)
    }
    
    private func getLocation(response: Search.Location.Response) -> Search.Location.ViewModel {
        var title: String = response.name
        if let state = response.state, state.isEmpty == false {
            title = "\(title), \(state)"
        }
        
        let subtitle: String = self.getCoords(lat: response.lat, lon: response.lon)
        return Search.Location.ViewModel(flag: UIImage(named: response.country), title: title, subtitle: subtitle)
    }
    
    private func updateAnimationState(finished: Bool) {
        let newState: Search.AnimationState = finished ? self.animationState.opposite : self.animationState
        self._animationState.accept(newState)
    }

}
