//
//  CTFilteredViewController.swift
//  Remix
//
//  Created by fong tinyik on 2/6/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit
import SafariServices
import SDWebImage

class CTFilteredViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ActivityFilterDelegate, UIGestureRecognizerDelegate, MGSwipeTableCellDelegate, BmobPayDelegate {
  
    @IBOutlet weak var tableView: UITableView!
    
    var coverImgURLs: [[NSURL]] = []
    var activities: [[BmobObject]] = []
    var monthNameStrings: [String] = []
    var dateLabel: UILabel!
    var likedActivitiesIds: [String] = []

    var currentUser = BmobUser.getCurrentUser()

    var filterName: String = "Technology"
    var headerImage: UIImage!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCloudData()
        setUpParallaxHeaderView()
        self.navigationController?.navigationBar.tintColor = .whiteColor()
        self.title = filterName
     
   
    }
    
  
    
    func setUpParallaxHeaderView() {
        let headerView = ParallaxHeaderView.parallaxHeaderViewWithImage(headerImage, forSize: CGSizeMake(UIScreen.mainScreen().bounds.width, 175)) as! ParallaxHeaderView
        self.tableView.tableHeaderView = headerView
        headerView.headerTitleLabel.text = filterName

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
        
        
        let query = BmobQuery(className: "Activity")
        query.whereKey("Category", containedIn: [filterName])
        query.whereKey("isVisibleToUsers", equalTo: true)
        query.whereKey("isVisibleOnMainList", equalTo: true)
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
    
    func filterQueryWithCategoryOrLabelName(name: String) {
        filterName = name
    }
    
    func setParallaxHeaderImage(headerImageURL: NSURL) {
        let manager = SDWebImageManager()
        manager.downloadImageWithURL(headerImageURL, options: .RetryFailed, progress: nil) { (image, error, cachetype, finished, url) -> Void in
            if error == nil{
                self.headerImage = image
            }
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
                    return DEVICE_SCREEN_WIDTH
                }
            }
        }
        return 166
    }
    

    
     func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            
        }
    }
    
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (activities[indexPath.section][indexPath.row].objectForKey("isFeatured") as! Bool) == true {
            let cell = tableView.dequeueReusableCellWithIdentifier("fullCellReuseIdentifier", forIndexPath: indexPath) as! RMFullCoverCell
            cell.delegate = self
            cell.parentViewController = self
            if let price = activities[indexPath.section][indexPath.row].objectForKey("Price") as? Double {
                if price != 0 {
                    let priceNumberFont = UIFont.systemFontOfSize(19)
                    let attrDic1 = [NSFontAttributeName:priceNumberFont]
                    let priceString = NSMutableAttributedString(string: String(price), attributes: attrDic1)
                    let currencyFont = UIFont.systemFontOfSize(13)
                    let attrDic2 = [NSFontAttributeName:currencyFont]
                    let currencyString = NSMutableAttributedString(string: "元/人", attributes: attrDic2)
                    priceString.appendAttributedString(currencyString)
                    cell.priceTag.attributedText = priceString
                
                }else{
                    cell.priceTag.text = "免费"
                   
                }
            }

            cell.titleLabel.text = activities[indexPath.section][indexPath.row].objectForKey("Title") as? String
            cell.orgLabel.text = activities[indexPath.section][indexPath.row].objectForKey("Org") as? String
            cell.timeLabel.text = activities[indexPath.section][indexPath.row].objectForKey("Date") as? String
            cell.likesNumberLabel.text = String(activities[indexPath.section][indexPath.row].objectForKey("LikesNumber") as! Int)
            cell.fullImageView.sd_setImageWithURL(coverImgURLs[indexPath.section][indexPath.row], placeholderImage: UIImage(named: "SDPlaceholder"))
            let _objId = activities[indexPath.section][indexPath.row].objectId
            cell.objectId = _objId
            let query = BmobQuery(className: "Organization")
            query.whereKey("Name", equalTo: cell.orgLabel.text)
            query.findObjectsInBackgroundWithBlock({ (organizations, error) -> Void in
                if error == nil {
                    for org in organizations {
                        let url = NSURL(string: (org.objectForKey("Logo") as! BmobFile).url)
                        cell.orgLogo.sd_setImageWithURL(url, placeholderImage: UIImage(named: "SDPlaceholder"))
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
        cell.parentViewController = self
        if let price = activities[indexPath.section][indexPath.row].objectForKey("Price") as? Double {
            if price != 0 {
                let priceNumberFont = UIFont.systemFontOfSize(19)
                let attrDic1 = [NSFontAttributeName:priceNumberFont]
                let priceString = NSMutableAttributedString(string: String(price), attributes: attrDic1)
                let currencyFont = UIFont.systemFontOfSize(13)
                let attrDic2 = [NSFontAttributeName:currencyFont]
                let currencyString = NSMutableAttributedString(string: "元/人", attributes: attrDic2)
                priceString.appendAttributedString(currencyString)
                cell.priceTag.attributedText = priceString
        
            }else{
                cell.priceTag.text = "免费"
       
            }
        }

        cell.titleLabel.text = activities[indexPath.section][indexPath.row].objectForKey("Title") as? String
        cell.desLabel.text = activities[indexPath.section][indexPath.row].objectForKey("Description") as? String
        cell.orgLabel.text = activities[indexPath.section][indexPath.row].objectForKey("Org") as? String
        cell.timeLabel.text = activities[indexPath.section][indexPath.row].objectForKey("Date") as? String
        cell.likesNumberLabel.text = String(activities[indexPath.section][indexPath.row].objectForKey("LikesNumber") as! Int)
        cell.themeImg.sd_setImageWithURL(coverImgURLs[indexPath.section][indexPath.row], placeholderImage: UIImage(named: "SDPlaceholder"))
        let _objId = activities[indexPath.section][indexPath.row].objectId
        cell.objectId = _objId
        let query = BmobQuery(className: "Organization")
        query.whereKey("Name", equalTo: cell.orgLabel.text)
        query.findObjectsInBackgroundWithBlock({ (organizations, error) -> Void in
            if error == nil {
                for org in organizations {
                    let url = NSURL(string: (org.objectForKey("Logo") as! BmobFile).url)
                    cell.orgLogo.sd_setImageWithURL(url, placeholderImage: UIImage(named: "SDPlaceholder"))
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
    
    
    func presentSettingsVC() {
        let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let settingsVC = storyBoard.instantiateViewControllerWithIdentifier("SettingsVC")
        let navigationController = UINavigationController(rootViewController: settingsVC)
        self.navigationController?.presentViewController(navigationController, animated: true, completion: nil)
        
    }


    
     func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let query = BmobQuery(className: "Activity")
        let objectId = activities[indexPath.section][indexPath.row].objectId
        query.getObjectInBackgroundWithId(objectId) { (activity, error) -> Void in
            activity.incrementKey("PageView", byAmount: 1)
            activity.updateInBackground()
        }
       
            let activityView = RMActivityViewController(url: NSURL(string: activities[indexPath.section][indexPath.row].objectForKey("URL") as! String)!)
            activityView.activity = activities[indexPath.section][indexPath.row]
            self.navigationController?.pushViewController(activityView, animated: true)
        
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let header: ParallaxHeaderView = tableView.tableHeaderView as! ParallaxHeaderView
        header.layoutHeaderViewForScrollViewOffset(scrollView.contentOffset)
        
//        self.tableView.tableHeaderView = header
    }
    
    

    
}
