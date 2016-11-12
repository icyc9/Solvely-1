//
//  MethodSelectorView.swift
//  Solvely
//
//  Created by Daniel Christopher on 11/11/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import UIKit

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
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        view = Bundle.main.loadNibNamed("MethodSelector", owner: self, options: nil)?[0] as! UIView!
        view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: frame.height)
        addSubview(view)
        
        topView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MethodSelectorView.headerTouched)))
        
        originalFrame = frame
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
        if selectionDelegate != nil {
            selectionDelegate.didSelectMethod()
        }
    }

    @IBAction func answerMath(_ sender: UIButton) {
        selectedAction = SolvelyAction.solveMath
        if selectionDelegate != nil {
            selectionDelegate.didSelectMethod()
        }
    }

    @IBAction func answerQuestion(_ sender: UIButton) {
        selectedAction = SolvelyAction.solveOpenEnded
        if selectionDelegate != nil {
            selectionDelegate.didSelectMethod()
        }
    }
    
    func getSelectedAction() -> SolvelyAction {
        return selectedAction!
    }
}

extension MethodSelectorView: Collapsible {

    func collapse() {
        originalFrame = self.frame
        collapsed = true
        
        UIView.animate(withDuration: AnimationConfig.collapseSpeed, animations: { [weak self] in
            self!.bottomView.alpha = 0
            self?.frame = CGRect(x: (self?.frame.origin.x)!, y: 0, width: (self?.frame.width)!, height: (self?.frame.height)!)
            self?.layoutIfNeeded()
        })
    }
    
    func expand() {
        collapsed = false
        
        UIView.animate(withDuration: AnimationConfig.collapseSpeed, animations: { [weak self] in
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
