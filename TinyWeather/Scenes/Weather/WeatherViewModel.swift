//
//  WeatherViewModel.swift
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
import TWExtensions
import TWModels
import TWRoutes

protocol WeatherViewModelInputs {
    var panGestureDidBegin: PublishRelay<Void> { get }
    var panGestureDidChange: PublishRelay<CGFloat> { get }
    var panGestureDidEnd: PublishRelay<CGPoint> { get }
}

protocol WeatherViewModelOutputs {
    var locationInfo: Driver<Weather.Location.ViewModel> { get }
    var state: Driver<Weather.State> { get }
    var weatherInfo: Driver<Weather.Overview.ViewModel> { get }
    var newDailyWeather: Driver<Weather.Day.ViewModel> { get }
}

protocol WeatherViewModelProtocol {
    var theme: Theme { get }
    var inputs: WeatherViewModelInputs { get }
    var outputs: WeatherViewModelOutputs { get }
    
    func loadWeather(forLocation location: WeatherLocation)
}

class WeatherViewModel: WeatherViewModelProtocol, WeatherViewModelInputs, WeatherViewModelOutputs, WeatherConditionPresenting, TemperaturePresenting, WindSpeedPresenting,
                        RainAmountPresenting, SnowAmountPresenting {
    
    private let disposeBag: DisposeBag = DisposeBag()
    private let dateFormatter: DateFormatter = DateFormatter()
    
    private let weatherLoader: WeatherLoading
    private let router: WeakRouter<AppRoute>
    private let storage: WeatherStorageManaging
    
    private var didBeginPan: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    private var panTranslation: BehaviorRelay<CGFloat> = BehaviorRelay(value: 0)

    var inputs: WeatherViewModelInputs { return self }
    var outputs: WeatherViewModelOutputs { return self }
    
    let theme: Theme

    // Inputs
    let panGestureDidBegin: PublishRelay<Void> = PublishRelay()
    let panGestureDidChange: PublishRelay<CGFloat> = PublishRelay()
    let panGestureDidEnd: PublishRelay<CGPoint> = PublishRelay()

    // Outputs
    private let _locationInfo: BehaviorRelay<Weather.Location.ViewModel?> = BehaviorRelay(value: nil)
    var locationInfo: Driver<Weather.Location.ViewModel> {
        return _locationInfo.asDriver().compactMap({ $0 })
    }
    
    private let _state: BehaviorRelay<Weather.State> = BehaviorRelay(value: .loading)
    var state: Driver<Weather.State> {
        return _state.asDriver()
    }
    
    private let _weatherInfo: BehaviorRelay<Weather.Overview.ViewModel?> = BehaviorRelay(value: nil)
    var weatherInfo: Driver<Weather.Overview.ViewModel> {
        return _weatherInfo.asDriver().compactMap({ $0 })
    }
    
    private let _dailyWeather: BehaviorRelay<[Weather.Day.ViewModel?]?> = BehaviorRelay(value: nil)
    var newDailyWeather: Driver<Weather.Day.ViewModel> {
        return _dailyWeather
            .compactMap({ $0 })
            .flatMap({
                Observable.from($0)
                    .observe(on: MainScheduler.instance)
            })
            .asDriver(onErrorJustReturn: nil)
            .compactMap({ $0 })
    }

    init(theme: Theme, weatherLoader: WeatherLoading, router: WeakRouter<AppRoute>, storage: WeatherStorageManaging) {
        self.theme = theme
        self.weatherLoader = weatherLoader
        self.router = router
        self.storage = storage
        
        self.dateFormatter.timeStyle = .short
        self.dateFormatter.dateStyle = .none
        self.dateFormatter.timeZone = TimeZone(abbreviation: "UTC")!
        self.dateFormatter.locale = Locale.current
        
        self.panGestureDidBegin
            .map({ true })
            .bind(to: self.didBeginPan)
            .disposed(by: self.disposeBag)
        
        self.panGestureDidBegin
            .subscribe(onNext: {
                router.route(to: .search(.began))
            })
            .disposed(by: self.disposeBag)
        
        self.panGestureDidChange
            .bind(to: self.panTranslation)
            .disposed(by: self.disposeBag)
        
        Observable.combineLatest(self.panGestureDidChange, self.didBeginPan)
            .filter({ _, didBeginPan in
                didBeginPan
            })
            .map({ translation, _ in
                translation
            })
            .map({ CGPoint(x: 0, y: $0) })
            .subscribe(onNext: { translation in
                router.route(to: .search(.changed(translation: translation)))
            })
            .disposed(by: self.disposeBag)
        
        self.panGestureDidEnd
            .withLatestFrom(Observable.combineLatest(self.panGestureDidEnd, self.panTranslation))
            .subscribe(onNext: { (velocity, translation) in
                if translation > 0 {
                    router.route(to: .search(.ended(velocity: velocity)))
                } else {
                    router.route(to: .search(.ended(velocity: CGPoint(x: 0, y: -1))))
                }
            })
            .disposed(by: self.disposeBag)
        
        self.panGestureDidEnd
            .map({ _ in false })
            .bind(to: self.didBeginPan)
            .disposed(by: self.disposeBag)
    }
    
    func loadWeather(forLocation location: WeatherLocation) {
        let info: Weather.Location.ViewModel = self.getLocationInfo(response: location)
        self._locationInfo.accept(info)
        
        // Save this location as default now (i.e. last one shown)
        self.storage.saveDefaultLocation(location)
        
        // Set loading state
        self._state.accept(.loading)
        
        // Load current weather
        self.weatherLoader.loadWeather(latitude: location.lat, longitude: location.lon)
            .do(onSuccess: { [weak self] (weather: Weather.Overview.Response) in
                self?.storage.saveLocationWeather(weather, location: location)
            })
            .compactMap({ [weak self] (weather: Weather.Overview.Response) in
                self?.getWeatherOverview(response: weather)
            })
            .subscribe(onSuccess: { [weak self] (weather: Weather.Overview.ViewModel) in
                self?._state.accept(.loaded)
                self?._weatherInfo.accept(weather)
                self?._dailyWeather.accept(weather.daily)
            }, onError: { [weak self] _ in
                self?._state.accept(.error)
            })
            .disposed(by: self.disposeBag)
    }
    
    //
    // MARK: - Private
    //
    
    private func getLocationInfo(response: WeatherLocation) -> Weather.Location.ViewModel {
        let title: String = response.name
        var subtitle: String = response.country
        if let state = response.state, state.isEmpty == false {
            subtitle = "\(state), \(subtitle)"
        }
        return Weather.Location.ViewModel(title: title, subtitle: subtitle, flag: UIImage(named: response.country), favoriteIcon: "")
    }
    
    private func getWeatherOverview(response: Weather.Overview.Response) -> Weather.Overview.ViewModel {
        let timezoneOffset: TimeInterval = response.timezoneOffset
        let current: Weather.Current.ViewModel = self.getCurrentWeather(response: response.current, timezoneOffset: timezoneOffset)
        let daily: [Weather.Day.ViewModel] = response.daily.map({ self.getDailyWeather(response: $0, timezoneOffset: timezoneOffset) })
        return Weather.Overview.ViewModel(current: current, daily: daily)
    }
    
    private func getCurrentWeather(response: Weather.Current.Response, timezoneOffset: TimeInterval) -> Weather.Current.ViewModel {
        let lastUpdate: String = self.getLastUpdate(timestamp: response.lastUpdate)
        let temperature: String = self.getTemperatureText(response.temperature)
        let description: String = response.weather.description.capitalizeFirstLetter()
        let icon: DuotoneIcon.ViewModel = self.getConditionIcon(weather: response.weather, colors: self.theme.colors.weather)
        
        // Show sunrise, sunset, snow OR rain, wind speed
        var attributesRaw: [Weather.Attribute] = [.sunrise(response.sunrise + timezoneOffset), .sunset(response.sunset + timezoneOffset)]
        
        // If we have snow info, show snow, otherwise show rain
        if response.snow > 0 {
            attributesRaw.append(.snow(response.snow))
        } else {
            attributesRaw.append(.rain(response.rain))
        }
        
        attributesRaw.append(.wind(response.windSpeed))
        
        let attributes: [Weather.Attribute.ViewModel] = attributesRaw.map(self.getAttribute)
        let lastUpdateIcon: DuotoneIcon.ViewModel = DuotoneIcon.ViewModel(icon: .clock, color: self.theme.colors.label)
        
        return Weather.Current.ViewModel(conditionIcon: icon, lastUpdate: lastUpdate, lastUpdateIcon: lastUpdateIcon, temperature: temperature, description: description, attributes: attributes)
    }
    
    private func getDailyWeather(response: Weather.Day.Response, timezoneOffset: TimeInterval) -> Weather.Day.ViewModel {
        let dayOfWeek: String = self.getDayOfWeek(timestamp: response.date + timezoneOffset)
        let date: String = self.getDate(timestamp: response.date + timezoneOffset)
        let icon: DuotoneIcon.ViewModel = self.getConditionIcon(weather: response.weather, colors: self.theme.colors.weather)
        let tempMin: Weather.Temperature.ViewModel = self.getTemperature(response.tempMin, theme: self.theme)
        let tempMax: Weather.Temperature.ViewModel = self.getTemperature(response.tempMax, theme: self.theme)
        
        // Show snow OR rain and wind speed
        var attributesRaw: [Weather.Attribute] = []
        
        // If we have snow info, show snow, otherwise show rain
        if response.snow > 0 {
            attributesRaw.append(.snow(response.snow))
        } else {
            attributesRaw.append(.rain(response.rain))
        }
        
        attributesRaw.append(.wind(response.windSpeed))
        
        let attributes: [Weather.Attribute.ViewModel] = attributesRaw.map(self.getAttribute)
        
        return Weather.Day.ViewModel(id: UUID(), dayOfWeek: dayOfWeek, date: date, conditionIcon: icon, tempMin: tempMin, tempMax: tempMax, attributes: attributes)
    }
    
    private func getDate(timestamp: TimeInterval) -> String {
        let date: Date = Date(timeIntervalSince1970: timestamp)
        
        self.dateFormatter.dateStyle = .medium
        self.dateFormatter.timeStyle = .none
        
        return self.dateFormatter.string(from: date)
    }
    
    private func getTime(timestamp: TimeInterval) -> String {
        let date: Date = Date(timeIntervalSince1970: timestamp)
        
        self.dateFormatter.dateStyle = .none
        self.dateFormatter.timeStyle = .short
        
        return self.dateFormatter.string(from: date)
    }
    
    private func getDayOfWeek(timestamp: TimeInterval) -> String {
        let date: Date = Date(timeIntervalSince1970: timestamp)
        
        let oldFormat: String = self.dateFormatter.dateFormat
        
        self.dateFormatter.dateFormat = "EE"
        let dayOfWeek: String = self.dateFormatter.string(from: date)
        
        self.dateFormatter.dateFormat = oldFormat
        
        return dayOfWeek
    }
    
    private func getAttribute(_ attribute: Weather.Attribute) -> Weather.Attribute.ViewModel {
        let colors: WeatherColors = self.theme.colors.weather
        
        switch attribute {
        case .rain(let amount):
            return Weather.Attribute.ViewModel(title: self.getRainAmount(amount), icon: DuotoneIcon.ViewModel(icon: .raindrops, color: colors.rain))
        case .snow(let amount):
            return Weather.Attribute.ViewModel(title: self.getSnowAmount(amount), icon: DuotoneIcon.ViewModel(icon: .snowflake, color: colors.snow))
        case .wind(let speed):
            return Weather.Attribute.ViewModel(title: self.getWindSpeed(speed), icon: DuotoneIcon.ViewModel(icon: .wind, color: colors.wind))
        case .sunrise(let time):
            return Weather.Attribute.ViewModel(title: self.getTime(timestamp: time), icon: DuotoneIcon.ViewModel(icon: .sunrise, color: colors.sun))
        case .sunset(let time):
            return Weather.Attribute.ViewModel(title: self.getTime(timestamp: time), icon: DuotoneIcon.ViewModel(icon: .sunset, color: colors.sun))
        }
    }
    
    private func getLastUpdate(timestamp: TimeInterval) -> String {
        let now: TimeInterval = Date().timeIntervalSince1970
        let diff: TimeInterval = now - timestamp
        let minutes: UInt = UInt(floor(diff / 60))
        
        // "Just now"
        if minutes < 1 {
            return NSLocalizedString("currentWeatherLastUpdateJustNowText", comment: "")
        }
        
        // "X minutes ago"
        if minutes < 60 {
            let format: String = NSLocalizedString("num_minutes_ago", comment: "")
            return String.localizedStringWithFormat(format, minutes)
        }
        
        // "X hours ago"
        let hours: UInt = minutes / 60
        if hours < 24 {
            let format: String = NSLocalizedString("num_hours_ago", comment: "")
            return String.localizedStringWithFormat(format, hours)
        }
        
        // "X days ago"
        let days: UInt = hours / 24
        let format: String = NSLocalizedString("num_days_ago", comment: "")
        return String.localizedStringWithFormat(format, days)
    }

}
