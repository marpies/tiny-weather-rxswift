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

class WeatherViewController: UIViewController, UIScrollViewDelegate, UITableViewDelegate {
    
    private let viewModel: WeatherViewModelProtocol
    private let disposeBag: DisposeBag = DisposeBag()
    
    private let tableViewHeader: WeatherTableHeaderView
    private let tableView: UITableView = UITableView(frame: .zero, style: .plain)
    private let dataSource: DailyWeatherTableDataSource
    
    init(viewModel: WeatherViewModelProtocol) {
        self.viewModel = viewModel
        self.tableViewHeader = WeatherTableHeaderView(theme: viewModel.theme)
        self.dataSource = DailyWeatherTableDataSource(tableView: self.tableView, theme: viewModel.theme)
        
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let headerView = self.tableView.tableHeaderView {
            let sizeToFit: CGSize = CGSize(width: headerView.bounds.width, height: 0)
            let layoutSize: CGSize = headerView.systemLayoutSizeFitting(sizeToFit, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
            
            if headerView.frame.size.height != layoutSize.height {
                var frame: CGRect = headerView.frame
                frame.size.height = layoutSize.height
                headerView.frame = frame
                self.tableView.tableHeaderView = headerView
            }
        }
    }
    
    //
    // MARK: - Private
    //
    
    private func setupViews() {
        // Table view
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.alwaysBounceVertical = true
        self.tableView.allowsMultipleSelection = false
        self.tableView.allowsSelection = true
        self.tableView.tableHeaderView = self.tableViewHeader
        self.tableView.tableFooterView = UIView()
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 88
        self.tableView.backgroundColor = self.viewModel.theme.colors.background
        self.tableView.separatorColor = self.viewModel.theme.colors.separator
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    //
    // MARK: - View model bindable
    //

    private func bindViewModel() {
        let outputs: WeatherViewModelOutputs = self.viewModel.outputs
        
        outputs.locationInfo
            .drive(self.tableViewHeader.rx.location)
            .disposed(by: self.disposeBag)
        
        outputs.weatherInfo
            .map({ $0.current })
            .drive(self.tableViewHeader.rx.weather)
            .disposed(by: self.disposeBag)
        
        let locationInfo = outputs.locationInfo.map({ _ in })
        let weatherInfo = outputs.weatherInfo.map({ _ in })
        
        Observable.merge(locationInfo.asObservable(), weatherInfo.asObservable())
            .subscribe(onNext: { [weak self] in
                self?.view.setNeedsLayout()
            })
            .disposed(by: self.disposeBag)
        
        outputs.newDailyWeather
            .drive(self.dataSource.rx.newDailyWeather)
            .disposed(by: self.disposeBag)
        
        let loadingStart = outputs.state
            .filter({ $0 == .loading })
            .map({ _ in })
        
        loadingStart
            .drive(self.tableViewHeader.rx.showLoading)
            .disposed(by: self.disposeBag)
        
        loadingStart
            .drive(self.dataSource.rx.removeAll)
            .disposed(by: self.disposeBag)
        
        outputs.state
            .filter({ $0 != .loading })
            .map({ _ in })
            .drive(self.tableViewHeader.rx.hideLoading)
            .disposed(by: self.disposeBag)
    }
    
}
