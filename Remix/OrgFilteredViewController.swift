//
//  OrgFilteredViewController.swift
//  Remix
//
//  Created by fong tinyik on 2/10/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit
import SafariServices
import SDWebImage
import MessageUI

class OrgFilteredViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MGSwipeTableCellDelegate, OrganizationViewDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var coverImgURLs: [[NSURL]] = []
    var activities: [[BmobObject]] = []
    var monthNameStrings: [String] = []
    var dateLabel: UILabel!
    var likedActivitiesIds: [String] = []
    var currentUser = BmobUser.getCurrentUser()
    var orgName: String = "BookyGreen"
    var headerImage: UIImage!
    var headerImageLoaded = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCloudData()
        self.navigationController?.navigationBar.tintColor = .whiteColor()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "关于我们", style: .Plain, target: self, action: "showOrgIntroView")
        self.title = orgName
        self.tableView.emptyDataSetDelegate = self
        self.tableView.emptyDataSetSource = self
        self.tableView.tableFooterView = UIView()
        setUpParallaxHeaderView()
        setParallaxHeaderImage()
        
        
    }
    
   
    
    func setUpParallaxHeaderView() {
        if headerImageLoaded == true {
        let headerView = ParallaxHeaderView.parallaxHeaderViewWithImage(headerImage, forSize: CGSizeMake(UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.width*0.667)) as! ParallaxHeaderView
        self.tableView.tableHeaderView = headerView
        }else{
            let headerView = ParallaxHeaderView.parallaxHeaderViewWithImage(UIImage(named: "SDPlaceholder"), forSize: CGSizeMake(UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.width*0.667)) as! ParallaxHeaderView
            self.tableView.tableHeaderView = headerView
        }
        
//        headerView.headerTitleLabel.text = orgName
        
    }
    
    override func viewDidAppear(animated: Bool) {
        if let headerView = tableView.tableHeaderView as? ParallaxHeaderView {
            headerView.refreshBlurViewForNewImage()
        }
        
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
        query.whereKey("Org", equalTo: orgName)
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
                                self.headerImageLoaded = true
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
                                    self.headerImageLoaded = true
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
    
    
    
    
    
    func presentSettingsVC() {
        let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let settingsVC = storyBoard.instantiateViewControllerWithIdentifier("SettingsVC")
        let navigationController = UINavigationController(rootViewController: settingsVC)
        self.navigationController?.presentViewController(navigationController, animated: true, completion: nil)
        
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
    
    //DZNEmptyDataSet
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        
        let attrDic = [NSFontAttributeName: UIFont.systemFontOfSize(16)]
        return NSAttributedString(string: "\n\n\n\n\n\n\n\n\n\n\n\nOops. 这个组织还没有发布活动。以后再来看看吧~\n", attributes: attrDic)
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let attrDic = [NSFontAttributeName: UIFont.systemFontOfSize(15)]
        return NSAttributedString(string: "不过，你可以:", attributes: attrDic)
    }
    
    func buttonTitleForEmptyDataSet(scrollView: UIScrollView!, forState state: UIControlState) -> NSAttributedString! {
        let attrDic = [NSFontAttributeName: UIFont.systemFontOfSize(16), NSForegroundColorAttributeName: FlatRed()]
        return NSAttributedString(string: "推荐活动或入驻Remix", attributes: attrDic)
    }
    
    func emptyDataSetShouldAllowScroll(scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    
    func emptyDataSet(scrollView: UIScrollView!, didTapButton button: UIButton!) {
        let sheet = LCActionSheet(title: "添加活动或地点至Remix。审核通过后其他用户将看到你的推荐。", buttonTitles: ["添加一条活动", "推荐一家店或地点", "入驻Remix"], redButtonIndex: -1) { (buttonIndex) -> Void in
            if buttonIndex == 0 {
                let webVC = RxWebViewController(url:NSURL(string: "http://jsform.com/f/v5pfam")!)
                self.navigationController?.pushViewController(webVC, animated: true)
            }
            
            if buttonIndex == 1 {
                let webVC = RxWebViewController(url:NSURL(string: "http://jsform.com/f/j49bk8")!)
                self.navigationController?.pushViewController(webVC, animated: true)
            }
            
            if buttonIndex == 2 {
                if MFMailComposeViewController.canSendMail() {
                    let composer = MFMailComposeViewController()
                    composer.mailComposeDelegate = self
                    let subjectString = NSString(format: "Remix平台组织入驻申请")
                    let bodyString = NSString(format: "简介:\n\n\n\n\n\n-----\n组织成立时间: \n组织名称:\n微信公众号ID:\n负责人联系方式:\n组织性质及分类:\n-----")
                    composer.setMessageBody(bodyString as String, isHTML: false)
                    composer.setSubject(subjectString as String)
                    composer.setToRecipients(["fongtinyik@gmail.com", "remixapp@163.com"])
                    self.presentViewController(composer, animated: true, completion: nil)
                }
                
            }
        }
        
        sheet.show()
    }

    
    
}
