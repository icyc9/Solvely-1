//
//  HomeViewController+UI.swift
//  Solvely
//
//  Created by Daniel Christopher on 11/3/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import Foundation
import CNPPopupController
import MessageUI

extension HomeViewController {
    
    func addActionSelector() {
        let w = self.view.frame.width
        let h: CGFloat = UIScreen.main.bounds.height * 0.75
        let x = (UIScreen.main.bounds.width / 2) - (w / 2)
        let y: CGFloat = UIScreen.main.bounds.height / 4
        actionSelector = MethodSelectionTableView(frame: CGRect(x: x, y: y, width: w, height: h))
        actionSelector.selectionDelegate = self
        
        let image = UIImage(named: "squid top")
        topSquidHead = UIImageView(image: image)
        let sw = (image?.size.width)! / 2
        let sh = (image?.size.height)! / 2
        topSquidHead?.frame = CGRect(x: (w / 2) - (sw / 2), y: y - sh, width: sw, height: sh)
        
        bubbleView = BubbleView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
            
        view.addSubview(bubbleView!)
        view.addSubview(actionSelector)
        view.addSubview(topSquidHead!)
    }
    
    func addHelpButton() {
        help = UIButton(type: .custom)
        
        if let image = UIImage(named: "help") {
            help?.setImage(image, for: .normal)
            let hw = image.size.width
            let hh = image.size.height
            help?.frame = CGRect(x: UIScreen.main.bounds.width - hw - 8, y: UIScreen.main.bounds.height - hh - 8, width: hw, height: hh)
            help?.addTarget(self, action: #selector(HomeViewController.showHelp), for: .touchUpInside)
        }
        
        self.view.addSubview(help!)
    }
    
    func showEdit(text: String?) {
        currentPopup = EditQuestionPopUp.create(questionText: text ?? "", delegate: self)
        presentPopup(popup: currentPopup)
    }
    
    func showError(message: String! = "Something went wrong!", closeable: Bool! = true, handler: SelectionHandler?) {
        currentPopup = ErrorPopUp.create(message: message, closeable: closeable, handler: handler)
        self.presentPopup(popup: currentPopup)
    }
    
    func showError(message: String! = "Something went wrong!") {
        showError(message: message, closeable: true) {[weak self] (button: CNPPopupButton!) -> Void in
            self?.hideCurrentPopup()
        }
    }
    
    func showAnsweringPopup() {
        currentPopup = AnsweringPopUp.create()
        presentPopup(popup: currentPopup)
    }
    
    func showHelp(sender: UIButton?) {
        currentPopup = HelpPopUp.create(delegate: self)
        presentPopup(popup: currentPopup)
    }
    
    func hideCurrentPopup() {
        expand()
        cameraView.showContents()
        currentPopup.dismiss(animated: true)
        currentPopup = nil
    }
    
    func presentPopup(popup: CNPPopupController) {
        if currentPopup != nil {
            currentPopup.dismiss(animated: false)
            currentPopup = nil
        }
        
        cameraView.hideContents()
        currentPopup = popup
        popup.present(animated: true)
    }
}

extension HomeViewController: EditQuestionPopUpDelegate {
    
    func didPressSolve(editedQuestion: String!) {
        showAnsweringPopup()
        

    }
}

extension HomeViewController: SolvelyPopUpDelegate {
    
    func popUpDidClose() {
        self.hideCurrentPopup()
    }
}
