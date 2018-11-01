//
//  ViewController.swift
//  CardViewAnimation
//
//  Created by Brian Advent on 26.10.18.
//  Copyright © 2018 Brian Advent. All rights reserved.
//

import UIKit


class ViewController: UIViewController {
    
    enum CardState {
        case expanded
        case collapsed
    }
    
    var cardViewController: CardViewController!
    var visualEffectView: UIVisualEffectView! // allows us to create, animate blur
    
    let cardHeight: CGFloat = 600
    let cardHandleAreaHeight: CGFloat = 65
    
    var isCardVisible = false // true if expanded, false if collapsed
    var nextState: CardState {
        return isCardVisible ? .collapsed : .expanded // if visible, collapse it, if not expand it
    }
    
    //MARK:- Animation arrays
    var runningAnimations = [UIViewPropertyAnimator]()
    var animationProgressWhenInterrupted: CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCard()
      
    }
    
    func setupCard() {
        //add the blur effect
        visualEffectView = UIVisualEffectView()
        visualEffectView.frame = self.view.frame
        self.view.addSubview(visualEffectView)
        
        //load call view controller
        cardViewController = CardViewController(nibName: "CardViewController", bundle: nil)
        //add as child to main view contorller
        self.addChild(cardViewController)
        self.view.addSubview(cardViewController.view)
        
        cardViewController.view.frame = CGRect(x: 0, y: self.view.frame.height - cardHandleAreaHeight, width: self.view.bounds.width, height: cardHeight)
        
        cardViewController.view.clipsToBounds = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleCardTap(recognizer:)))
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleCardPan(recognizer:)))
        
        cardViewController.handleArea.addGestureRecognizer(tapGestureRecognizer)
        cardViewController.handleArea.addGestureRecognizer(panGestureRecognizer)
    }
    
    //MARK:- Gesture recognizers and handlers
    @objc func handleCardTap(recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            animateTransitionIfNeeded(state: nextState, duration: 0.9)
            
        default:
            break
        }
    }
    
    @objc func handleCardPan(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            // startTransition - finger on screen
            startInteractiveTransition(state: nextState, duration: 0.9)
        case .changed:
            // updateTransition - move finger on screen
            
            // check translation of recognizer, create a fractional value for the animation "completion"
            let translation = recognizer.translation(in: self.cardViewController.handleArea)
            var fractionComplete = translation.y / cardHeight
            
            // if the card is visible, use the derived fraction complete as is. Otherwise, provide the negative value to animate UPWARD.
            fractionComplete = isCardVisible ? fractionComplete : -fractionComplete
            updateInteractiveTransition(fractionCompleted: fractionComplete)
        case .ended:
            //continueTransition - lift finger
            continueInteractiveTransition()
        default:
            break
        }
    }
    
    //MARK:- Animation block
    func animateTransitionIfNeeded (state: CardState, duration: TimeInterval) {
        // called when there are no animations in runningAnimation array
        if runningAnimations.isEmpty {
            //MARK:- Frame Animator
            // create a frame animator, using damping for animation style
            let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                //move card view up or down
                switch state {
                case .expanded:
                    self.cardViewController.view.frame.origin.y = self.view.frame.height - self.cardHeight
                case .collapsed:
                    self.cardViewController.view.frame.origin.y = self.view.frame.height - self.cardHandleAreaHeight
                }
            }
            
            frameAnimator.addCompletion { _ in
                self.isCardVisible = !self.isCardVisible
                self.runningAnimations.removeAll()
            }
            
            // start the animation and append animator to array
            frameAnimator.startAnimation()
            runningAnimations.append(frameAnimator)
            
            //MARK:- Corner Radius Animator
            let cornerRadiusAnimator = UIViewPropertyAnimator(duration: duration, curve: .linear) {
                switch state {
                case .expanded:
                    self.cardViewController.view.layer.cornerRadius = 12
                case.collapsed:
                    self.cardViewController.view.layer.cornerRadius = 0
                }
            }
            
            cornerRadiusAnimator.startAnimation()
            runningAnimations.append(cornerRadiusAnimator)
            
            //MARK:- Blur Animator
            let blurAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                switch state {
                case .expanded:
                    self.visualEffectView.effect = UIBlurEffect(style: .dark)
                case .collapsed:
                    self.visualEffectView.effect = nil
                }
            }
            
            blurAnimator.startAnimation()
            runningAnimations.append(blurAnimator)
        }
    }
    
    func startInteractiveTransition(state: CardState, duration: TimeInterval) {
        // check if we have a currently animation
        if runningAnimations.isEmpty {
            animateTransitionIfNeeded(state: state, duration: duration)
        }
        
        for animator in runningAnimations {
            animator.pauseAnimation() // set animation speed to 0, which also makes it interactive
            animationProgressWhenInterrupted = animator.fractionComplete
        }
    }
    
    func updateInteractiveTransition(fractionCompleted: CGFloat) {
        //update the fraction complete for ALL of our animations
        for animator in runningAnimations {
            // add animationProgress so that animations begin at proper point when we move finger across the screen
            animator.fractionComplete = fractionCompleted + animationProgressWhenInterrupted
        }
    }
    
    func continueInteractiveTransition() {
        for animator in runningAnimations {
            // using remaing time in the animation, set when calling startInteractiveTransition
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        }
        
    }
}

