//
//  RMTableViewController.swift
//  Remix
//
//  Created by fong tinyik on 2/5/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit
import SafariServices
import PassKit
import SDWebImage

// Global Constants
let DEVICE_SCREEN_WIDTH = UIScreen.mainScreen().bounds.width
let DEVICE_SCREEN_HEIGHT = UIScreen.mainScreen().bounds.height
let COMMENTS_TABLE_VIEW_VISIBLE_HEIGHT: CGFloat = 450
var APPLICATION_UI_REMOTE_CONFIG: BmobObject!

var naviController: RMSwipeBetweenViewControllers!
var isHomepageFirstLaunching: Bool!
var hasPromptedToEnableNotif: Bool!
class RMTableViewController: TTUITableViewZoomController, MGSwipeTableCellDelegate, UISearchBarDelegate, PKPaymentAuthorizationViewControllerDelegate, BmobPayDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var headerScrollView: UIScrollView!
    @IBOutlet weak var adTableView: UITableView!
    @IBOutlet weak var floatingScrollView: UIScrollView!
    
    @IBOutlet weak var filterButton_1: UIButton!
    @IBOutlet weak var filterButton_2: UIButton!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var filterLabel_2: UILabel!
    @IBOutlet weak var filterLabel_1: UILabel!
    
    var isRefreshing: Bool = false
    var shouldAskToEnableNotif = true
    var coverImgURLs: [[NSURL]] = []
    var activities: [[BmobObject]] = []
    var headerAds: [BmobObject] = []
    var floatingActivities: [BmobObject] = []
    var registeredActivitiesIds: [String] = []
    var monthNameStrings: [String] = []
    var dateLabel: UILabel!
    var likedActivitiesIds: [String] = []
    var adTargetURLs: [NSURL] = []
    var bannerAds: [BmobObject]!
    var randomAdIndex = Int()
    var currentUser = BmobUser.getCurrentUser()
    var launchedTimes: Int!
    var pageControl = UIPageControl(frame: CGRectMake(80, 240, 200, 50))
  
    func updateLaunchedTimes() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        hasPromptedToEnableNotif = userDefaults.boolForKey("hasPromptedToEnableNotif")
        if hasPromptedToEnableNotif == nil {
            hasPromptedToEnableNotif = false
        }
        launchedTimes = userDefaults.integerForKey("LaunchedTimes")
        if launchedTimes == nil {
            userDefaults.setObject(0, forKey: "LaunchedTimes")
        }else{
            launchedTimes = userDefaults.integerForKey("LaunchedTimes")
            launchedTimes = launchedTimes! + 1
            userDefaults.setObject(launchedTimes, forKey: "LaunchedTimes")
        }
        print(launchedTimes)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLaunchedTimes()
        if launchedTimes % 10 == 0 {
            askToEnableNotifications()
        }
        cellZoomAnimationDuration = 0.4
        cellZoomXScaleFactor = 1.1
        cellZoomYScaleFactor = 1.1
        cellZoomInitialAlpha = 0.5
        self.tableView.delegate = self
        self.tableView.dataSource = self
        searchBar.delegate = self
        headerScrollView.delegate = self
        let refreshCtrl = UIRefreshControl()
        refreshCtrl.addTarget(self, action: "refresh", forControlEvents: .ValueChanged)
        self.refreshControl = refreshCtrl
        setUpViews()
        loadRemoteUIConfigurations()
        fetchCloudData()
        fetchCloudAdvertisement()
        fetchOrdersInformation()
          }
    

    func setUpViews() {
        adTableView.separatorStyle = .None
        searchBar.searchBarStyle = .Minimal
        self.tableView.separatorColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.4)
        self.navigationItem.hidesBackButton = true
    }
    
    func loadRemoteUIConfigurations() {
        let query = BmobQuery(className: "UIRemoteConfig")
        query.getObjectInBackgroundWithId("Cd3f1112") { (config, error) -> Void in
            if error == nil {
                APPLICATION_UI_REMOTE_CONFIG = config
                self.filterLabel_1.text = config.objectForKey("FilterLabel_1_Text") as? String
                self.filterLabel_2.text = config.objectForKey("FilterLabel_2_Text") as? String
                self.locationLabel.text = config.objectForKey("LocationLabel_Text") as? String
                let url1 = NSURL(string: (config.objectForKey("FilterButton_1_Image") as? BmobFile)!.url)
                let url2 = NSURL(string: (config.objectForKey("FilterButton_2_Image") as? BmobFile)!.url)
                let url3 = NSURL(string: (config.objectForKey("LocationButton_Image") as? BmobFile)!.url)
                let manager = SDWebImageManager()
                manager.downloadImageWithURL(url1, options: .RetryFailed, progress: nil, completed: { (image, error, type, isSuccessful, url) -> Void in
                    self.filterButton_1.setImage(image, forState: .Normal)
                })
                manager.downloadImageWithURL(url2, options: .RetryFailed, progress: nil, completed: { (image, error, type, isSuccessful, url) -> Void in
                    self.filterButton_2.setImage(image, forState: .Normal)
                })
                manager.downloadImageWithURL(url3, options: .RetryFailed, progress: nil, completed: { (image, error, type, isSuccessful, url) -> Void in
                    self.locationButton.setImage(image, forState: .Normal)
                })
            }
        }
    }
    
    func configurePageControl() {
       
        pageControl.addTarget(self, action: Selector("changePage:"), forControlEvents: UIControlEvents.ValueChanged)
        pageControl.numberOfPages = adTargetURLs.count
        pageControl.currentPage = 0
        pageControl.tintColor = UIColor.blackColor()
        pageControl.pageIndicatorTintColor = UIColor(white: 0.4, alpha: 0.8)
        pageControl.currentPageIndicatorTintColor = UIColor.whiteColor()
        self.view.addSubview(pageControl)
        
    }
    
    func changePage(sender: AnyObject) -> () {
        let x = CGFloat(pageControl.currentPage) * headerScrollView.frame.size.width
        headerScrollView.setContentOffset(CGPointMake(x, 0), animated: true)
    }
    
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView == headerScrollView {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
        }
    }
    
    func presentSettingsVC() {
        let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let settingsVC = storyBoard.instantiateViewControllerWithIdentifier("SettingsVC")
        let navigationController = UINavigationController(rootViewController: settingsVC)
        self.navigationController?.presentViewController(navigationController, animated: true, completion: nil)

    }
    
    func fetchOrdersInformation() {
        registeredActivitiesIds = []
        let query = BmobQuery(className: "Orders")
        query.whereKey("CustomerObjectId", equalTo: currentUser.objectId)
        query.findObjectsInBackgroundWithBlock { (orders, error) -> Void in
            if error == nil {
                for order in orders {
                    print(order.objectId)
                    self.registeredActivitiesIds.append(order.objectForKey("ParentActivityObjectId") as! String)
                }
                self.setUpFloatingScrollView()
            }
        }
    }

    
    func setUpFloatingScrollView() {
        for subView in floatingScrollView.subviews {
            subView.removeFromSuperview()
        }
        var imageURLs: [NSURL] = []
        for activity in floatingActivities {
            let imageURL = NSURL(string: (activity.objectForKey("CoverImg") as! BmobFile).url)
            imageURLs.append(imageURL!)

        }

            let elementWidth: CGFloat = 170 + 12
            self.floatingScrollView.contentSize = CGSizeMake(elementWidth*CGFloat(activities.count) + 12, self.floatingScrollView.frame.height)
            self.floatingScrollView.userInteractionEnabled = true
            
            for var i = 0; i < floatingActivities.count; ++i {
                let fView = FloatingActivityView.loadFromNibNamed("FloatingActivityView") as! FloatingActivityView
                fView.tag = i
                fView.activity = self.floatingActivities[i]
                fView.registeredActivitiesIds = self.registeredActivitiesIds
                fView.parentViewController = self
                fView.frame = CGRectMake(5 + elementWidth*CGFloat(i), 0, elementWidth, 185)
                fView.imageView.sd_setImageWithURL(imageURLs[i], placeholderImage: UIImage(named: "SDPlaceholder"))
                let tap = UITapGestureRecognizer(target: self, action: "handleFloatingViewSelection:")
                fView.addGestureRecognizer(tap)
                fView.titleLabel.text = self.floatingActivities[i].objectForKey("Title") as! String
                
                if let price = self.floatingActivities[i].objectForKey("Price") as? Double {
                    if price != 0 {
                        let priceNumberFont = UIFont.systemFontOfSize(17)
                        let attrDic1 = [NSFontAttributeName:priceNumberFont]
                        let priceString = NSMutableAttributedString(string: String(price), attributes: attrDic1)
                        let currencyFont = UIFont.systemFontOfSize(13)
                        let attrDic2 = [NSFontAttributeName:currencyFont]
                        let currencyString = NSMutableAttributedString(string: "元", attributes: attrDic2)
                        priceString.appendAttributedString(currencyString)
                        fView.priceTag.attributedText = priceString
                 
                    }else{
                        fView.priceTag.text = "免费"
                        fView.payButton.setImage(UIImage(named: "RegisterButton"), forState: .Normal)
                    }

                }
                
                self.floatingScrollView.addSubview(fView)
            }
            
        
    }
    
    func fetchCloudAdvertisement() {
        adTargetURLs = []
        headerAds = []
        let query = BmobQuery(className: "HeaderPromotion")
        query.whereKey("isVisibleToUsers", equalTo: true)
        query.findObjectsInBackgroundWithBlock { (ads, error) -> Void in
            if error == nil {
                if self.isRefreshing == true {
                    self.isRefreshing = false
                    self.refreshControl?.endRefreshing()
                }
                var adImageURLs: [NSURL] = []
                for ad in ads{
                    let adImageURL = NSURL(string: (ad.objectForKey("AdImage") as! BmobFile).url)
                    if let urlString = ad.objectForKey("URL") as? String {
                        self.adTargetURLs.append(NSURL(string: urlString)!)
                    }
                    adImageURLs.append(adImageURL!)
                    self.headerAds.append(ad as! BmobObject)
                }
                
                
                let screenWidth = UIScreen.mainScreen().bounds.width
                self.headerScrollView.contentSize = CGSizeMake(screenWidth*CGFloat((ads.count)), self.headerScrollView.frame.height)
                self.headerScrollView.userInteractionEnabled = true
                for var i = 0; i < ads.count; ++i {
                    let headerImageView = UIImageView(frame: CGRectMake(screenWidth*CGFloat(i),0,screenWidth,self.headerScrollView.frame.height ))
                    headerImageView.contentMode = .ScaleAspectFill
                    headerImageView.clipsToBounds = true
                    headerImageView.tag = i
                    headerImageView.userInteractionEnabled = true
                    let tap = UITapGestureRecognizer(target: self, action: "handlePromoSelection:")
                    headerImageView.addGestureRecognizer(tap)
                    headerImageView.sd_setImageWithURL(adImageURLs[i], placeholderImage: UIImage(named: "SDPlaceholder"))
                    self.headerScrollView.addSubview(headerImageView)
                    
                }
                
                self.configurePageControl()
                self.pageControl.frame.origin.x = UIScreen.mainScreen().bounds.size.width/2 - self.pageControl.frame.size.width/2
            }else{
                let alert = UIAlertController(title: "Remix提示", message: "出错了！ |ﾟДﾟ)))请检查你的网络连接后重试。", preferredStyle: .Alert)
                let action = UIAlertAction(title: "好的", style: .Default, handler: { (action) -> Void in
                    if self.isRefreshing == true {
                        self.isRefreshing = false
                        self.refreshControl?.endRefreshing()
                    }
                })
                
                alert.addAction(action)
                self.presentViewController(alert, animated: true, completion: nil)
            }
            
        }
    
    }
    
    func fetchCloudData() {
        coverImgURLs = []
      
        monthNameStrings = []
        activities = []
        floatingActivities = []
        
        let query = BmobQuery(className: "Activity")
        query.whereKey("isVisibleToUsers", equalTo: true)
        query.whereKey("isVisibleOnMainList", equalTo: true)
        query.findObjectsInBackgroundWithBlock { (activities, error) -> Void in
            if activities.count > 0 {
                for activity in activities {
                    if activity.objectForKey("isFloatingActivity") as! Bool == false {
                        
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
                        

                    }else{
                        print("NO")
                        self.floatingActivities.append(activity as! BmobObject)
                    }
                }
                self.fetchOrdersInformation()
                self.tableView.reloadData()
              
            }
        }
        
        if let _likedlist = currentUser.objectForKey("LikedActivities") as? [String] {
            likedActivitiesIds = _likedlist
        }
        
       
        
    }
    
    func refresh() {
        isRefreshing = true
        loadRemoteUIConfigurations()
        fetchCloudData()
        fetchCloudAdvertisement()

    }
    
    
    func isMonthAdded(monthName: String) -> Bool {
        
        for _date in monthNameStrings {
            if _date == monthName {
                return true
            }
        }
        return false
    }
    
    func handleFloatingViewSelection(sender: UIGestureRecognizer) {
        if launchedTimes! == 1 && shouldAskToEnableNotif {
            askToEnableNotifications()
            shouldAskToEnableNotif = false
        }
        let targetURL = NSURL(string: floatingActivities[(sender.view?.tag)!].objectForKey("URL") as! String)
       
            let activityView = RMActivityViewController(url: targetURL)
            activityView.activity = floatingActivities[(sender.view?.tag)!]
            self.navigationController?.pushViewController(activityView, animated: true)
    }
    
    func handlePromoSelection(sender: UIGestureRecognizer) {
        if launchedTimes! == 1 && shouldAskToEnableNotif {
            askToEnableNotifications()
            shouldAskToEnableNotif = false
        }
        
        if let parentActivityId = headerAds[(sender.view?.tag)!].objectForKey("ParentActivityObjectId") as? String {
            let query = BmobQuery(className: "Activity")
            query.getObjectInBackgroundWithId(parentActivityId, block: { (activity, error) -> Void in
                let activityView = RMActivityViewController(url: NSURL(string: activity.objectForKey("URL") as! String))
                activityView.activity = activity
                self.navigationController?.pushViewController(activityView, animated: true)
            })
            
        }else{
            if #available(iOS 9.0, *) {
                let safariView = SFSafariViewController(URL: adTargetURLs[(sender.view?.tag)!], entersReaderIfAvailable: false)
                self.navigationController?.pushViewController(safariView, animated: true)
            } else {
                let webVC = RxWebViewController(url: adTargetURLs[(sender.view?.tag)!])
                self.navigationController?.pushViewController(webVC, animated: true)
            }
            
        }
        
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if tableView == adTableView {
            return DEVICE_SCREEN_WIDTH*0.4
        }
        if activities.count > 0 {
        if let isFeatured = activities[indexPath.section][indexPath.row].objectForKey("isFeatured") as? Bool  {
            if isFeatured == true {
            return DEVICE_SCREEN_WIDTH
            }
        }
        }
        return 166
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if tableView == adTableView {
            return 1
        }
  
        return activities[section].count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if tableView == adTableView {
            return 1
        }
        
        return monthNameStrings.count
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if tableView == adTableView {
            return nil
        }
        
        let dateHeaderView = UIView(frame: CGRectMake(30,0,UIScreen.mainScreen().bounds.width, 50))
        
        dateHeaderView.backgroundColor = .whiteColor()
        dateHeaderView.layer.shadowColor = UIColor.blackColor().CGColor
        dateHeaderView.layer.shadowOpacity = 0.08
        dateHeaderView.layer.shadowOffset = CGSizeMake(0, 0.7)
        dateLabel = UILabel(frame: CGRectMake(0,0,300,390))
        
        if monthNameStrings.count > section {
            dateLabel.text = monthNameStrings[section]
        }else{
            let alert = UIAlertController(title: "Remix提示", message: "出错了！ |ﾟДﾟ)))请检查你的网络连接后重试。", preferredStyle: .Alert)
            let action = UIAlertAction(title: "立即重试", style: .Default, handler: { (action) -> Void in
                if self.isRefreshing == false {
                    self.isRefreshing = true
                    self.refreshControl?.beginRefreshing()
                }
            })
            
            let cancel = UIAlertAction(title: "好的", style: .Cancel, handler: nil)
            alert.addAction(cancel)
            alert.addAction(action)
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        dateLabel.font = UIFont.systemFontOfSize(19)
        dateLabel.sizeToFit()
        dateHeaderView.addSubview(dateLabel)
        dateLabel.center = dateHeaderView.center
        dateLabel.center.x = UIScreen.mainScreen().bounds.width/2
        return dateHeaderView
        
        
    }
    
    
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == adTableView {
            return 0
        }
        return  53
    }
    
  

    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        if tableView == adTableView {
            let action = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "换一换", handler: { (action, indexpath) -> Void in
                self.adTableView.reloadData()
            })
           return [action]
        }
        
        return nil
    }
    
   override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if tableView == self.tableView {
            return false
        }
        
        return true
    }
    
   
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if tableView == adTableView {
            self.bannerAds = []
            let cell = tableView.dequeueReusableCellWithIdentifier("adCellReuseIdentifier", forIndexPath: indexPath) as! AdvertiseCell
            let query = BmobQuery(className: "BannerPromotion")
            query.whereKey("isVisibleToUsers", equalTo: true)
            query.findObjectsInBackgroundWithBlock({ (promotions, error) -> Void in
                if promotions.count > 0{
                    for promotion in promotions {
                        self.bannerAds.append(promotion as! BmobObject)
                    }
                     self.randomAdIndex = Int(arc4random_uniform(UInt32(self.bannerAds.count)))
                    let adImageURL = NSURL(string:(self.bannerAds[self.randomAdIndex].objectForKey("AdImage") as! BmobFile).url)
    
                    cell.adImageView.sd_setImageWithURL(adImageURL, placeholderImage: UIImage(named: "SDPlaceholder"))
                    
                }
            })
            return cell
        }else {
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

        
            return cell }
        
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if launchedTimes! == 1 && shouldAskToEnableNotif {
            askToEnableNotifications()
            shouldAskToEnableNotif = false
        }
        if tableView == adTableView {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            let query = BmobQuery(className: "BannerPromotion")
            let objectId = bannerAds[randomAdIndex].objectId
            query.getObjectInBackgroundWithId(objectId) { (ad, error) -> Void in
                ad.incrementKey("PageView", byAmount: 1)
                ad.updateInBackground()
            }
            let adTargetURL = NSURL(string:(self.bannerAds[Int(self.randomAdIndex)].objectForKey("URL") as! String))
            if #available(iOS 9.0, *) {
            
                let safariView = SFSafariViewController(URL: adTargetURL!, entersReaderIfAvailable: false)
                safariView.view.tintColor = UIColor(red: 74/255, green: 144/255, blue: 224/255, alpha: 1)
                self.navigationController?.presentViewController(safariView, animated: true, completion: nil)
            } else {
                let webView = RxWebViewController(url: adTargetURL!)
                self.navigationController?.pushViewController(webView, animated: true)
            }

            
        }
        
        if tableView == self.tableView {
            
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
            let query = BmobQuery(className: "Activity")
            let objectId = activities[indexPath.section][indexPath.row].objectId
            query.getObjectInBackgroundWithId(objectId) { (activity, error) -> Void in
                if error == nil {
                activity.incrementKey("PageView", byAmount: 1)
                activity.updateInBackground()
                }else{
                    let alert = UIAlertController(title: "Remix提示", message: "出错了！ |ﾟДﾟ)))请检查你的网络连接后重试。", preferredStyle: .Alert)
                    let action = UIAlertAction(title: "好的", style: .Default, handler: nil)
                    alert.addAction(action)
                    self.presentViewController(alert, animated: true, completion: nil)
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
            
            self.navigationController?.pushViewController(activityView, animated: true)
   
            
      
       
        }
    }
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let searchResultVC = storyBoard.instantiateViewControllerWithIdentifier("SearchVC")
        self.navigationController?.pushViewController(searchResultVC, animated: true)
        
        return false
    }
    
    func askToEnableNotifications() {
        if UIApplication.sharedApplication().isRegisteredForRemoteNotifications() == false {
            
        let alert = UIAlertController(title: "推送设置", message: "Remix需要你允许推送消息才能及时传递魔都学生圈的最新消息。想要现在允许推送消息吗？(●'◡'●)ﾉ♥", preferredStyle: .Alert)
        let buttonOK = UIAlertAction(title: "好的", style: .Default) { (action) -> Void in
            self.promptToEnableNotifications()
        }
        let buttonCancel = UIAlertAction(title: "稍后再问", style: .Default, handler: nil)
        alert.addAction(buttonCancel)
        alert.addAction(buttonOK)
        self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func promptToEnableNotifications() {
        
        if hasPromptedToEnableNotif == false {
            let categories = UIMutableUserNotificationCategory()
            categories.identifier = "com.fongtinyik.remix"
            let notifSettings = UIUserNotificationSettings(forTypes: [UIUserNotificationType.Badge, UIUserNotificationType.Sound, UIUserNotificationType.Alert], categories: [categories] )
            UIApplication.sharedApplication().registerUserNotificationSettings(notifSettings)
            UIApplication.sharedApplication().registerForRemoteNotifications()
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setObject(true, forKey: "hasPromptedToEnableNotif")
            hasPromptedToEnableNotif = true
        
        }else{
             
                let instruction = UIAlertController(title: "如何开启消息通知", message: "请进入 设置->通知->Remix->允许通知 来开启Remix推送消息。", preferredStyle: .Alert)
                let ok = UIAlertAction(title: "好的", style: .Default, handler: nil)
                instruction.addAction(ok)
                self.presentViewController(instruction, animated: true, completion: nil)
           
        }
    }
   
    func paymentAuthorizationViewController(controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: (PKPaymentAuthorizationStatus) -> Void) {
        completion(PKPaymentAuthorizationStatus.Success)
    }
    
    func paymentAuthorizationViewControllerDidFinish(controller: PKPaymentAuthorizationViewController) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
}
   