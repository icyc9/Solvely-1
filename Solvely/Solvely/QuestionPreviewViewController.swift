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
}

class QuestionPreviewViewController: UIViewController {

    @IBOutlet weak var answersTableView: UITableView!
    
    private var answerChoices = ["A) India", "B) Pakistan", "C) Afghanistan", "D) Bolivia"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        answersTableView.delegate = self
        answersTableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
