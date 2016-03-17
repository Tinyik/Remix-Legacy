//
//  LabelFilteredViewController.swift
//  Remix
//
//  Created by fong tinyik on 2/13/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit
import TTGSnackbar

class LabelFilteredViewController: CTFilteredViewController {

    

override func fetchCloudData() {
        coverImgURLs = []
        
        //    dates = []
        monthNameStrings = []
        activities = []
        
        
        let query = AVQuery(className: "Activity")
        query.whereKey("Labels", containedIn: [filterName])
        query.whereKey("isVisibleToUsers", equalTo: true)
    query.whereKey("isFloatingActivity", equalTo: false)
    query.whereKey("Cities", containedIn: [REMIX_CITY_NAME])
        query.findObjectsInBackgroundWithBlock { (activities, error) -> Void in
            if error == nil {
                if activities.count > 0 {
                    for activity in activities {
                        
                        let coverImg = activity.objectForKey("CoverImg") as! AVFile
                        let imageURL = NSURL(string:coverImg.url)!
                        
                        let dateString = activity.objectForKey("Date") as! String
                        let monthName = dateString.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet())[0] + " " + dateString.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet())[2]
                        if self.isMonthAdded(monthName) == false {
                            self.monthNameStrings.append(monthName)
                            self.activities.append([activity as! AVObject])
                            self.coverImgURLs.append([imageURL])
                        } else {
                            
                            if let index = self.activities.indexOf({
                                
                                ($0[0].objectForKey("Date") as! String).componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet())[0] + " " + dateString.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet())[2] == monthName})
                            {
                                self.activities[index].append(activity as! AVObject)
                                self.coverImgURLs[index].append(imageURL)
                            }
                            
                        }
                        
                        
                        
                        self.tableView.reloadData()
                    }
                }
            }else{
                let snackBar = TTGSnackbar.init(message: "获取数据失败。请检查网络连接后重试。", duration: .Middle)
                snackBar.backgroundColor = FlatWatermelonDark()
                snackBar.show()
            }
           
        }
        
       fetchLikedActivitiesList()
    }
    


}
