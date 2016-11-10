//
//  MethodSelectionView.swift
//  Solvely
//
//  Created by Daniel Christopher on 10/23/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import UIKit
import CNPPopupController

enum SolvelyAction {
    case summarize
    case solveMath
    case solveOpenEnded
    case solveMultipleChoice
    case none
}

class MethodSelectionTableView: UITableView {
    let method_table_view_cell = "method_table_view_cell"
    let cancel_table_view_cell = "cancel_table_view_cell"
    let titleIndex = 1
    let imageIndex = 0
    var originalHeight: CGFloat?
    var collapsed = false
    var selectedRow: Int?
    var items = ["What do you want help with?", "Summarize Text", "Solve Math", "Solve Open Ended", "Solve Multiple Choice"]
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        
        originalHeight = frame.height
        
        self.frame = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: frame.height)
        
        setup()
    }
    
    func getSelectedAction() -> SolvelyAction {
        switch selectedRow! {
        case 1:
            return SolvelyAction.summarize
        case 2:
            return SolvelyAction.solveMath
        case 3:
            return SolvelyAction.solveOpenEnded
        case 4:
            return SolvelyAction.solveMultipleChoice
        default:
            return SolvelyAction.none
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        setup()
    }

    private func setup() {
        isScrollEnabled = false
        
        backgroundColor = UIColor.black.withAlphaComponent(0)
        separatorStyle = .none
        
        let nib = UINib(nibName: "MethodTableViewCell", bundle: nil)
        register(nib, forCellReuseIdentifier: method_table_view_cell)
        
        let cancelNib = UINib(nibName: "CancelTableViewCell", bundle: nil)
        register(cancelNib, forCellReuseIdentifier: cancel_table_view_cell)
        
        delegate = self
        dataSource = self
    }
}

extension MethodSelectionTableView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: method_table_view_cell) as! MethodTableViewCell
        cell.title.text = items[indexPath.row]
        cell.contentView.backgroundColor = UIColor.solvelyPrimaryBlue().withAlphaComponent(0.75)
        cell.backgroundColor = UIColor.solvelyPrimaryBlue().withAlphaComponent(0.75)
        
        if indexPath.row > 0 {
            cell.view.backgroundColor = UIColor.white
            cell.title.textColor = UIColor.solvelyPrimaryBlue().withAlphaComponent(0.75)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

extension MethodSelectionTableView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (self.frame.height / 2) / CGFloat(items.count)
    }
  
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if collapsed == true {
            collapsed = false
            UIView.animate(withDuration: 0.1, animations: { () -> Void in
                self.frame = CGRect(x: self.frame.minX, y: self.frame.minY, width: self.frame.width, height: self.originalHeight!)
                self.layoutIfNeeded()
            })
        }
        else {
            selectedRow = indexPath.row
            collapsed = true
            UIView.animate(withDuration: 0.1, animations: { () -> Void in
                self.frame = CGRect(x: self.frame.minX, y: self.frame.minY, width: self.frame.width, height: (self.originalHeight! / 2) / CGFloat(self.items.count))
                self.layoutIfNeeded()
            })
        }
    }
}
