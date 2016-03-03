//
//  TrendingViewController.swift
//  Remix
//
//  Created by fong tinyik on 2/21/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit
import SDWebImage

class RMSecondFilteredViewController: CTFilteredViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = APPLICATION_UI_REMOTE_CONFIG.objectForKey("FilterLabel_2_Text") as? String
    }
    
    override func setUpParallaxHeaderView() {
        
        let headerView = ParallaxHeaderView.parallaxHeaderViewWithImage(UIImage(named: "SDPlaceholder"), forSize: CGSizeMake(UIScreen.mainScreen().bounds.width, 175)) as! ParallaxHeaderView
        let url = NSURL(string: (APPLICATION_UI_REMOTE_CONFIG.objectForKey("Filter_2_HeaderImage") as? BmobFile)!.url)
        let manager = SDWebImageManager()
        manager.downloadImageWithURL(url, options: .RetryFailed, progress: nil, completed: { (image, error, type, isSuccessful, url) -> Void in
            headerView.headerImage = image
        })
        
        headerView.headerTitleLabel.text = APPLICATION_UI_REMOTE_CONFIG.objectForKey("FilterLabel_2_Text") as? String
        self.tableView.tableHeaderView = headerView
        
    }
    
    override func fetchCloudData() {
        coverImgURLs = []
        
        //    dates = []
        monthNameStrings = []
        activities = []
        
        
        let query = BmobQuery(className: "Activity")
        query.whereKey("isVisibleOnFilterList_2", equalTo: true)
        query.whereKey("isVisibleToUsers", equalTo: true)
        query.whereKey("isFloatingActivity", equalTo: false)
        query.findObjectsInBackgroundWithBlock { (activities, error) -> Void in
            if activities.count > 0 {
                for activity in activities {
                    
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
            }
        }
        
        fetchLikedActivitiesList()
        
    }

}
