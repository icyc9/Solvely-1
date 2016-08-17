//
//  ConceptViewController.swift
//  Solvely
//
//  Created by Daniel Christopher on 8/5/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import UIKit

class ConceptCell: UITableViewCell {
    @IBOutlet weak var conceptLabel: UILabel!
    
}

class ConceptViewController: UITableViewController {
    var concepts: [BackgroundInfo]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.layer.cornerRadius = Radius.inputCornerRadius
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if concepts != nil {
            return concepts!.count
        }
        
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("concept_table_view_cell") as! ConceptCell
        cell.conceptLabel.text = concepts![indexPath.row].sentenceChunk
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedConcept = concepts![indexPath.row]
        
        let explainConceptViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("background_info") as! BackgroundInfoViewController
        
        explainConceptViewController.backgroundInfo = selectedConcept.backgroundInfoAboutChunk
        explainConceptViewController.topic = selectedConcept.sentenceChunk
        
        self.presentViewController(explainConceptViewController, animated: true, completion: nil)
    }
}

