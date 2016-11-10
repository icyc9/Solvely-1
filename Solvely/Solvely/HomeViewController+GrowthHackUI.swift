//
//  HomeViewController+GrowthHackUI.swift
//  Solvely
//
//  Created by Daniel Christopher on 11/3/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import Foundation
import MessageUI
import CNPPopupController

extension HomeViewController: MFMessageComposeViewControllerDelegate {
    
    func showGrowthHack() {
        
    }
    
    func showThanksForSharing() {
        
    }
    
    func sendSMSMessage(sender: UIButton?) {
        if MFMessageComposeViewController.canSendText() {
            let composeVC = MFMessageComposeViewController()
            composeVC.messageComposeDelegate = self
            
            composeVC.recipients = ["7033623714"]
            composeVC.body = "This app Solvely lets you take a picture of a multiple choice question and receive the answer. Check it out at http://apple.co/2bMVIKY"
            
            self.present(composeVC, animated: true, completion: nil)
        }
        else {
            self.hideCurrentPopup()
            self.showError(message: "It seems like your device can't send text messages!", closeable: true) {(button: CNPPopupButton!) -> Void in
                self.currentPopup.dismiss(animated: true)
                self.showGrowthHack()
            }
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch (result) {
        case MessageComposeResult.cancelled:
            self.showGrowthHack()
            break
        case is MessageComposeResult:
            self.hideCurrentPopup()
            self.showError(message: "Looks like your text message failed to send! Try again.", closeable: true) {(button: CNPPopupButton!) -> Void in
                self.currentPopup.dismiss(animated: true)
                self.showGrowthHack()
            }
            break
        case is MessageComposeResult:
            self.showThanksForSharing()
            break
        default:
            break
        }
    }
}
