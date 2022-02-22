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

class SearchViewController: UIViewController {
    
    private let effect: UIBlurEffect = UIBlurEffect(style: .regular)
    private let visualView: UIVisualEffectView = UIVisualEffectView(effect: nil)
    
    private let searchField: SearchTextField = SearchTextField()
    private let disposeBag: DisposeBag = DisposeBag()
    
    private let viewModel: SearchViewModelProtocol
    
    private var viewAnimator: UIViewPropertyAnimator?
    private var blurAnimator: UIViewPropertyAnimator?
    
    var animationState: SearchAnimationState {
        return self.viewModel.outputs.animationState.value
    }
    
    deinit {
        self.viewAnimator?.stopAnimation(true)
        self.blurAnimator?.stopAnimation(true)
    }

    init(viewModel: SearchViewModelProtocol) {
        self.viewModel = viewModel
        
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
    
    //
    // MARK: - Public
    //
    
    func animateIn() {
        self.viewAnimator = UIViewPropertyAnimator(duration: 0.6, dampingRatio: 0.6)
        self.blurAnimator = UIViewPropertyAnimator(duration: 0.3, curve: .easeOut)
        
        self.visualView.effect = nil
        self.searchField.transform = CGAffineTransform(scaleX: 0.6, y: 0.6).translatedBy(x: 0, y: -50)
        
        self.viewAnimator?.addAnimations {
            self.searchField.alpha = 1
            self.searchField.transform = .identity
        }
        
        self.viewAnimator?.addCompletion { _ in
            self.viewModel.inputs.animationDidComplete.accept(())
        }
        
        self.blurAnimator?.addAnimations {
            self.visualView.effect = self.effect
        }
        
        self.blurAnimator?.startAnimation()
        self.viewAnimator?.startAnimation()
    }
    
    func startScrubbingAnimation() {
        self.viewAnimator?.stopAnimation(true)
        self.blurAnimator?.stopAnimation(true)
        
        switch self.viewModel.outputs.animationState.value {
        case .hidden:
            self.setupScrubAnimationIn()
            
        case .visible:
            self.setupScrubAnimationOut()
        }
    }
    
    func setAnimationProgress(_ value: CGFloat, translation: CGPoint) {
        self.viewAnimator?.fractionComplete = value
        self.blurAnimator?.fractionComplete = value
        
        if self.viewModel.outputs.animationState.value == .visible {
            var transform = self.searchField.transform
            transform.tx = 0
            transform.ty = 0
            
            if translation.y > 0 {
                self.searchField.transform = transform.translatedBy(x: 0, y: sqrt(translation.y))
            } else {
                self.searchField.transform = transform.translatedBy(x: 0, y: translation.y / 2)
            }
        }
    }
    
    func finishAnimation(velocity: CGPoint) {
        let state: SearchAnimationState = self.viewModel.outputs.animationState.value
        let reversed: Bool
        
        switch state {
        case .hidden:
            reversed = velocity.y < 0
            
        case .visible:
            reversed = velocity.y > 0
        }
        
        self.finishAnimation(reversed: reversed, animations: { [weak self] in
            guard let weakSelf = self else { return }
            
            switch state {
            case .hidden:
                if reversed {
                    weakSelf.searchField.alpha = 0
                    weakSelf.searchField.transform = CGAffineTransform(scaleX: 0.6, y: 0.6).translatedBy(x: 0, y: -50)
                } else {
                    weakSelf.searchField.alpha = 1
                    weakSelf.searchField.transform = .identity
                }
                
            case .visible:
                if reversed {
                    weakSelf.searchField.alpha = 1
                    weakSelf.searchField.transform = .identity
                } else {
                    weakSelf.searchField.alpha = 0
                    weakSelf.searchField.transform = CGAffineTransform(scaleX: 0.6, y: 0.6).translatedBy(x: 0, y: -50)
                }
            }
        })
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
        
        // Search field
        self.searchField.update(for: self.viewModel.theme)
        self.searchField.alpha = 0
        self.searchField.keyboardType = .alphabet
        self.searchField.textContentType = .addressCityAndState
        self.searchField.returnKeyType = .search
        self.searchField.autocorrectionType = .no
        self.view.addSubview(self.searchField)
    }
    
    private func setupConstraints() {
        let isRegular: Bool = self.traitCollection.horizontalSizeClass == .regular
        
        self.searchField.snp.remakeConstraints { make in
            if isRegular {
                make.width.equalTo(self.view.readableContentGuide)
            } else {
                make.width.equalToSuperview().inset(24)
            }
            make.height.equalTo(44)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.5)
        }
    }
    
    private func setupScrubAnimationIn() {
        self.viewAnimator = UIViewPropertyAnimator(duration: 0.6, curve: .easeOut)
        self.blurAnimator = UIViewPropertyAnimator(duration: 0.3, curve: .easeOut)
        
        self.visualView.effect = nil
        self.searchField.transform = CGAffineTransform(scaleX: 0.6, y: 0.6).translatedBy(x: 0, y: -50)
        self.blurAnimator?.scrubsLinearly = false
        self.blurAnimator?.addAnimations {
            self.visualView.effect = self.effect
        }
        
        self.viewAnimator?.scrubsLinearly = false
        self.viewAnimator?.addAnimations({
            UIView.animateKeyframes(withDuration: 0.6, delay: 0, animations: {
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.3) {
                    self.searchField.alpha = 1
                    self.searchField.transform = .identity
                }
                
                UIView.addKeyframe(withRelativeStartTime: 0.3, relativeDuration: 0.6) {
                    self.searchField.transform = CGAffineTransform(scaleX: 0.8, y: 0.8).translatedBy(x: 0, y: 50)
                }
            })
        })
    }
    
    private func setupScrubAnimationOut() {
        self.viewAnimator = UIViewPropertyAnimator(duration: 0.6, curve: .easeOut)
        self.blurAnimator = UIViewPropertyAnimator(duration: 0.3, curve: .easeOut)
        
        self.visualView.effect = self.effect
        self.blurAnimator?.scrubsLinearly = false
        self.blurAnimator?.addAnimations {
            self.visualView.effect = nil
        }
        
        self.viewAnimator?.scrubsLinearly = false
        self.viewAnimator?.addAnimations({
            self.searchField.alpha = 0
            self.searchField.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        })
    }
    
    private func finishAnimation(reversed: Bool, animations: @escaping () -> Void) {
        self.viewAnimator?.stopAnimation(true)
        
        self.viewAnimator = UIViewPropertyAnimator(duration: 0.6, dampingRatio: 0.5, animations: nil)
        
        self.viewAnimator?.isReversed = reversed
        self.blurAnimator?.isReversed = reversed
        
        self.blurAnimator?.continueAnimation(withTimingParameters: nil, durationFactor: 1)
        
        self.viewAnimator?.addAnimations(animations)
        self.viewAnimator?.startAnimation()
        
        if !reversed {
            self.viewModel.inputs.animationDidComplete.accept(())
        }
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
        
        self.searchField.rx.text
            .bind(to: inputs.searchValue)
            .disposed(by: self.disposeBag)
        
        self.searchField.rx
            .controlEvent(.editingDidEndOnExit)
            .bind(to: inputs.performSearch)
            .disposed(by: self.disposeBag)
    }
    
}
