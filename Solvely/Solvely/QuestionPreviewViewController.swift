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
    }
}

class QuestionPreviewViewController: UIViewController {

    @IBOutlet weak var answersTableView: UITableView!
    
    @IBOutlet weak var solveButton: UIButton!
    
    private var answerChoices = ["A) India", "B) Pakistan", "C) Afghanistan", "D) Bolivia"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        answersTableView.delegate = self
        answersTableView.dataSource = self
        
        self.solveButton.layer.cornerRadius = 20
        
        self.solveButton.layer.borderWidth = 4
        
        self.solveButton.layer.borderColor = UIColor.whiteColor().CGColor
        
        self.solveButton.layer.masksToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func solve(sender: UIButton) {
        let answer = "C) Afghanistan"
        
        let answerCell = self.answersTableView.cellForRowAtIndexPath(NSIndexPath(forRow: answerChoices.indexOf(answer)!, inSection: 0)) as! AnswerTableViewCell
        
        answerCell.selectAsAnswer()
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
