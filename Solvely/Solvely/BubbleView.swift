//
//  BubbleView.swift
//  Solvely
//
//  Created by Daniel Christopher on 11/10/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import UIKit

class BubbleView: UIView {
    private let bubbleWidth = 32
    private let bubbleHeight = 32
    private var wasLastWhite = false
    var timer: Timer?
    var bubbleDuration = 1
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(BubbleView.spawnBubble), userInfo: nil, repeats: true)
    }
    
    func spawnBubble() {
        let x = randInRange(min: 0, max: UIScreen.main.bounds.width - CGFloat(bubbleWidth))
        let y = frame.height
        
        let bubble = UIView(frame: CGRect(x: Int(x), y: Int(y), width: bubbleWidth, height: bubbleHeight))
        
        // Alternate between white/blue
        if wasLastWhite {
            bubble.backgroundColor = UIColor.solvelyPrimaryBlue()
            wasLastWhite = false
        }
        else {
            bubble.backgroundColor = UIColor.white
            wasLastWhite = true
        }
        
        bubble.layer.cornerRadius = bubble.frame.height / 2
        
        self.addSubview(bubble)
        
        addFloatAnimation(bubble: bubble)
    }
    
    private func randInRange(min: CGFloat, max: CGFloat) -> CGFloat {
        return CGFloat(Float(arc4random()) / Float(UINT32_MAX)) * (max - min) + min
    }
    
    func addFloatAnimation(bubble: UIView?) {
        let animation = CAKeyframeAnimation()
        animation.keyPath = "position"
        animation.duration = CFTimeInterval(Int(self.randInRange(min: 2, max: 3)))
        animation.isAdditive = true
        animation.delegate = AnimationDelegate(
            didStart: nil,
            didStop: { [weak self] in
                bubble?.removeFromSuperview()
        })
        
        let amplitude = self.randInRange(min: 10, max: 15)
        let period = self.randInRange(min: 0.01, max: 0.05)
        animation.values = (0..<Int(frame.height + CGFloat(bubbleHeight))).map({ x -> NSValue in
            let point = CGPoint(x: amplitude * sin(period * CGFloat(x)), y: CGFloat(-x))
            return NSValue(cgPoint: point)
        })
        
        bubble?.layer.add(animation, forKey: "float")
    }
}

extension BubbleView: Collapsible {
    
    func collapse() {
        timer?.invalidate()
        
        for bubble in subviews {
            UIView.animate(withDuration: AnimationConfig.expandSpeed) { [weak self] in
                bubble.alpha = 0
            }
        }
    }
    
    func expand() {
        setup()
    }
}

class AnimationDelegate: NSObject, CAAnimationDelegate {
    typealias AnimationCallback = (() -> Void)
    
    let didStart: AnimationCallback?
    let didStop: AnimationCallback?
    
    init(didStart: AnimationCallback?, didStop: AnimationCallback?) {
        self.didStart = didStart
        self.didStop = didStop
    }
    
    internal func animationDidStart(_ anim: CAAnimation) {
        didStart?()
    }
    
    internal func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        didStop?()
    }
}
