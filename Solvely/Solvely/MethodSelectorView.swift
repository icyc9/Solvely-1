//
//  MethodSelectorView.swift
//  Solvely
//
//  Created by Daniel Christopher on 11/11/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import UIKit
import Spring

enum SolvelyAction {
    case summarize
    case solveMath
    case solveOpenEnded
    case solveMultipleChoice
    case none
}

protocol MethodSelectorDelegate {
    func didSelectMethod()
    func didExpand()
}

class MethodSelectorView: UIView {
    fileprivate var collapsed = false
    var view: UIView!
    var selectionDelegate: MethodSelectorDelegate!
    var originalFrame: CGRect!
    var selectedAction: SolvelyAction?
    
    @IBOutlet weak var topView: SpringView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var topViewTitleLabel: UILabel!
    @IBOutlet weak var topViewSubtitleLabel: UILabel!
    @IBOutlet weak var collapsedTopView:
    SpringView!
    @IBOutlet weak var summarizeButton: SpringButton!
    
    @IBOutlet weak var answerButton: SpringButton!
    @IBOutlet weak var mathButton: SpringButton!
    @IBOutlet weak var collapsedTopViewTitle: SpringLabel!
    @IBOutlet weak var collapsedTopViewArrow: SpringImageView!
    
    var selectedButton: UIButton?
    
    private var hasAnimated = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.clear
        
        view = Bundle.main.loadNibNamed("MethodSelector", owner: self, options: nil)?[0] as! UIView!
        view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: frame.height)
        addSubview(view)
        
        collapsedTopView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MethodSelectorView.headerTouched)))
        
        originalFrame = frame
        
        collapsedTopView.alpha = 0
        
        animateButtons()
    }
    
    func headerTouched() {
        if collapsed {
            expand()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBAction func summarize(_ sender: UIButton) {
        selectedAction = SolvelyAction.summarize
        selectedButton = sender
        if selectionDelegate != nil {
            selectionDelegate.didSelectMethod()
        }
    }

    @IBAction func answerMath(_ sender: UIButton) {
        selectedAction = SolvelyAction.solveMath
        selectedButton = sender
        if selectionDelegate != nil {
            selectionDelegate.didSelectMethod()
        }
    }

    @IBAction func answerQuestion(_ sender: UIButton) {
        selectedAction = SolvelyAction.solveOpenEnded
        selectedButton = sender
        if selectionDelegate != nil {
            selectionDelegate.didSelectMethod()
        }
    }
    
    func getSelectedAction() -> SolvelyAction {
        return selectedAction!
    }
    
    fileprivate func animateButtons() {
        var delay: CGFloat = 0
        
        if hasAnimated == false {
            delay = AnimationConfig.startDelay
        }
        
        self.topView.y = UIScreen.main.bounds.height
        self.topView.animation = "squeeze"
        self.topView.delay = delay
        self.topView.animate()
        
        self.topView.y = UIScreen.main.bounds.height
        self.topView.animation = "slideUp"
        self.topView.delay = delay
        self.topView.animate()
        
        self.summarizeButton.y = UIScreen.main.bounds.height
        self.summarizeButton.animation = "squeeze"
        self.summarizeButton.delay = delay
        self.summarizeButton.animate()
        
        self.answerButton.y = UIScreen.main.bounds.height
        self.answerButton.animation = "squeeze"
        self.answerButton.delay = delay
        self.answerButton.animate()
        
        self.mathButton.y = UIScreen.main.bounds.height
        self.mathButton.animation = "squeeze"
        self.mathButton.delay = delay
        self.mathButton.animate()
        
        self.summarizeButton.y = UIScreen.main.bounds.height
        self.summarizeButton.animation = "slideUp"
        self.summarizeButton.delay = delay
        self.summarizeButton.animate()
        
        self.answerButton.y = UIScreen.main.bounds.height
        self.answerButton.animation = "slideUp"
        self.answerButton.delay = delay
        self.answerButton.animate()
        
        self.mathButton.y = UIScreen.main.bounds.height
        self.mathButton.animation = "slideUp"
        self.mathButton.delay = delay
        self.mathButton.animate()
        
        hasAnimated = true
    }
}

extension MethodSelectorView: Collapsible {

    func collapse() {
        self.collapsedTopViewTitle.text = selectedButton?.titleLabel?.text
        originalFrame = self.frame
        collapsed = true
        
        
        self.collapsedTopViewArrow.animation = "slideUp"
        self.collapsedTopViewArrow.delay = CGFloat(AnimationConfig.collapseSpeed)
        self.collapsedTopViewArrow.animate()
        
        self.collapsedTopViewTitle.animation = "slideUp"
        self.collapsedTopViewTitle.animate()
        
        self.summarizeButton.animation = "slideUp"
        self.summarizeButton.animate()
        
        UIView.animate(withDuration: AnimationConfig.collapseSpeed, animations: { [weak self] in
            self!.topView.alpha = 0
            self!.collapsedTopView.alpha = 1
            self!.bottomView.alpha = 0
            self?.frame = CGRect(x: (self?.frame.origin.x)!, y: 0, width: (self?.frame.width)!, height: (self?.frame.height)!)
            self?.layoutIfNeeded()
        })
    }
    
    func expand() {
        collapsed = false
        
        animateButtons()
        
        UIView.animate(withDuration: AnimationConfig.collapseSpeed, animations: { [weak self] in
            self!.collapsedTopView.alpha = 0
            self!.topView.alpha = 1
            self!.bottomView.alpha = 1
            self?.frame = CGRect(x: (self?.frame.origin.x)!, y: self!.originalFrame.minY, width: (self?.frame.width)!, height: self!.frame.height)
            self?.layoutIfNeeded()
        }) { [weak self] complete in
            if self!.selectionDelegate != nil {
                self!.selectionDelegate!.didExpand()
            }
        }
    }
}
