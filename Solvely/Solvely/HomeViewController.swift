
//
//  HomeViewController.swift
//  Solvely
//
//  Created by Daniel Christopher on 8/27/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import UIKit
import FastttCamera
import RxSwift
import NMPopUpViewSwift
import CNPPopupController
import MessageUI
import Spring

protocol Collapsible {
    func collapse()
    func expand()
}

class HomeViewController: UIViewController, UITextViewDelegate {
    private let reachabilityService = ReachabilityService()
    let ocrService = OCRService()
    
    let disposeBag = DisposeBag()
    
    var currentPopup: CNPPopupController!
    var connectionErrorShowing = false
    var popupBeforeConnectionError: CNPPopupController?
    
    var cameraView: CameraView!
    var summarizePresenter: SummarizationPresenter!
    var multipleChoicePresenter: MultipleChoicePresenter!
    var actionSelector: MethodSelectorView!
    
    var help: UIButton?
    var topSquidHead: SpringImageView?
    var bubbleView: BubbleView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        multipleChoicePresenter = MultipleChoicePresenter(viewController: self, strategy: MultipleChoiceStrategy(), disposeBag: disposeBag)
        
        summarizePresenter = SummarizationPresenter(viewController: self, strategy: SummarizeStrategy(), disposeBag: disposeBag)
        
        cameraView = CameraView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        cameraView.delegate = self
        
        view.addSubview(cameraView)
        
        addBubbles()
        addHelpButton()
        addActionSelector()
        
        // Initially collapse everything except action selector
        collapseHelpButton()
        cameraView.collapse()
        
        expandTopSquidHead()
        
        reachabilityService.registerForUpdates(delegate: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
   
    func convertImageToText(image: UIImage!) -> Observable<String?> {
        return self.ocrService.convertImageToText(image: image)
            .observeOn(MainScheduler.instance)
    }
}

extension HomeViewController: MethodSelectorDelegate {
    
    func didExpand() {
        expandTopSquidHead()
        bubbleView?.expand()
    }
    
    func didSelectMethod() {
        collapse()
    }
}

extension HomeViewController: Collapsible {
    
    func collapseHelpButton() {
        // Hide help button
        UIView.animate(withDuration: AnimationConfig.collapseSpeed) { [weak self] in
            self?.help?.frame = CGRect(x: (self?.help?.frame.origin.x)!, y: UIScreen.main.bounds.height, width: (self?.help?.frame.width)!, height: (self?.help?.frame.height)!)
        }
    }
    
    func expandHelpButton() {
       // Show help button
        UIView.animate(withDuration: AnimationConfig.expandSpeed) { [weak self] in
            self?.help?.frame = CGRect(x: (self?.help?.frame.origin.x)!, y: UIScreen.main.bounds.height - (self?.help?.frame.height)! - 8, width: (self?.help?.frame.width)!, height: (self?.help?.frame.height)!)
        } 
    }
    
    func collapseTopSquidHead() {
        SpringAnimation.springEaseInOut(duration: AnimationConfig.collapseSpeed) { [weak self] in
            self?.topSquidHead?.frame.origin.y = UIScreen.main.bounds.height - (self?.topSquidHead?.frame.height)!
        }
    }
    
    func expandTopSquidHead() {
        SpringAnimation.springEaseInOut(duration: AnimationConfig.expandSpeed) { [weak self] in
            self?.topSquidHead?.frame.origin.y = (self?.actionSelector.frame.minY)! - (self?.topSquidHead?.frame.height)!
        }
    }
    
    func collapse() {
        cameraView.collapse()
        actionSelector.collapse()
        bubbleView?.collapse()
        collapseHelpButton()
        collapseTopSquidHead()
    }
    
    func expand() {
        cameraView.expand()
        actionSelector.expand()
        bubbleView?.expand()
        expandHelpButton()
        expandTopSquidHead()
    }
}

extension HomeViewController: CameraViewDelegate {
    
    func didPressTakeImage() {
        let loadingPopUp = AnsweringPopUp.create()
        presentPopup(popup: loadingPopUp)
        
        // Collapse views
        collapse()
    }
    
    func didTakeImage(croppedImage: UIImage) {
        let selectedAction = actionSelector.getSelectedAction()
        
        switch selectedAction {
        case .solveMath:
            break
        case .solveMultipleChoice:
            multipleChoicePresenter.processImage(image: croppedImage)
            break
        case .summarize:
            summarizePresenter.processImage(image: croppedImage)
            break
        case .solveOpenEnded:
            break
        case .none:
            presentPopup(popup: ErrorPopUp.create(message: "You must first select an action up top!", closeable: true, handler: nil))
            break
        default:
            presentPopup(popup: ErrorPopUp.create(message: "You must first select an action up top!", closeable: true, handler: nil))
            break
        }
    }
}
