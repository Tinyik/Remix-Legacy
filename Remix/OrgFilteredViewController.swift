//
//  OrgFilteredViewController.swift
//  Remix
//
//  Created by fong tinyik on 2/10/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit
import SafariServices

class OrgFilteredViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, MGSwipeTableCellDelegate, OrganizationViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var coverImgURLs: [[NSURL]] = []
    var activities: [[BmobObject]] = []
    var monthNameStrings: [String] = []
    var dateLabel: UILabel!
    var likedActivitiesIds: [String] = []
    var currentUser = BmobUser.getCurrentUser()
    
    var orgName: String = "BookyGreen"
    var headerImage: UIImage!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCloudData()
        let moreInfo = UIButton(type: .InfoDark)
        moreInfo.setTitle("简介", forState: .Normal)
        moreInfo.tintColor = .blackColor()
        moreInfo.addTarget(self, action: "showOrgIntroView", forControlEvents: .TouchUpInside)
        let backButton = UIButton(frame: CGRectMake(0,0,30,30))
        backButton.setImage(UIImage(named: "back"), forState: .Normal)
        backButton.addTarget(self, action: "popCurrentVC", forControlEvents: .TouchUpInside)
        let backItem = UIBarButtonItem(customView: backButton)
        let moreInfoItem = UIBarButtonItem(customView: moreInfo)
        self.navigationItem.leftBarButtonItem = backItem
        self.navigationItem.rightBarButtonItem = moreInfoItem
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.title = orgName
        setParallaxHeaderImage()
        self.navigationController?.navigationBar.translucent = false
        
        
    }
    
    func setUpParallaxHeaderView() {
        let headerView = ParallaxHeaderView.parallaxHeaderViewWithImage(headerImage, forSize: CGSizeMake(UIScreen.mainScreen().bounds.width, 250)) as! ParallaxHeaderView
        self.tableView.tableHeaderView = headerView
//        headerView.headerTitleLabel.text = orgName
        
    }
    
    override func viewDidAppear(animated: Bool) {
        (tableView.tableHeaderView as! ParallaxHeaderView).refreshBlurViewForNewImage()
        super.viewDidAppear(animated)
    }
    
    
    func popCurrentVC() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func fetchCloudData() {
        coverImgURLs = []
        
        //    dates = []
        monthNameStrings = []
        activities = []
        
        
        var query = BmobQuery(className: "Activity")
        query.whereKey("Org", equalTo: orgName)
        query.whereKey("isVisibleToUsers", equalTo: true)
        query.whereKey("isVisibleOnMainList", equalTo: true)
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
        
        if let _likedlist = currentUser.objectForKey("LikedActivities") as? [String] {
            likedActivitiesIds = _likedlist
        }
        
    }
    
    func isMonthAdded(monthName: String) -> Bool {
        
        for _date in monthNameStrings {
            if _date == monthName {
                return true
            }
        }
        return false
    }
    
    // Delegate Methods
    
    func filterQueryWithOrganizationName(name: String) {
        orgName = name
        print(orgName)
    }
    
    func setParallaxHeaderImage() {
        let query = BmobQuery(className: "Organization")
        query.whereKey("Name", equalTo: orgName)
        query.findObjectsInBackgroundWithBlock { (organizations, error) -> Void in
            if error == nil {
                for org in organizations {
                    if let urlString = org.objectForKey("HomePageCoverImage") as? BmobFile {
                        let url = NSURL(string: urlString.url)
                        let manager = SDWebImageManager()
                        manager.downloadImageWithURL(url, options: .RetryFailed, progress: nil) { (image, error, cachetype, finished, url) -> Void in
                            if error == nil{
                                self.headerImage = image
                                self.setUpParallaxHeaderView()
                            }else{
                                self.headerImage = UIImage(named: "Logo")
                                self.setUpParallaxHeaderView()
                            }
                        }
                    }else {
                        if let urlString = org.objectForKey("Logo") as? BmobFile {
                            let url = NSURL(string: urlString.url)
                            let manager = SDWebImageManager()
                            manager.downloadImageWithURL(url, options: .RetryFailed, progress: nil) { (image, error, cachetype, finished, url) -> Void in
                                if error == nil{
                                    self.headerImage = image
                                    self.setUpParallaxHeaderView()
                                }else{
                                    self.headerImage = UIImage(named: "Logo")
                                    self.setUpParallaxHeaderView()
                                }
                            }
                    }
                }
                
                }
            }else{
                self.headerImage = UIImage(named: "Logo")
                self.setUpParallaxHeaderView()
            }
        
        }
    }
    
    
    
    
    func swipeTableCell(cell: MGSwipeTableCell!, swipeButtonsForDirection direction: MGSwipeDirection, swipeSettings: MGSwipeSettings!, expansionSettings: MGSwipeExpansionSettings!) -> [AnyObject]! {
        
        swipeSettings.transition = .Border
        expansionSettings.fillOnTrigger = false
        expansionSettings.threshold = 1.5
        expansionSettings.buttonIndex = 1
        var likeButtonTitle: String!
        if let _cell = cell as? RMTableViewCell {
            likeButtonTitle = _cell.likeButtonTitle
        }
        if let _cell = cell as? RMFullCoverCell {
            likeButtonTitle = _cell.likeButtonTitle
        }
        
        if direction == .RightToLeft {
            
            
            let shareButton = MGSwipeButton(title: "Share", backgroundColor: UIColor(white: 0.95, alpha: 1), callback: { (sender) -> Bool in
                
                let indexPath = self.tableView.indexPathForCell(cell)
                let activity = self.activities[indexPath!.section][indexPath!.row]
                let coverImageURL = self.coverImgURLs[indexPath!.section][indexPath!.row]
                let shareText = "Remix活动推荐: " + (activity.objectForKey("Title") as! String)
                let manager = SDWebImageManager()
                manager.downloadImageWithURL(coverImageURL, options: .RetryFailed, progress: nil, completed: { (coverImage, error, cache, finished, url) -> Void in
                    if error == nil {
                        let url = activity.objectForKey("URL") as! String
                        let handler = UMSocialWechatHandler.setWXAppId("wx6e2c22b24588e0e1", appSecret: "e085edb726c5b92bf443f1e3da3f838e", url: url)
                        UMSocialSnsService.presentSnsIconSheetView(self, appKey: "56ba8fa2e0f55a1071000931", shareText: shareText, shareImage: coverImage, shareToSnsNames: [UMShareToWechatSession,UMShareToWechatTimeline, UMShareToQQ, UMShareToQzone, UMShareToTwitter], delegate: nil)
                    }
                })
                
                return true
            })
            
            let likeButton = MGSwipeButton(title: likeButtonTitle, backgroundColor: UIColor(white: 0.9, alpha: 1), callback: { (sender) -> Bool in
                if let _cell = sender as? RMTableViewCell {
                    _cell.isLiked = !(sender as! RMTableViewCell).isLiked
                    if _cell.isLiked == true {
                        self.likedActivitiesIds.append(_cell.objectId)
                        _cell.likesNumberLabel.text = String(Int(_cell.likesNumberLabel.text!)! + 1)
                        let query = BmobQuery(className: "Activity")
                        query.getObjectInBackgroundWithId(_cell.objectId, block: { (activity, error) -> Void in
                            activity.incrementKey("LikesNumber", byAmount: 1)
                            activity.updateInBackground()
                        })
                    }else{
                        if let index = self.likedActivitiesIds.indexOf(_cell.objectId) {
                            self.likedActivitiesIds.removeAtIndex(index)
                            _cell.likesNumberLabel.text = String(Int(_cell.likesNumberLabel.text!)! - 1)
                            let query = BmobQuery(className: "Activity")
                            query.getObjectInBackgroundWithId(_cell.objectId, block: { (activity, error) -> Void in
                                activity.decrementKey("LikesNumber", byAmount: 1)
                                activity.updateInBackground()
                            })
                        }
                    }
                    self.currentUser.setObject(self.likedActivitiesIds, forKey: "LikedActivities")
                    self.currentUser.updateInBackground()
                    
                    
                }
                if let _cell = sender as? RMFullCoverCell {
                    _cell.isLiked = !(sender as! RMFullCoverCell).isLiked
                    if _cell.isLiked == true {
                        self.likedActivitiesIds.append(_cell.objectId)
                        _cell.likesNumberLabel.text = String(Int(_cell.likesNumberLabel.text!)! + 1)
                        let query = BmobQuery(className: "Activity")
                        query.getObjectInBackgroundWithId(_cell.objectId, block: { (activity, error) -> Void in
                            activity.incrementKey("LikesNumber", byAmount: 1)
                            activity.updateInBackground()
                        })
                    }else{
                        if let index = self.likedActivitiesIds.indexOf(_cell.objectId) {
                            self.likedActivitiesIds.removeAtIndex(index)
                            _cell.likesNumberLabel.text = String(Int(_cell.likesNumberLabel.text!)! - 1)
                            let query = BmobQuery(className: "Activity")
                            query.getObjectInBackgroundWithId(_cell.objectId, block: { (activity, error) -> Void in
                                activity.decrementKey("LikesNumber", byAmount: 1)
                                activity.updateInBackground()
                            })
                        }
                    }
                    self.currentUser.setObject(self.likedActivitiesIds, forKey: "LikedActivities")
                    self.currentUser.updateInBackground()
                }
                if let _cell = cell as? RMTableViewCell {
                    cell.rightButtons[1].setTitle(_cell.likeButtonTitle, forState: .Normal)
                }
                if let _cell = cell as? RMFullCoverCell {
                    cell.rightButtons[1].setTitle(_cell.likeButtonTitle, forState: .Normal)
                }
                return true
            })
            
            shareButton.setTitleColor(.blackColor(), forState: .Normal)
            return [shareButton, likeButton] }else{
            return  nil
        }
        
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return activities[section].count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return monthNameStrings.count
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let dateHeaderView = UIView(frame: CGRectMake(30,0,UIScreen.mainScreen().bounds.width, 50))
        
        dateHeaderView.backgroundColor = .whiteColor()
        dateHeaderView.layer.shadowColor = UIColor.blackColor().CGColor
        dateHeaderView.layer.shadowOpacity = 0.08
        dateHeaderView.layer.shadowOffset = CGSizeMake(0, 0.7)
        dateLabel = UILabel(frame: CGRectMake(0,0,300,390))
        dateLabel.text = monthNameStrings[section]
        dateLabel.font = UIFont.systemFontOfSize(19)
        dateLabel.sizeToFit()
        dateHeaderView.addSubview(dateLabel)
        dateLabel.center = dateHeaderView.center
        dateLabel.center.x = UIScreen.mainScreen().bounds.width/2
        return dateHeaderView
        
        
    }
    
    
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return  53
    }
    
    
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if activities.count > 0 {
            if let isFeatured = activities[indexPath.section][indexPath.row].objectForKey("isFeatured") as? Bool  {
                if isFeatured == true {
                    return 375
                }
            }
        }
        return 138
    }
    
    
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (activities[indexPath.section][indexPath.row].objectForKey("isFeatured") as! Bool) == true {
            let cell = tableView.dequeueReusableCellWithIdentifier("fullCellReuseIdentifier", forIndexPath: indexPath) as! RMFullCoverCell
            cell.delegate = self
            cell.titleLabel.text = activities[indexPath.section][indexPath.row].objectForKey("Title") as! String
            cell.orgLabel.text = activities[indexPath.section][indexPath.row].objectForKey("Org") as! String
            cell.timeLabel.text = activities[indexPath.section][indexPath.row].objectForKey("Date") as! String
            cell.likesNumberLabel.text = String(activities[indexPath.section][indexPath.row].objectForKey("LikesNumber") as! Int)
            cell.fullImageView.sd_setImageWithURL(coverImgURLs[indexPath.section][indexPath.row])
            let _objId = activities[indexPath.section][indexPath.row].objectId
            cell.objectId = _objId
            let query = BmobQuery(className: "Organization")
            query.whereKey("Name", equalTo: cell.orgLabel.text)
            query.findObjectsInBackgroundWithBlock({ (organizations, error) -> Void in
                if error == nil {
                    for org in organizations {
                        let url = NSURL(string: (org.objectForKey("Logo") as! BmobFile).url)
                        cell.orgLogo.sd_setImageWithURL(url)
                    }
                }
            })
            if likedActivitiesIds.contains(_objId) {
                cell.isLiked = true
            }else{
                cell.isLiked = false
            }
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! RMTableViewCell
        cell.delegate = self
        cell.titleLabel.text = activities[indexPath.section][indexPath.row].objectForKey("Title") as! String
        cell.desLabel.text = activities[indexPath.section][indexPath.row].objectForKey("Description") as! String
        cell.orgLabel.text = activities[indexPath.section][indexPath.row].objectForKey("Org") as! String
        cell.timeLabel.text = activities[indexPath.section][indexPath.row].objectForKey("Date") as! String
        cell.likesNumberLabel.text = String(activities[indexPath.section][indexPath.row].objectForKey("LikesNumber") as! Int)
        cell.themeImg.sd_setImageWithURL(coverImgURLs[indexPath.section][indexPath.row])
        let _objId = activities[indexPath.section][indexPath.row].objectId
        cell.objectId = _objId
        let query = BmobQuery(className: "Organization")
        query.whereKey("Name", equalTo: cell.orgLabel.text)
        query.findObjectsInBackgroundWithBlock({ (organizations, error) -> Void in
            if error == nil {
                for org in organizations {
                    let url = NSURL(string: (org.objectForKey("Logo") as! BmobFile).url)
                    cell.orgLogo.sd_setImageWithURL(url)
                }
            }
        })
        if likedActivitiesIds.contains(_objId) {
            cell.isLiked = true
        }else{
            cell.isLiked = false
        }
        return cell
    }
    
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        var query = BmobQuery(className: "Activity")
        let objectId = activities[indexPath.section][indexPath.row].objectId
        query.getObjectInBackgroundWithId(objectId) { (activity, error) -> Void in
            activity.incrementKey("PageView", byAmount: 1)
            activity.updateInBackground()
        }
        if #available(iOS 9.0, *) {
            let safariView = SFSafariViewController(URL: NSURL(string: activities[indexPath.section][indexPath.row].objectForKey("URL") as! String)!, entersReaderIfAvailable: true)
            
            
            safariView.view.tintColor = UIColor(red: 74/255, green: 144/255, blue: 224/255, alpha: 1)
            self.navigationController?.presentViewController(safariView, animated: true, completion: nil)
        } else {
            let webView = RxWebViewController(url: NSURL(string: activities[indexPath.section][indexPath.row].objectForKey("URL") as! String)!)
            self.navigationController?.pushViewController(webView, animated: true)
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let header: ParallaxHeaderView = tableView.tableHeaderView as! ParallaxHeaderView
        header.layoutHeaderViewForScrollViewOffset(scrollView.contentOffset)
        
        //        self.tableView.tableHeaderView = header
    }
    
    func showOrgIntroView() {
        self.performSegueWithIdentifier("showOrgIntro", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showOrgIntro" {
            if let introView = segue.destinationViewController as? OrgIntroViewController {
                introView.orgName = self.orgName
            }
        }
    }
    
    
}
