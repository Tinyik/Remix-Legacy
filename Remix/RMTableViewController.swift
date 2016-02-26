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

let themeColor = UIColor(red: 74/255, green: 144/255, blue: 224/255, alpha: 1)
var isHomepageFirstLaunching: Bool!

var hasPromptedToEnableNotif: Bool!

class RMTableViewController: TTUITableViewZoomController, MGSwipeTableCellDelegate, UISearchBarDelegate, PKPaymentAuthorizationViewControllerDelegate, BmobPayDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var headerScrollView: UIScrollView!
    @IBOutlet weak var adTableView: UITableView!
    
    var shouldAskToEnableNotif = true
    var coverImgURLs: [[NSURL]] = []
    var activities: [[BmobObject]] = []
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
        fetchCloudData()
        fetchCloudAdvertisement()
        
          }
    
    
    func setUpViews() {
        adTableView.separatorStyle = .None
        searchBar.searchBarStyle = .Minimal
        self.tableView.separatorColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.4)
        let view = UIView(frame: CGRectMake((self.navigationController?.navigationBar.frame.size.width)!/2 - 80,0, 160, 35))
        let moreButton = UIButton(frame: CGRectMake(0,0,25,25))
        moreButton.setImage(UIImage(named: "more"), forState: .Normal)
        moreButton.addTarget(self, action: "presentSettingsVC", forControlEvents: .TouchUpInside)
        let backItem = UIBarButtonItem(customView: moreButton)
        self.navigationItem.rightBarButtonItem = backItem
        self.navigationController?.navigationBar.translucent = false
        self.navigationItem.titleView = view
        self.navigationItem.hidesBackButton = true
        let button1 = UIButton()
        let button2 = UIButton()
        let button3 = UIButton()
        button1.selected = true
        button1.setBackgroundImage(UIImage(named: "button1"), forState: .Selected)
        button3.setBackgroundImage(UIImage(named: "button3"), forState: .Selected)
        button2.setBackgroundImage(UIImage(named: "button2"), forState: .Selected)
        button1.setBackgroundImage(UIImage(named: "button1_normal"), forState: .Normal)
        button3.setBackgroundImage(UIImage(named: "button3_normal"), forState: .Normal)
        button2.setBackgroundImage(UIImage(named: "button2_normal"), forState: .Normal)
        
        
        
        button1.frame = CGRectMake(0, 10, 28, 26)
        button2.frame = CGRectMake(70, 10, 28, 26)
        button3.frame = CGRectMake(140, 10, 26, 26)
        view.addSubview(button1)
        view.addSubview(button2)
        view.addSubview(button3)
        button2.addTarget(self, action: "presentSecondVC", forControlEvents: .TouchUpInside)
        button3.addTarget(self, action: "presentThirdVC", forControlEvents: .TouchUpInside)
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
    
    
    func presentSecondVC() {
        if launchedTimes! == 1 && shouldAskToEnableNotif {
            askToEnableNotifications()
            shouldAskToEnableNotif = false
        }
        let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let categoryVC = storyBoard.instantiateViewControllerWithIdentifier("CategoryVC")
        let navigationController = UINavigationController(rootViewController: categoryVC)
        self.navigationController?.presentViewController(navigationController, animated: false, completion: nil)
        if launchedTimes! == 1 && shouldAskToEnableNotif {
            askToEnableNotifications()
            shouldAskToEnableNotif = false
        }
        
    }
    
    func presentThirdVC() {
        if launchedTimes! == 1 && shouldAskToEnableNotif {
            askToEnableNotifications()
            shouldAskToEnableNotif = false
        }
        let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let orgsVC = storyBoard.instantiateViewControllerWithIdentifier("OrgsVC")
        let navigationController = UINavigationController(rootViewController: orgsVC)
        self.navigationController?.presentViewController(navigationController, animated: false, completion: nil)
        if launchedTimes! == 1 && shouldAskToEnableNotif {
            askToEnableNotifications()
            shouldAskToEnableNotif = false
        }
    }

    
    func fetchCloudAdvertisement() {
        let query = BmobQuery(className: "HeaderPromotion")
        query.whereKey("isVisibleToUsers", equalTo: true)
        query.findObjectsInBackgroundWithBlock { (ads, error) -> Void in
            var adImageURLs: [NSURL] = []
            for ad in ads{
                let adImageURL = NSURL(string: (ad.objectForKey("AdImage") as! BmobFile).url)
                if let urlString = ad.objectForKey("URL") as? String {
                    self.adTargetURLs.append(NSURL(string: urlString)!)
                }
                adImageURLs.append(adImageURL!)
               
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
                headerImageView.sd_setImageWithURL(adImageURLs[i])
                self.headerScrollView.addSubview(headerImageView)
                
            }
        
        self.configurePageControl()
        self.pageControl.frame.origin.x = UIScreen.mainScreen().bounds.size.width/2 - self.pageControl.frame.size.width/2
        }
    
    }
    
    func fetchCloudData() {
        coverImgURLs = []
      
        monthNameStrings = []
        activities = []
        
        
        let query = BmobQuery(className: "Activity")
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
    
    func refresh() {
         self.refreshControl?.endRefreshing()
    }
    
    func isMonthAdded(monthName: String) -> Bool {
        
        for _date in monthNameStrings {
            if _date == monthName {
                return true
            }
        }
        return false
    }
    
    func handlePromoSelection(sender: UIGestureRecognizer) {
        if launchedTimes! == 1 && shouldAskToEnableNotif {
            askToEnableNotifications()
            shouldAskToEnableNotif = false
        }
        if #available(iOS 9.0, *) {
            let safariView = SFSafariViewController(URL: adTargetURLs[(sender.view?.tag)!], entersReaderIfAvailable: true)
            safariView.view.tintColor = UIColor(red: 74/255, green: 144/255, blue: 224/255, alpha: 1)
            self.navigationController?.presentViewController(safariView, animated: true, completion: nil)
        } else {
            let webView = RxWebViewController(url: adTargetURLs[(sender.view?.tag)!])
            self.navigationController?.pushViewController(webView, animated: true)
        }

    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if tableView == adTableView {
            return 150
        }
        if activities.count > 0 {
        if let isFeatured = activities[indexPath.section][indexPath.row].objectForKey("isFeatured") as? Bool  {
            if isFeatured == true {
            return 375
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
        dateLabel.text = monthNameStrings[section]
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
    
                    cell.adImageView.sd_setImageWithURL(adImageURL)
                    
                }
            })
            return cell
        }else {
            if (activities[indexPath.section][indexPath.row].objectForKey("isFeatured") as! Bool) == true {
                
                let cell = tableView.dequeueReusableCellWithIdentifier("fullCellReuseIdentifier", forIndexPath: indexPath) as! RMFullCoverCell
                cell.delegate = self
                cell.titleLabel.text = activities[indexPath.section][indexPath.row].objectForKey("Title") as? String
                cell.orgLabel.text = activities[indexPath.section][indexPath.row].objectForKey("Org") as? String
                cell.timeLabel.text = activities[indexPath.section][indexPath.row].objectForKey("Date") as? String
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
                    cell.payButton.hidden = false
                }else{
                    cell.priceTag.text = "免费"
                    cell.payButton.hidden = true
                }
            }
        cell.titleLabel.text = activities[indexPath.section][indexPath.row].objectForKey("Title") as? String
        cell.desLabel.text = activities[indexPath.section][indexPath.row].objectForKey("Description") as? String
        cell.orgLabel.text = activities[indexPath.section][indexPath.row].objectForKey("Org") as? String
        cell.timeLabel.text = activities[indexPath.section][indexPath.row].objectForKey("Date") as? String
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

        
            return cell }
        
    }
    
    func swipeTableCell(cell: MGSwipeTableCell!, swipeButtonsForDirection direction: MGSwipeDirection, swipeSettings: MGSwipeSettings!, expansionSettings: MGSwipeExpansionSettings!) -> [AnyObject]! {
        
            swipeSettings.transition = .Border
            expansionSettings.fillOnTrigger = false
            expansionSettings.threshold = 1.5
            expansionSettings.buttonIndex = 2
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
            let registerButton = MGSwipeButton(title: "报名", backgroundColor: UIColor(white: 0.925, alpha: 1), callback: { (sender) -> Bool in
                
                self.registerForActivity(cell)
                
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
                        print(self.likedActivitiesIds)
                    }else{
                        if let index = self.likedActivitiesIds.indexOf(_cell.objectId) {
                            self.likedActivitiesIds.removeAtIndex(index)
                            _cell.likesNumberLabel.text = String(Int(_cell.likesNumberLabel.text!)! - 1)
                            let query = BmobQuery(className: "Activity")
                            query.getObjectInBackgroundWithId(_cell.objectId, block: { (activity, error) -> Void in
                                activity.decrementKey("LikesNumber", byAmount: 1)
                                activity.updateInBackground()
                            })
                            print(self.likedActivitiesIds)
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
            registerButton.setTitleColor(.blackColor(), forState: .Normal)
            return [shareButton, registerButton, likeButton] }else{
            return  nil
        }
            

    }
    
    
    func registerForActivity(cell: MGSwipeTableCell) {
        
        let indexPath = self.tableView.indexPathForCell(cell)
        let activity = self.activities[indexPath!.section][indexPath!.row]
        let orgName = activity.objectForKey("Org") as? String
        if let price = activity.objectForKey("Price") as? Double {
            if price != 0 {
//                if IOSVersion.SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO("9.2") {
//                    
//                    
//                    if PKPaymentAuthorizationViewController.canMakePayments() {
//                        let payment = PKPaymentRequest()
//                        let item = PKPaymentSummaryItem(label: orgName!, amount: NSDecimalNumber(double: price))
//                        payment.paymentSummaryItems = [item]
//                        payment.currencyCode = "CNY"
//                        payment.countryCode = "CN"
//                        payment.merchantIdentifier = "merchant.com.fongtinyik.remix"
//                        if #available(iOS 9.0, *) {
//                            payment.merchantCapabilities = [.Capability3DS, .CapabilityCredit, .CapabilityDebit, .CapabilityEMV]
//                        }
//                        if #available(iOS 9.2, *) {
//                            payment.supportedNetworks = [PKPaymentNetworkChinaUnionPay]
//                        }
//                        let payVC = PKPaymentAuthorizationViewController(paymentRequest: payment)
//                        payVC.delegate = self
//                        self.presentViewController(payVC, animated: true, completion: nil)
//                        
//                    }
//                }else{
                    let bPay = BmobPay()
                    bPay.delegate = self
                    bPay.price = NSNumber(double: price)
                    bPay.productName = orgName! + "活动报名费"
                    bPay.body = "Test"
                    bPay.appScheme = "BmobPay"
                    bPay.payInBackground()
                    
//                }
                
            }
        }

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
                
                let safariView = SFSafariViewController(URL: adTargetURL!, entersReaderIfAvailable: true)
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
    
    
    func paySuccess() {
        let alert = UIAlertController(title: "支付状态", message: "支付成功！", preferredStyle: .Alert)
        let action = UIAlertAction(title: "好的", style: .Default, handler: nil)
        alert.addAction(action)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func payFailWithErrorCode(errorCode: Int32) {
        print(errorCode)
        print("PAYFAILED")
        let alert = UIAlertController(title: "支付状态", message: "支付失败。", preferredStyle: .Alert)
        let action = UIAlertAction(title: "好的", style: .Default, handler: nil)
        alert.addAction(action)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
}
   