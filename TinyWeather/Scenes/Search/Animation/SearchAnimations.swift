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
    
    var hintsView: UIView?

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
    
    func animateIn() {
        self.animator = UIViewPropertyAnimator(duration: 1 / 3, curve: .easeOut)
        
        self.visualView.effect = nil
        self.searchField.transform = CGAffineTransform(scaleX: 0.6, y: 0.6).translatedBy(x: 0, y: -50)
        
        self.animator?.addAnimations { [weak self] in
            self?.searchField.alpha = 1
            self?.searchField.transform = .identity
            self?.visualView.effect = self?.effect
        }
        
        self.animator?.addCompletion { [weak self] position in
            self?.visualView.effect = self?.effect
            self?.animationDidComplete.accept(position)
            self?.animator = nil
            self?.searchField.becomeFirstResponder()
        }
        
        self.animator?.startAnimation()
    }
    
    func animateOut() {
        self.animator = UIViewPropertyAnimator(duration: 1 / 3, curve: .easeOut)
        
        self.animator?.addAnimations { [weak self] in
            self?.hintsView?.transform = CGAffineTransform(scaleX: 0.8, y: 0.8).translatedBy(x: 0, y: -40)
            self?.hintsView?.alpha = 0
            self?.searchField.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            self?.searchField.alpha = 0
            self?.visualView.effect = nil
        }
        
        self.animator?.addCompletion { [weak self] position in
            self?.visualView.effect = nil
            self?.animationDidComplete.accept(position)
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
            self.animator = UIViewPropertyAnimator(duration: 1 / 3, curve: .easeOut)
            
            self.animator?.addAnimations { [weak self] in
                guard let weakSelf = self else { return }
                
                switch state {
                case .hidden:
                    weakSelf.visualView.effect = nil
                    weakSelf.searchField.alpha = 0
                    weakSelf.hintsView?.alpha = 0
                case .visible:
                    weakSelf.visualView.effect = weakSelf.effect
                    weakSelf.searchField.alpha = 1
                    weakSelf.hintsView?.alpha = 1
                }
            }
            
            self.animator?.addCompletion({ [weak self] position in
                guard let weakSelf = self else { return }
                
                // Focus the search field (if it is not already) once it becomes fully visible
                if position == .end && state == .visible && !weakSelf.searchField.isFirstResponder {
                    weakSelf.searchField.becomeFirstResponder()
                }
                
                weakSelf.animator = nil
                weakSelf.searchField.transform = .identity
                weakSelf.hintsView?.transform = .identity
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
        
        let shouldHide: Bool = velocity.y < 0
        
        // Update the search field's transform during the final animation
        animator.addAnimations { [weak self] in
            if shouldHide {
                self?.searchField.transform = CGAffineTransform(translationX: 0, y: max(-100, velocity.y)).scaledBy(x: 0.8, y: 0.8)
                self?.hintsView?.transform = CGAffineTransform(translationX: 0, y: max(-100, velocity.y)).scaledBy(x: 0.8, y: 0.8)
            } else {
                self?.searchField.transform = .identity
                self?.hintsView?.transform = .identity
            }
        }
        
        if velocity.y == 0 {
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
            return
        }
        
        switch self.animationState {
        case .hidden:
            if shouldHide && !animator.isReversed {
                animator.isReversed = true
            } else if !shouldHide && animator.isReversed {
                animator.isReversed = false
            }
            
        case .visible:
            if shouldHide && animator.isReversed {
                animator.isReversed = false
            } else if !shouldHide && !animator.isReversed {
                animator.isReversed = true
            }
        }
        
        animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
    }
    
    //
    // MARK: - Private
    //
    
    private func setAnimationProgress(_ value: CGFloat, translation: CGPoint) {
        let total: CGFloat = self.fractionComplete + value
        let progress: CGFloat = max(0.001, min(0.999, total))
        self.animator?.fractionComplete = progress
        
        // Add translation to the search field according to the pan gesture
        let translationY: CGFloat = translation.y
        var offsetY: CGFloat
        if translationY < 0 {
            offsetY = -pow(abs(translationY), 0.85)
        } else {
            offsetY = pow(translationY, 0.85)
        }
        
        var scale: CGFloat = 1
        
        // Focus in/out the search field depending on the animation progress
        switch self.animationState {
        case .hidden:
            offsetY -= 20
            
            let minScale: CGFloat = 0.8
            scale = (progress * (1 - minScale)) + minScale
            
            if progress > 0.4 && !self.searchField.isFirstResponder {
                self.searchField.becomeFirstResponder()
            } else if progress < 0.3 && self.searchField.isFirstResponder {
                self.searchField.endEditing(true)
            }
            
        case .visible:
            if progress > 0.1 && self.searchField.isFirstResponder {
                self.searchField.endEditing(true)
            }
        }
        
        self.searchField.transform = CGAffineTransform(translationX: 0, y: offsetY).scaledBy(x: scale, y: scale)
        self.hintsView?.transform = CGAffineTransform(translationX: 0, y: offsetY).scaledBy(x: scale, y: scale)
    }
    
}
