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
        let h: CGFloat = self.view.frame.height
        let x = (UIScreen.main.bounds.width / 2) - (w / 2)
        let y: CGFloat = 0
        actionSelector = MethodSelectionTableView(frame: CGRect(x: x, y: y, width: w, height: h))
        
        view.addSubview(actionSelector)
    }
    
    func addHelpButton() {
        let help = UIButton(type: .custom)
        
        if let image = UIImage(named: "help") {
            help.setImage(image, for: .normal)
            let hw = image.size.width
            let hh = image.size.height
            help.frame = CGRect(x: UIScreen.main.bounds.width - hw - 8, y: UIScreen.main.bounds.height - hh - 8, width: hw, height: hh)
            help.addTarget(self, action: #selector(HomeViewController.showHelp), for: .touchUpInside)
        }
        
        self.view.addSubview(help)
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
        showError(message: message, closeable: true) {(button: CNPPopupButton!) -> Void in
            self.hidePopup(popup: self.currentPopup)
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
    
    func hidePopup(popup: CNPPopupController) {
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
        self.hidePopup(popup: currentPopup)
    }
}
