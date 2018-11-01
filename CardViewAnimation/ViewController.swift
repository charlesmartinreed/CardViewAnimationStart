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
        
    }
    
    @objc func handleCardPan(recognizer: UIPanGestureRecognizer) {
        
    }

}

