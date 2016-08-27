//
//  AnswerViewController.swift
//  Solvely
//
//  Created by Daniel Christopher on 8/5/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

//
//  ResultsViewController.swift
//  Solvely
//
//  Created by Daniel Christopher on 7/25/16.
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

class AnswerViewController: UIViewController {
    
    @IBOutlet weak var answersTableView: UITableView!
    
    @IBOutlet weak var solveAnotherButton: UIButton!
    
    @IBOutlet weak var questionTextView: UITextView!
    
    var answer: SolveResult!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        answersTableView.delegate = self
        answersTableView.dataSource = self
        
        answersTableView.reloadData()
        showResults()
        
        self.answersTableView.layer.cornerRadius = Radius.inputCornerRadius
        self.solveAnotherButton.layer.cornerRadius = Radius.buttonCornerRadius
        self.questionTextView.layer.cornerRadius = Radius.inputCornerRadius
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func solveAnother(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func showResults() {
        if answer != nil {
            //questionTextView.text = answer!.question?.questionText
            
            var index = 0
            if answer!.answerChoices != nil {
                for choice in answer.answerChoices! {
                    let cell = self.answersTableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) as! AnswerTableViewCell
                    if choice.correctAnswer != nil && choice.correctAnswer! {
                        cell.selectAsAnswer()
                    }
                    else {
                        cell.selectAsIncorrect()
                    }
                    index = index + 1
                }
            }
            self.solveAnotherButton.hidden = false
        }
    }
}

extension AnswerViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if answer != nil && answer.answerChoices != nil {
            return answer.answerChoices!.count
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("answer_cell") as! AnswerTableViewCell
        cell.answerChoiceLabel.text = answer.answerChoices![indexPath.row].answerText
        return cell
    }
}

extension AnswerViewController: UITableViewDelegate {
    
}