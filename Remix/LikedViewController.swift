//
//  TestViewController.swift
//  Remix
//
//  Created by fong tinyik on 2/9/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit

class LikedViewController: CTFilteredViewController {

    var likedHeaderImage = UIImage(named: "LikedActivities")
 
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "我喜欢的活动"
    }
    
    override func setUpParallaxHeaderView() {
        let headerView = ParallaxHeaderView.parallaxHeaderViewWithImage(likedHeaderImage, forSize: CGSizeMake(UIScreen.mainScreen().bounds.width, 175)) as! ParallaxHeaderView
        self.tableView.tableHeaderView = headerView
        headerView.headerTitleLabel.text = "Liked Activities"
    }

    override func fetchCloudData() {
        coverImgURLs = []
        
        //    dates = []
        monthNameStrings = []
        activities = []
        
        if let _likedlist = currentUser.objectForKey("LikedActivities") as? [String] {
            likedActivitiesIds = _likedlist
        }
        
        var query = BmobQuery(className: "Activity")
        
        
        if let _likedlist = currentUser.objectForKey("LikedActivities") as? [String] {
            likedActivitiesIds = _likedlist
            
        }
        print(likedActivitiesIds)
        for likedActivityId in likedActivitiesIds {
            query.getObjectInBackgroundWithId(likedActivityId, block: { (activity, error) -> Void in
                if activity != nil {
                    let coverImg = activity.objectForKey("CoverImg") as! BmobFile
                    let imageURL = NSURL(string:coverImg.url)!
                    
                    let dateString = activity.objectForKey("Date") as! String
                    let monthName = dateString.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet())[0] + " " + dateString.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet())[2]
                    
                    if self.isMonthAdded(monthName) == false {
                        self.monthNameStrings.append(monthName)
                        self.activities.append([activity as! BmobObject])
                        self.coverImgURLs.append([imageURL])
                    } else {
                        
                        if let index = self.activities.indexOf({
                            
                            ($0[0].objectForKey("Date") as! String).componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet())[0] + " " + dateString.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet())[2] == monthName})
                        {
                            self.activities[index].append(activity as! BmobObject)
                            self.coverImgURLs[index].append(imageURL)
                        }
                        
                    }
                    self.tableView.reloadData()
                }
                
            })
        }
        
        
    }
    

}
