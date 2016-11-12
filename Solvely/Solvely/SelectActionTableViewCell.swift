//
//  SelectActionTableViewCell.swift
//  Solvely
//
//  Created by Daniel Christopher on 11/5/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import Foundation

protocol SelectActionHeaderCellDelegate {
    func didTouch()
}

class SelectActionHeaderCell: UITableViewCell {
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var selectedActionView: UIView!
    @IBOutlet weak var selectedActionLabel: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!
    var touchDelegate: SelectActionHeaderCellDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    private func setup() {
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SelectActionHeaderCell.touch)))
    }
    
    func touch() {
        if touchDelegate != nil {
            touchDelegate!.didTouch()
        }
    }
}
