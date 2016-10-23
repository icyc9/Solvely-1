//
//  MethodTableViewCell.swift
//  Solvely
//
//  Created by Daniel Christopher on 10/23/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import UIKit

class MethodTableViewCell: UITableViewCell {
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var title: UILabel!
   // @IBOutlet weak var iconImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
