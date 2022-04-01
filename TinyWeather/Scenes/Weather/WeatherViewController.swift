//
//  WeatherViewController.swift
//  TinyWeather
//
//  Created Marcel Piešťanský on 30.03.2022.
//  Copyright © 2022 Marcel Piestansky. All rights reserved.
//

import UIKit
import RxSwift
import SnapKit

class WeatherViewController: UIViewController {
    
    private let viewModel: WeatherViewModelProtocol
    private let disposeBag: DisposeBag = DisposeBag()
    
    private let scrollView: UIScrollView = UIScrollView()
    private let contentView: UIView = UIView()
    private let contentStack: UIStackView = UIStackView()
    
    private let locationView: WeatherLocationView
    private let currentWeatherView: CurrentWeatherView

    init(viewModel: WeatherViewModelProtocol) {
        self.viewModel = viewModel
        self.locationView = WeatherLocationView(theme: viewModel.theme)
        self.currentWeatherView = CurrentWeatherView(theme: viewModel.theme)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = self.viewModel.theme.colors.background
        
        self.setupViews()
        self.bindViewModel()
    }
    
    //
    // MARK: - Private
    //
    
    private func setupViews() {
        // Scroll view
        self.scrollView.alwaysBounceVertical = true
        self.scrollView.backgroundColor = self.viewModel.theme.colors.background
        self.scrollView.showsVerticalScrollIndicator = false
        self.view.addSubview(self.scrollView)
        self.scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.contentView.backgroundColor = self.viewModel.theme.colors.background
        self.scrollView.addSubview(self.contentView)
        self.contentView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.width.equalTo(self.view)
            make.height.equalTo(self.scrollView.safeAreaLayoutGuide).priority(.high)
            make.top.bottom.equalToSuperview()
        }
        
        self.contentStack.axis = .vertical
        self.contentStack.spacing = 32
        self.contentView.addSubview(self.contentStack)
        self.contentStack.snp.makeConstraints { make in
            make.leading.trailing.equalTo(self.contentView.layoutMarginsGuide)
            make.top.greaterThanOrEqualToSuperview().offset(16)
            make.bottom.lessThanOrEqualToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
        
        // Location info
        self.contentStack.addArrangedSubview(self.locationView)
        
        // Current weather
        self.contentStack.addArrangedSubview(self.currentWeatherView)
    }

    //
    // MARK: - View model bindable
    //

    private func bindViewModel() {
        let outputs: WeatherViewModelOutputs = self.viewModel.outputs
        
        outputs.locationInfo
            .compactMap({ $0 })
            .drive(self.locationView.rx.locationInfo)
            .disposed(by: self.disposeBag)
        
        outputs.currentWeather
            .compactMap({ $0 })
            .drive(self.currentWeatherView.rx.weather)
            .disposed(by: self.disposeBag)
    }
    
}
