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
        return 4
    }
    
    func configurePage(cell: GHWalkThroughPageCell!, atIndex index: Int) {
        cell.title = "郭寒"
        //  cell.titleImage = UIImage(named: "Tech")
        cell.desc = "一半是激素，一半是情怀。 -- Inverse"
    }
    
    func bgImageforPage(index: Int) -> UIImage! {
        if index == 0 {
            return UIImage(named: "GuoHan")
        }
        if index == 1 {
            return UIImage(named: "Tech")
        }
        
        return UIImage(named: "630")
    }

    func walkthroughDidDismissView(walkthroughView: GHWalkThroughView!) {
         let storyboard = UIStoryboard(name: "Main", bundle: nil)
    print("Dismiss")
        let rootVC = storyboard.instantiateViewControllerWithIdentifier("RegLoginVC") as! RegLoginViewController
        self.presentViewController(rootVC, animated: false, completion: nil)

    }


}
