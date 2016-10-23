//
//  MethodSelectionView.swift
//  Solvely
//
//  Created by Daniel Christopher on 10/23/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import UIKit
import CNPPopupController

class MethodSelectionTableView: UITableView {
    let method_table_view_cell = "method_table_view_cell"
    let cancel_table_view_cell = "cancel_table_view_cell"
    let titleIndex = 1
    let imageIndex = 0
    var data: [[String]] = []
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        setup()
    }

    private func setup() {
        backgroundColor = UIColor.solvelyPrimaryBlue()
        separatorStyle = .none
        
        data.append(["Summarize", "Summarize"])
        data.append(["Define", "Define"])
        data.append(["Translate", "Translate"])
        data.append(["Solve", "Solve"])
        
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
        cell.title.text = data[indexPath.row][titleIndex]
        cell.contentView.backgroundColor = UIColor.solvelyPrimaryBlue().withAlphaComponent(0.75)
        cell.backgroundColor = UIColor.solvelyPrimaryBlue().withAlphaComponent(0.75)
        //cell.iconImageView.image = UIImage(named: data[indexPath.row][titleIndex])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func numberOfRows(inSection section: Int) -> Int {
        return data.count
    }
}

extension MethodSelectionTableView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return frame.height / CGFloat(data.count)
    }
}

extension MethodSelectionTableView: CNPPopupControllerDelegate {
    func popupControllerDidDismiss(_ controller: CNPPopupController) {
        
    }
    
    func popupControllerDidPresent(_ controller: CNPPopupController) {
        let tableViewInset: CGFloat = max((frame.height - contentSize.height) / 2.0, 0.0)
        contentInset = UIEdgeInsetsMake(tableViewInset, 0, -tableViewInset, 0)
    }
    
    func popupControllerWillDismiss(_ controller: CNPPopupController) {
        
    }
    
    func popupControllerWillPresent(_ controller: CNPPopupController) {
        
    }
}

