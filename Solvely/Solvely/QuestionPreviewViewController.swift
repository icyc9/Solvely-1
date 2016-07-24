//
//  QuestionPreviewViewController.swift
//  Solvely
//
//  Created by Daniel Christopher on 7/23/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import UIKit

class AnswerTableViewCell: UITableViewCell {
    @IBOutlet weak var answerChoiceLabel: UILabel!
    
    func selectAsAnswer() {
        self.contentView.backgroundColor = Colors.green
//        let checkImage = UIImageView(image: UIImage(named: "check"))
//        self.contentView.addSubview(checkImage)
//        self.contentView.addConstraint(NSLayoutConstraint(item: checkImage, attribute: .Left, relatedBy: .Equal, toItem: answerChoiceLabel, attribute: .Right, multiplier: 1, constant: 8))
//        
//        self.contentView.addConstraint(NSLayoutConstraint(item: checkImage, attribute: .Right, relatedBy: .Equal, toItem: self.contentView, attribute: .Right, multiplier: 1, constant: 8))
//            
//        self.contentView.addConstraint(NSLayoutConstraint(item: checkImage, attribute: .CenterY, relatedBy: .Equal, toItem: self.contentView, attribute: .CenterY, multiplier: 1, constant: 0))
    }
    
    func selectAsIncorrect() {
        self.contentView.backgroundColor = Colors.red
    }
}

class QuestionPreviewViewController: UIViewController {

    @IBOutlet weak var answersTableView: UITableView!
    
    @IBOutlet weak var solveButton: UIButton!
    
    @IBOutlet weak var solveAnotherButton: UIButton!
    
    @IBOutlet weak var solveLabelButton: UIButton!
    
    @IBOutlet weak var questionTextView: UITextView!
    
    private var answerChoices = ["A) India", "B) Pakistan", "C) Afghanistan", "D) Bolivia"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        answersTableView.delegate = self
        answersTableView.dataSource = self
        
        self.answersTableView.layer.cornerRadius = Radius.inputCornerRadius
        self.solveButton.layer.cornerRadius = 20
        self.solveButton.layer.borderWidth = 4
        self.solveButton.layer.borderColor = UIColor.whiteColor().CGColor
        self.solveButton.layer.masksToBounds = true
        
        self.questionTextView.layer.cornerRadius = Radius.inputCornerRadius
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func solveAnother(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func solve(sender: UIButton) {
        let correctAnswer = "C) Afghanistan"
        
        for answer in answerChoices {
            let cell = self.answersTableView.cellForRowAtIndexPath(NSIndexPath(forRow: answerChoices.indexOf(answer)!, inSection: 0)) as! AnswerTableViewCell
            if answer == correctAnswer {
                cell.selectAsAnswer()
            }
            else {
                cell.selectAsIncorrect()
            }
        }
        
        self.solveLabelButton.removeFromSuperview()
        self.solveButton.removeFromSuperview()
        self.solveAnotherButton.hidden = false
    }
}

extension QuestionPreviewViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return answerChoices.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("answer_cell") as! AnswerTableViewCell
        cell.answerChoiceLabel.text = answerChoices[indexPath.row] as String
        return cell
    }
}

extension QuestionPreviewViewController: UITableViewDelegate {
    
}
