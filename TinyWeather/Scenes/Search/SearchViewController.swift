//
//  SearchViewController.swift
//  TinyWeather
//
//  Created by Marcel Piešťanský.
//  Copyright © 2022 Marcel Piestansky. All rights reserved.
//
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture

class SearchViewController: UIViewController, UIScrollViewDelegate {
    
    private let visualView: UIVisualEffectView = UIVisualEffectView(effect: nil)
    
    private let scrollView: UIScrollView = UIScrollView()
    private let contentView: UIView = UIView()
    private let searchField: SearchTextField = SearchTextField()
    private let locationBtn: UIDuotoneIconButton
    private let disposeBag: DisposeBag = DisposeBag()
    
    private let viewModel: SearchViewModelProtocol
    
    private var searchHintsView: SearchHintsView?
    private var animation: SearchPanAnimation?
    
    private var animationState: Search.AnimationState {
        return self.viewModel.outputs.animationState
    }

    init(viewModel: SearchViewModelProtocol) {
        self.viewModel = viewModel
        self.locationBtn = UIDuotoneIconButton(theme: viewModel.theme)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupViews()
        self.setupConstraints()
        self.bindViewModel()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        self.setupConstraints()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.viewModel.inputs.viewDidDisappear.accept(())
    }
    
    //
    // MARK: - Public
    //
    
    func animateIn() {
        self.loadViewIfNeeded()
        
        self.animation?.animateIn()
    }
    
    func animateOut() {
        self.animation?.animateOut()
    }
    
    func startScrubbingAnimation() {
        self.loadViewIfNeeded()
        
        self.animation?.startInteractive(to: self.animationState.opposite)
    }
    
    func updateAnimationProgress(translation: CGPoint) {
        self.animation?.updateAnimationProgress(translation: translation)
    }
    
    func finishAnimation(velocity: CGPoint) {
        self.animation?.finishAnimation(velocity: velocity)
    }
    
    //
    // MARK: - Private
    //
    
    private func setupViews() {
        self.view.backgroundColor = .clear
        
        // Blur
        self.view.addSubview(self.visualView)
        self.visualView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // Scroll view
        self.scrollView.alwaysBounceVertical = false
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.contentInsetAdjustmentBehavior = .always
        self.scrollView.delegate = self
        self.view.addSubview(self.scrollView)
        self.scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.scrollView.addSubview(self.contentView)
        self.contentView.snp.makeConstraints { make in
            make.width.equalTo(self.view)
            make.leading.trailing.equalToSuperview()
            make.top.bottom.equalTo(self.scrollView)
        }
        
        // Location button
        self.locationBtn.alpha = 0
        self.locationBtn.setContentCompressionResistancePriority(.required, for: .vertical)
        self.contentView.addSubview(self.locationBtn)
        
        // Search field
        self.searchField.update(for: self.viewModel.theme)
        self.searchField.alpha = 0
        self.searchField.keyboardType = .alphabet
        self.searchField.textContentType = .addressCityAndState
        self.searchField.returnKeyType = .done
        self.searchField.autocorrectionType = .no
        self.searchField.transform = CGAffineTransform(scaleX: 0.6, y: 0.6).translatedBy(x: 0, y: -50)
        self.searchField.setContentCompressionResistancePriority(.required, for: .vertical)
        self.contentView.addSubview(self.searchField)
        
        // Animation
        self.animation = SearchPanAnimation(searchField: self.searchField, visualView: self.visualView, locationBtn: self.locationBtn)
    }
    
