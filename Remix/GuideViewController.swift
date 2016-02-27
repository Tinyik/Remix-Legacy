//
//  GuideViewController.swift
//  Remix
//
//  Created by fong tinyik on 2/15/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit

class GuideViewController: UIViewController, GHWalkThroughViewDataSource, GHWalkThroughViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        let RMWalkThroughView = GHWalkThroughView(frame: self.view.bounds)
        RMWalkThroughView.dataSource = self
        RMWalkThroughView.delegate = self
        RMWalkThroughView.walkThroughDirection = .Horizontal
        RMWalkThroughView.showInView(self.view, animateDuration: 0.3)
            }

    func numberOfPages() -> Int {
        return 5
    }
    
    func configurePage(cell: GHWalkThroughPageCell!, atIndex index: Int) {
        cell.title = ""
        //  cell.titleImage = UIImage(named: "Tech")
        cell.desc = ""
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func bgImageforPage(index: Int) -> UIImage! {
        if index == 0 {
            return UIImage(named: "as1")
        }
        if index == 1 {
            return UIImage(named: "as2")
        }
        if index == 2 {
            return UIImage(named: "as3")
        }
        if index == 3 {
            return UIImage(named: "as4")
        }
        if index == 4 {
            return UIImage(named: "as5")
        }
        return nil
    }

    func walkthroughDidDismissView(walkthroughView: GHWalkThroughView!) {
         let storyboard = UIStoryboard(name: "Main", bundle: nil)
    print("Dismiss")
        if BmobUser.getCurrentUser() == nil {
        let rootVC = storyboard.instantiateViewControllerWithIdentifier("RegLoginVC") as! RegLoginViewController
        self.presentViewController(rootVC, animated: false, completion: nil)
        }else{
            self.dismissViewControllerAnimated(true, completion: nil)
        }

    }


}
