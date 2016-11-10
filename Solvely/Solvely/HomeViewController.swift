
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

class HomeViewController: UIViewController, UITextViewDelegate {
    private let reachabilityService = ReachabilityService()
    let solveService = SolveService()
    let ocrService = OCRService()
    
    let disposeBag = DisposeBag()
    
    var currentPopup: CNPPopupController!
    var connectionErrorShowing = false
    var popupBeforeConnectionError: CNPPopupController?
    
    var cameraView: CameraView!
    
    var multipleChoicePresenter: MultipleChoicePresenter!
    var actionSelector: MethodSelectionTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        multipleChoicePresenter = MultipleChoicePresenter(viewController: self, strategy: MultipleChoiceStrategy(), disposeBag: disposeBag)
        
        cameraView = CameraView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        cameraView.delegate = self
        
        view.addSubview(cameraView)
        
        addHelpButton()
        addActionSelector()
        
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

extension HomeViewController: CameraViewDelegate {
    
    func didTakeImage(croppedImage: UIImage) {
        let selectedAction = actionSelector.getSelectedAction()
        
        switch selectedAction {
        case .solveMath:
            break
        case .solveMultipleChoice:
            multipleChoicePresenter.processImage(image: croppedImage)
            break
        case .summarize:
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
