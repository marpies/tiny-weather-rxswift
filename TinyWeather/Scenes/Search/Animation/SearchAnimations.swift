//
//  SearchAnimations.swift
//  TinyWeather
//
//  Created by Marcel Piešťanský.
//  Copyright © 2022 Marcel Piestansky. All rights reserved.
//  
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//  

import Foundation
import UIKit
import RxSwift
import RxCocoa

class SearchPanAnimation {
    
    private let searchField: UIView
    private let visualView: UIVisualEffectView
    private let effect: UIBlurEffect = UIBlurEffect(style: .regular)
    
    private var animator: UIViewPropertyAnimator?
    
    private var animationState: Search.AnimationState = .hidden
    private var fractionComplete: CGFloat = 0
    
    let animationDidComplete: PublishRelay<UIViewAnimatingPosition> = PublishRelay()

    init(searchField: UIView, visualView: UIVisualEffectView) {
        self.searchField = searchField
        self.visualView = visualView
    }
    
    deinit {
        self.animator?.stopAnimation(true)
    }
    
    //
    // MARK: - Public
    //
    
    func start() {
        self.animator = UIViewPropertyAnimator(duration: 1 / 3, curve: .easeOut)
        
        self.visualView.effect = nil
        self.searchField.transform = CGAffineTransform(scaleX: 0.6, y: 0.6).translatedBy(x: 0, y: -50)
        
        self.animator?.addAnimations { [weak self] in
            self?.searchField.alpha = 1
            self?.searchField.transform = .identity
            self?.visualView.effect = self?.effect
        }
        
        self.animator?.addCompletion { [weak self] position in
            self?.animationDidComplete.accept(position)
            self?.visualView.effect = self?.effect
        }
        
        self.animator?.startAnimation()
    }
    
    func startInteractive(to state: Search.AnimationState) {
        self.animationState = state.opposite
        
        if let anim = self.animator {
            self.fractionComplete = anim.fractionComplete
        } else {
            self.fractionComplete = 0
        }
        
        self.animator?.pauseAnimation()
        
        if self.animator == nil {
            self.animator = UIViewPropertyAnimator(duration: 2 / 3, curve: .easeOut)
            
            self.animator?.addAnimations { [weak self] in
                guard let weakSelf = self else { return }
                
                switch state {
                case .hidden:
                    weakSelf.visualView.effect = nil
                    weakSelf.searchField.alpha = 0
                    weakSelf.searchField.transform = CGAffineTransform(scaleX: 0.8, y: 0.8).translatedBy(x: 0, y: -50)
                case .visible:
                    weakSelf.visualView.effect = weakSelf.effect
                    weakSelf.searchField.alpha = 1
                    weakSelf.searchField.transform = .identity
                }
            }
            
            self.animator?.addCompletion({ [weak self] position in
                guard let weakSelf = self else { return }
                
                weakSelf.animator = nil
                weakSelf.animationDidComplete.accept(position)
            })
        }
    }
    
    func updateAnimationProgress(translation: CGPoint) {
        var fraction: CGFloat = translation.y / 300
        
        // If we are in the visible state, negative translation makes the progress,
        // thus we flip the sign
        if self.animationState == .visible {
            fraction *= -1
        }
        
        // Flip the progress when the animator is reversed
        if let animator = self.animator, animator.isReversed {
            fraction *= -1
        }
        
        self.setAnimationProgress(fraction, translation: translation)
    }
    
    func finishAnimation(velocity: CGPoint) {
        guard let animator = self.animator else { return }
        
        if animator.state == .inactive {
            animator.pauseAnimation()
        }
        
        if velocity.y == 0 {
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
            return
        }
        
        let shouldHide: Bool = velocity.y < 0
        
        switch self.animationState {
        case .hidden:
            if shouldHide && !animator.isReversed {
                animator.isReversed = true
            }
            
            if !shouldHide && animator.isReversed {
                animator.isReversed = false
            }
            
        case .visible:
            if shouldHide && animator.isReversed {
                animator.isReversed = false
            }
            
            if !shouldHide && !animator.isReversed {
                animator.isReversed = true
            }
        }
        
        let params: UISpringTimingParameters = UISpringTimingParameters(dampingRatio: 1, initialVelocity: CGVector(dx: 0, dy: velocity.y))
        
        animator.continueAnimation(withTimingParameters: params, durationFactor: 0)
    }
    
    //
    // MARK: - Private
    //
    
    private func setAnimationProgress(_ value: CGFloat, translation: CGPoint) {
        let total: CGFloat = self.fractionComplete + value
        let progress: CGFloat = max(0.001, min(0.999, total))
        self.animator?.fractionComplete = progress
    }
    
}