    private func setupConstraints() {
        let isRegular: Bool = self.traitCollection.horizontalSizeClass == .regular
        
        self.searchField.snp.remakeConstraints { make in
            if isRegular {
                make.width.equalToSuperview().multipliedBy(0.5)
            } else {
                make.width.equalToSuperview().inset(24)
            }
            make.height.equalTo(44)
            make.centerX.equalToSuperview()
            make.top.equalTo(self.contentView).offset(8)
            make.bottom.equalToSuperview().priority(.high)
            make.bottom.lessThanOrEqualToSuperview()
        }
        
        self.locationBtn.snp.remakeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.searchField.snp.bottom).offset(16)
            make.bottom.equalToSuperview().priority(.high)
            make.bottom.lessThanOrEqualToSuperview()
        }
    }
    
    private func addHintsView(viewModel: Search.SearchHints) {
        if self.searchHintsView == nil {
            self.searchHintsView = SearchHintsView(theme: self.viewModel.theme)
            self.searchHintsView?.hintViewTap
                .bind(to: self.viewModel.inputs.cityHintTap)
                .disposed(by: self.disposeBag)
            self.contentView.insertSubview(self.searchHintsView!, belowSubview: self.searchField)
            self.searchHintsView?.snp.makeConstraints({ make in
                make.top.equalTo(self.searchField.snp.bottom).offset(-8)
                make.leading.trailing.equalTo(self.searchField).inset(24)
                make.bottom.equalToSuperview().priority(.high)
                make.bottom.lessThanOrEqualToSuperview()
            })
        }
        
        self.searchHintsView?.update(viewModel: viewModel)
        self.animation?.hintsView = self.searchHintsView
    }
    
    private func removeHintsView() {
        self.searchHintsView?.removeFromSuperview()
        self.searchHintsView = nil
        self.animation?.hintsView = nil
    }

    //
    // MARK: - View model bindable
    //

    private func bindViewModel() {
        let inputs: SearchViewModelInputs = self.viewModel.inputs
        let outputs: SearchViewModelOutputs = self.viewModel.outputs
        
        outputs.searchPlaceholder
            .subscribe(onNext: { [weak self] value in
                guard let weakSelf = self else { return }
                
                weakSelf.searchField.attributedPlaceholder = NSAttributedString(string: value, attributes: [
                    NSAttributedString.Key.font: weakSelf.viewModel.theme.fonts.primary(style: .title2),
                    NSAttributedString.Key.foregroundColor: weakSelf.viewModel.theme.colors.secondaryLabel
                ])
            })
            .disposed(by: self.disposeBag)
        
        let searchHints = outputs.searchHints.share()
        searchHints
            .subscribe(onNext: { [weak self] hints in
                if let hints = hints {
                    self?.addHintsView(viewModel: hints)
                } else {
                    self?.removeHintsView()
                }
            })
            .disposed(by: self.disposeBag)
        
        searchHints
            .map({ $0 != nil })
            .bind(to: self.locationBtn.rx.isHidden)
            .disposed(by: self.disposeBag)
        
        outputs.locationButtonTitle
            .subscribe(onNext: { [weak self] viewModel in
                self?.locationBtn.update(viewModel: viewModel)
            })
            .disposed(by: self.disposeBag)
        
        self.searchField.rx.text
            .bind(to: inputs.searchValue)
            .disposed(by: self.disposeBag)
        
        self.searchField.rx
            .controlEvent(.editingChanged)
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .bind(to: inputs.performSearch)
            .disposed(by: self.disposeBag)
        
        let editBegin = self.searchField.rx.controlEvent(.editingDidBegin)
        let editEnd = self.searchField.rx.controlEvent(.editingDidEnd)
        let editEndExit = self.searchField.rx.controlEvent(.editingDidEndOnExit)
        
        let editEvents = Observable.merge([editBegin.asObservable(), editEnd.asObservable(), editEndExit.asObservable()]).share()
        
        let disposable: Disposable = editEvents
            .subscribe(onNext: { [weak self] in
                self?.setupConstraints()
                
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                    self?.view.layoutIfNeeded()
                }, completion: nil)
            })
        
        // Dispose search field edit observers when the scene is about to disappear to avoid
        // modifying constraints during UINavigationController transition
        // The constraints are not animated during that and results in jumpy UI
        outputs.sceneWillHide
            .filter({ [weak self] in
                self?.searchField.isFirstResponder ?? false
            })
            .subscribe(onNext: {
                disposable.dispose()
            })
            .disposed(by: self.disposeBag)
        
        editBegin
            .bind(to: inputs.searchFieldDidBeginEditing)
            .disposed(by: self.disposeBag)
        
        self.animation?.animationDidComplete
            .map({ $0 == .end })
            .bind(to: inputs.animationDidComplete)
            .disposed(by: self.disposeBag)
        
        self.locationBtn.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.searchField.resignFirstResponder()
            })
            .disposed(by: self.disposeBag)
        
        self.locationBtn.rx.tap
            .bind(to: inputs.searchByLocation)
            .disposed(by: self.disposeBag)
        
        // Enable panning animation only when needed
        guard outputs.isInteractiveAnimationEnabled else { return }
        
        self.view.rx.panGesture()
            .when(.began)
            .map({ _ in })
            .subscribe(onNext: { [weak self] in
                self?.startScrubbingAnimation()
            })
            .disposed(by: self.disposeBag)
        
        self.view.rx.panGesture()
            .when(.changed)
            .asTranslation()
            .map({ (translation, _) in translation })
            .subscribe(onNext: { [weak self] translation in
                self?.updateAnimationProgress(translation: translation)
            })
            .disposed(by: self.disposeBag)
        
        self.view.rx.panGesture()
            .when(.ended)
            .asTranslation()
            .map({ (_, velocity) in velocity })
            .subscribe(onNext: { [weak self] velocity in
                self?.finishAnimation(velocity: velocity)
            })
            .disposed(by: self.disposeBag)
    }
    
    //
    // MARK: - Scroll view delegate
    //
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if self.searchField.isFirstResponder {
            self.searchField.endEditing(true)
        }
    }
    
}
