//
//  TutorialViewController.swift
//  Solvely
//
//  Created by Daniel Christopher on 8/24/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import UIKit

class TutorialViewController: UIPageViewController {
    private var orderedViewControllers: [UIViewController] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        
        let storyboard = UIStoryboard(name: "Landing", bundle: nil)
        
        let one = storyboard.instantiateViewControllerWithIdentifier("TutorialSlide") as! TutorialSlideViewController
        one.imageName = "one"
        one.text = "Hey, I’m Solvely!\nSnap a pic of your question and I'll solve it."
        
        let two = storyboard.instantiateViewControllerWithIdentifier("TutorialSlide") as! TutorialSlideViewController
        two.imageName = "two"
        two.text = "My eyes aren’t the best.\nPlease give me clear pictures."
        
        let three = storyboard.instantiateViewControllerWithIdentifier("TutorialSlide") as! TutorialSlideViewController
        three.imageName = "three"
        three.text = "I can't solve math problems...\n Give me your open ended and multiple choice questions!"
        
        self.orderedViewControllers.append(one)
        self.orderedViewControllers.append(two)
        self.orderedViewControllers.append(three)
        
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .Forward,
                               animated: true,
                               completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension TutorialViewController: UIPageViewControllerDataSource {

    func pageViewController(pageViewController: UIPageViewController,
                            viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.indexOf(viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(pageViewController: UIPageViewController,
                            viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.indexOf(viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return orderedViewControllers.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
}
