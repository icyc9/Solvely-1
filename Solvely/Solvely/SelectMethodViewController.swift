//
//  SelectMethodViewController.swift
//  Solvely
//
//  Created by Daniel Christopher on 8/20/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import UIKit

class MethodCell: UICollectionViewCell {
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var name: UILabel!
    
}

class SelectMethodViewController: UICollectionViewController {
    
    private let text = "text"
    private let camera = "camera"
    private let gallery = "gallery"
    private let voice = "voice"
    
    private var options: [String]!
    
    let cellName: String = "MethodCell"
    var initialScrollDone: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        options = [text, camera, voice]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLayoutSubviews() {
        if !self.initialScrollDone {
            self.initialScrollDone = true;
            
            let index = NSIndexPath(forItem: 1, inSection: 0)
            
            self.collectionView?.scrollToItemAtIndexPath(index, atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: false)
        }
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellName, forIndexPath: indexPath) as! MethodCell
        
        cell.useRoundedCorners()
        
        let bounds = UIScreen.mainScreen().bounds
        
        cell.frame = CGRectMake(cell.frame.origin.x + (bounds.width * 0.8), cell.frame.origin.y, bounds.width * 0.8, cell.frame.size.height)
        
        let type = options[indexPath.row]
        
        switch type {
        case text:
            cell.name.text = "Text"
            cell.icon.image = UIImage(named: "gallery")
            break
        case camera:
            cell.name.text = "Camera"
            cell.icon.image = UIImage(named: "camera")
            break
        case voice:
            cell.name.text = "Voice"
            cell.icon.image = UIImage(named: "microphone")
            break
        default:
            break
        }
        
        return cell
    }
}
