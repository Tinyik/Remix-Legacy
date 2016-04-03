//
//  OrgFilteredViewController.swift
//  Remix
//
//  Created by fong tinyik on 2/10/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit
import SDWebImage
import MessageUI
import TTGSnackbar

class OrgFilteredViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MGSwipeTableCellDelegate, OrganizationViewDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, MFMailComposeViewControllerDelegate, RMActivityViewControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var coverImgURLs: [[NSURL]] = []
    var activities: [[AVObject]] = []
    var monthNameStrings: [String] = []
    var dateLabel: UILabel!
    var likedActivitiesIds: [String] = []
    var orgName: String = "BookyGreen"
    var headerImage: UIImage!
    var headerImageLoaded = false
    var snackBar: TTGSnackbar!
    var indexPathForSelectedActivity: NSIndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCloudData()
        sharedOneSignalInstance.sendTag(orgName, value: "Visited")
        self.navigationController?.navigationBar.tintColor = .whiteColor()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "关于我们", style: .Plain, target: self, action: "showOrgIntroView")
        self.title = orgName
        self.tableView.emptyDataSetDelegate = self
        self.tableView.emptyDataSetSource = self
        self.tableView.tableFooterView = UIView()
        setUpParallaxHeaderView()
        setParallaxHeaderImage()
        
        //Registering nib
        self.tableView.registerNib(UINib(nibName: "MiddleCoverCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "MiddleCoverCell")
        self.tableView.registerNib(UINib(nibName: "RMTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "RMTableViewCell")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.translucent = false
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.translucent = true
        if snackBar != nil {
            self.snackBar.dismiss()
        }
    }
    
    func setUpParallaxHeaderView() {
        if headerImageLoaded == true {
        let headerView = ParallaxHeaderView.parallaxHeaderViewWithImage(headerImage, forSize: CGSizeMake(UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.width*0.667)) as! ParallaxHeaderView
        self.tableView.tableHeaderView = headerView
        }else{
            let headerView = ParallaxHeaderView.parallaxHeaderViewWithImage(UIImage(named: "SDPlaceholder"), forSize: CGSizeMake(UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.width*0.667)) as! ParallaxHeaderView
            self.tableView.tableHeaderView = headerView
        }
                
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
        
        
        let query = AVQuery(className: "Activity")
        query.whereKey("Cities", containedIn: [REMIX_CITY_NAME])
        query.whereKey("Org", equalTo: orgName)
        query.whereKey("isVisibleToUsers", equalTo: true)
      //  query.whereKey("isFloatingActivity", equalTo: false)
        query.orderByDescending("InternalDate")
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
    
    func fetchLikedActivitiesList() {
        if let _likedlist = CURRENT_USER.objectForKey("LikedActivities") as? [String] {
            likedActivitiesIds = _likedlist
        }
    }
   
    func reloadRowForActivity(activity: AVObject, isFloating: Bool) {
        fetchLikedActivitiesList()
        if isFloating == false {
            let query = AVQuery(className: "Activity")
            query.whereKey("Cities", containedIn: [REMIX_CITY_NAME])
            query.getObjectInBackgroundWithId(activity.objectId) { (activity, error) -> Void in
                if error == nil {
                    self.activities[self.indexPathForSelectedActivity.section][self.indexPathForSelectedActivity.row] = activity
                    self.tableView.reloadRowsAtIndexPaths([self.indexPathForSelectedActivity], withRowAnimation: .Automatic)
                }else{
                    let snackBar = TTGSnackbar.init(message: "获取数据失败。请检查网络连接后重试。", duration: .Middle)
                    snackBar.backgroundColor = FlatWatermelonDark()
                    snackBar.show()
                }
                
            }
            
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
       
    }
    
    func setParallaxHeaderImage() {
        let query = AVQuery(className: "Organization")
        query.whereKey("Name", equalTo: orgName)
        query.findObjectsInBackgroundWithBlock { (organizations, error) -> Void in
            if error == nil {
                for org in organizations {
                    if let _wechatId = org.objectForKey("WechatId") as? String {
                        self.snackBar = TTGSnackbar.init(message: "微信公众号:   " + _wechatId, duration: .Forever, actionText: "关注") { (snackbar) -> Void in
                            let alert = UIAlertController(title: "复制成功", message: "已复制到系统剪贴板, 即将打开微信。请在微信对话框中粘贴并搜索该公众号。", preferredStyle: .Alert)
                            let action = UIAlertAction(title: "好的", style: .Default, handler: { (action) -> Void in
                                UIPasteboard.generalPasteboard().string = _wechatId
                                UIApplication.sharedApplication().openURL(NSURL(string: "weixin://")!)
                                snackbar.dismiss()
                            })
                            alert.addAction(action)
                            self.presentViewController(alert, animated: true, completion: nil)
                        }
                        self.snackBar.alpha = 0.8
                        self.snackBar.backgroundColor = FlatBlueDark()
                        self.snackBar.show()
                        
                    }

                    if let urlString = org.objectForKey("HomePageCoverImage") as? AVFile {
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
                        if let urlString = org.objectForKey("Logo") as? AVFile {
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
                let snackBar = TTGSnackbar.init(message: "获取数据失败。请检查网络连接后重试。", duration: .Middle)
                snackBar.backgroundColor = FlatWatermelonDark()
                snackBar.show()
                self.headerImage = UIImage(named: "Logo")
                self.setUpParallaxHeaderView()
            }
        
        }
    }
    
    
    
    
    
    func presentSettingsVC() {
        let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let settingsVC = storyBoard.instantiateViewControllerWithIdentifier("SettingsVC")
        let navigationController = RMNavigationController(rootViewController: settingsVC)
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
                    return UITableViewAutomaticDimension
                }
            }
        }
        return 166
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        // don't know about the adTableView, so the first value might need to change in the future
        return 350
    }
    
    
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (activities[indexPath.section][indexPath.row].objectForKey("isFeatured") as! Bool) == true {
            let cell = tableView.dequeueReusableCellWithIdentifier("MiddleCoverCell", forIndexPath: indexPath) as! RMFullCoverCell
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
            let query = AVQuery(className: "Organization")
            query.whereKey("Name", equalTo: cell.orgLabel.text)
            query.findObjectsInBackgroundWithBlock({ (organizations, error) -> Void in
                if error == nil {
                    for org in organizations {
                        let url = NSURL(string: (org.objectForKey("Logo") as! AVFile).url)
                        cell.orgLogo.sd_setImageWithURL(url, placeholderImage: UIImage(named: "SDPlaceholder"))
                    }
                }else{
                    let snackBar = TTGSnackbar.init(message: "获取数据失败。请检查网络连接后重试。", duration: .Middle)
                    snackBar.backgroundColor = FlatWatermelonDark()
                    snackBar.show()
                }
            })
            if likedActivitiesIds.contains(_objId) {
                cell.isLiked = true
            }else{
                cell.isLiked = false
            }
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("RMTableViewCell", forIndexPath: indexPath) as! RMTableViewCell
        if let summary = activities[indexPath.section][indexPath.row].objectForKey("Summary") as? String {
            cell.summaryLabel.text = summary
        }else{
            cell.summaryLabel.text = ""
        }
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
        if let summary = activities[indexPath.section][indexPath.row].objectForKey("Summary") as? String{
            cell.orgLabel.text = cell.orgLabel.text! + summary
        }
        let query = AVQuery(className: "Organization")
        query.whereKey("Name", equalTo: activities[indexPath.section][indexPath.row].objectForKey("Org") as? String)
        query.findObjectsInBackgroundWithBlock({ (organizations, error) -> Void in
            if error == nil {
                for org in organizations {
                    let url = NSURL(string: (org.objectForKey("Logo") as! AVFile).url)
                    cell.orgLogo.sd_setImageWithURL(url, placeholderImage: UIImage(named: "SDPlaceholder"))
                }
            }else{
                let snackBar = TTGSnackbar.init(message: "获取数据失败。请检查网络连接后重试。", duration: .Middle)
                snackBar.backgroundColor = FlatWatermelonDark()
                snackBar.show()
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
        let query = AVQuery(className: "Activity")
        query.whereKey("Cities", containedIn: [REMIX_CITY_NAME])
        let objectId = activities[indexPath.section][indexPath.row].objectId
        query.getObjectInBackgroundWithId(objectId) { (activity, error) -> Void in
            if error == nil {
                activity.incrementKey("PageView", byAmount: 1)
                activity.saveInBackground()
            }else{
                let snackBar = TTGSnackbar.init(message: "获取数据失败。请检查网络连接后重试。", duration: .Middle)
                snackBar.backgroundColor = FlatWatermelonDark()
                snackBar.show()
            }
            
        }
        let activityView = RMActivityViewController(url: NSURL(string: activities[indexPath.section][indexPath.row].objectForKey("URL") as! String)!)
        activityView.activity = activities[indexPath.section][indexPath.row]
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? RMFullCoverCell {
            activityView.isLiked = cell.isLiked
        }
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? RMTableViewCell {
            activityView.isLiked = cell.isLiked
        }
        indexPathForSelectedActivity = indexPath
        activityView.delegate = self
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
        return NSAttributedString(string: "提交活动或入驻Remix", attributes: attrDic)
    }
    
    func emptyDataSetShouldAllowScroll(scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    
    func emptyDataSet(scrollView: UIScrollView!, didTapButton button: UIButton!) {
       (self.navigationController as! RMSwipeBetweenViewControllers).recommendActivityAndLocation()
    }

    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    
}
