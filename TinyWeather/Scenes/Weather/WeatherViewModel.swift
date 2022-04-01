//
//  WeatherViewModel.swift
//  TinyWeather
//
//  Created Marcel Piešťanský on 30.03.2022.
//  Copyright © 2022 Marcel Piestansky. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

protocol WeatherViewModelInputs {

}

protocol WeatherViewModelOutputs {
    var locationInfo: Driver<Weather.Location.ViewModel?> { get }
    var state: Driver<Weather.State> { get }
    var currentWeather: Driver<Weather.Current.ViewModel?> { get }
}

protocol WeatherViewModelProtocol {
    var theme: Theme { get }
    var inputs: WeatherViewModelInputs { get }
    var outputs: WeatherViewModelOutputs { get }
    
    func displayWeather(forLocation location: Search.Location.Response)
}

class WeatherViewModel: WeatherViewModelProtocol, WeatherViewModelInputs, WeatherViewModelOutputs, WeatherConditionPresenting, TemperaturePresenting, WindSpeedPresenting, RainAmountPresenting {
    
    private let disposeBag: DisposeBag = DisposeBag()
    private let dateFormatter: DateFormatter = DateFormatter()
    
    private let apiService: RequestExecuting
    private let router: WeakRouter<AppRoute>

    var inputs: WeatherViewModelInputs { return self }
    var outputs: WeatherViewModelOutputs { return self }
    
    let theme: Theme

    // Inputs

    // Outputs
    private let _locationInfo: BehaviorRelay<Weather.Location.ViewModel?> = BehaviorRelay(value: nil)
    var locationInfo: Driver<Weather.Location.ViewModel?> {
        return _locationInfo.asDriver()
    }
    
    private let _state: BehaviorRelay<Weather.State> = BehaviorRelay(value: .loading)
    var state: Driver<Weather.State> {
        return _state.asDriver()
    }
    
    private let _currentWeather: BehaviorRelay<Weather.Current.ViewModel?> = BehaviorRelay(value: nil)
    var currentWeather: Driver<Weather.Current.ViewModel?> {
        return _currentWeather.asDriver()
    }

    init(theme: Theme, apiService: RequestExecuting, router: WeakRouter<AppRoute>) {
        self.theme = theme
        self.apiService = apiService
        self.router = router
        
        self.dateFormatter.timeStyle = .short
        self.dateFormatter.dateStyle = .none
    }
    
    func displayWeather(forLocation location: Search.Location.Response) {
        let info: Weather.Location.ViewModel = self.getLocationInfo(response: location)
        self._locationInfo.accept(info)
        
        // Load current weather
        self.apiService.execute(request: APIResource.weather(lat: location.lat, lon: location.lon))
            .map({ (response: HTTPResponse) in
                try response.map(to: Weather.Current.Response.self)
            })
            .compactMap({ [weak self] (weather: Weather.Current.Response) in
                print(weather)
                return self?.getWeather(response: weather)
            })
            .subscribe(onSuccess: { [weak self] (weather: Weather.Current.ViewModel) in
                self?._state.accept(.loaded)
                self?._currentWeather.accept(weather)
            }, onError: { [weak self] _ in
                self?._state.accept(.error)
            })
            .disposed(by: self.disposeBag)
    }
    
    //
    // MARK: - Private
    //
    
    private func getLocationInfo(response: Search.Location.Response) -> Weather.Location.ViewModel {
        let title: String = response.name
        var subtitle: String = response.country
        if let state = response.state, state.isEmpty == false {
            subtitle = "\(state), \(subtitle)"
        }
        return Weather.Location.ViewModel(title: title, subtitle: subtitle, flag: UIImage(named: response.country), favoriteIcon: "")
    }
    
    private func getWeather(response: Weather.Current.Response) -> Weather.Current.ViewModel {
        let lastUpdate: String = self.dateFormatter.string(from: response.lastUpdate)
        let temperature: String = self.getTemperature(response.temperature)
        let description: String = response.weather.description.capitalizeFirstLetter()
        let icon: DuotoneIcon.ViewModel = self.getConditionIcon(weather: response.weather, colors: self.theme.colors.weather)
        let attributesRaw: [Weather.Attribute] = [.sunrise(response.sunrise), .sunset(response.sunset), .rain(response.rain), .wind(response.wind)]
        let attributes: [Weather.Attribute.ViewModel] = attributesRaw.map(self.getAttribute)
        let lastUpdateIcon: DuotoneIcon.ViewModel = DuotoneIcon.ViewModel(icon: .clock, color: self.theme.colors.label)
        
        return Weather.Current.ViewModel(conditionIcon: icon, lastUpdate: lastUpdate, lastUpdateIcon: lastUpdateIcon, temperature: temperature, description: description, attributes: attributes)
    }
    
    private func getAttribute(_ attribute: Weather.Attribute) -> Weather.Attribute.ViewModel {
        let colors: WeatherColors = self.theme.colors.weather
        
        switch attribute {
        case .rain(let amount):
            return Weather.Attribute.ViewModel(title: self.getRainAmount(amount), icon: DuotoneIcon.ViewModel(icon: .raindrops, color: colors.rain))
        case .wind(let speed):
            return Weather.Attribute.ViewModel(title: self.getWindSpeed(speed), icon: DuotoneIcon.ViewModel(icon: .wind, color: colors.wind))
        case .sunrise(let time):
            return Weather.Attribute.ViewModel(title: self.dateFormatter.string(from: time), icon: DuotoneIcon.ViewModel(icon: .sunrise, color: colors.sun))
        case .sunset(let time):
            return Weather.Attribute.ViewModel(title: self.dateFormatter.string(from: time), icon: DuotoneIcon.ViewModel(icon: .sunset, color: colors.sun))
        }
    }

}
