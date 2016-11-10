//
//  CropBox.swift
//  Solvely
//
//  Created by Daniel Christopher on 10/22/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import UIKit

class CropBoxView: UIView {
    var touchLocation: CGPoint?
    var initialSize: CGSize?
    var initialFrame: CGRect?
    var isTop = false
    var isLeft = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        setup()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        touchLocation = touch?.location(in: superview)
        initialSize = frame.size
        initialFrame = frame
        print(superview?.frame.midY)
        print(frame.midY)
    }
    
    func didPan(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: superview)
        let location = gesture.location(in: superview)
        
        let minW = CGFloat(96)
        let minH = CGFloat(48)
        
        var x = CGFloat(0)
        var y = CGFloat(0)
        var w = CGFloat(0)
        var h = CGFloat(0)
        
        let velocity = gesture.velocity(in: self)
        
        if (touchLocation?.x)! < (superview?.frame.midX)! {
            print("left")
            x = initialFrame!.minX + translation.x
            w = CGFloat(initialSize!.width - (translation.x * 2))
        }
        else {
            print("right")
            x = initialFrame!.minX - translation.x
            w = CGFloat(initialSize!.width + (translation.x * 2))
        }
        
        print(touchLocation?.y)
        print(frame.midY)
        
        if (touchLocation?.y)! < (superview?.frame.midY)! {
            print("top")
            y = initialFrame!.minY + translation.y
            h = CGFloat(initialSize!.height - (translation.y * 2))
        }
        else {
            print("bottom")
            y = initialFrame!.minY - translation.y
            h = CGFloat(initialSize!.height + (translation.y * 2))
        }
        
        if x < 0 {
            x = 0
        }
        
        if w > (superview?.frame.width)! {
            w = (superview?.frame.width)!
        }
        
        if y < 0 {
            y = 0
        }
        
        if h > (superview?.frame.height)! {
            h = (superview?.frame.height)!
        }
        
        if w < minW {
            w = minW
            x = (superview?.frame.midX)! - (minW / 2)
        }
        
        if h <= minH {
            h = minH
            y = (superview?.frame.midY)! - (minH / 2)
        }
        
        frame = CGRect(x: x, y: y, width: w, height: h)
    }
    
    private func setup() {
        isUserInteractionEnabled = true
        backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
        layer.borderWidth = 4
        layer.cornerRadius = 4
        layer.borderColor = UIColor(red: 0.9333, green: 0.9333, blue: 0.9333, alpha: 1.0).withAlphaComponent(1).cgColor
        
        let panGesture = UIPanGestureRecognizer()
        panGesture.addTarget(self, action: #selector(CropBoxView.didPan))
        
        addGestureRecognizer(panGesture)
    }
}
