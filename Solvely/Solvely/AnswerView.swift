//
//  AnswerView.swift
//  Solvely
//
//  Created by Daniel Christopher on 8/30/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import UIKit

class AnswerView: UIView {
    @IBOutlet weak var content: UIView?
    @IBOutlet weak var answerLetter: UILabel!
    @IBOutlet weak var answerText: UITextView!
    
    override init(frame : CGRect) {
        super.init(frame: frame)
        NSBundle.mainBundle().loadNibNamed("Answer", owner: self, options: nil)
        self.addSubview(self.content!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NSBundle.mainBundle().loadNibNamed("Answer", owner: self, options: nil)
        self.addSubview(self.content!)
    }
    
}
