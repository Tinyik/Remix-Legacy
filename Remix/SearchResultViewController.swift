//
//  SearchResultViewController.swift
//  Remix
//
//  Created by fong tinyik on 2/13/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit
import SafariServices
import PassKit
import SDWebImage


class SearchResultViewController: UITableViewController, UIGestureRecognizerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchBarDelegate, MGSwipeTableCellDelegate, PKPaymentAuthorizationViewControllerDelegate, BmobPayDelegate {
    
    var labelName = ""
    var delegate: ActivityFilterDelegate!
    
    var labelImageURLs: [NSURL] = []
    var labelImageURL: NSURL!
    var labelNames: [String] = []
    var activities: [BmobObject] = []
    var coverImgURLs: [NSURL] = []
    var likedActivitiesIds: [String] = []
    var registeredActivitiesIds: [String] = []
    var currentUser = BmobUser.getCurrentUser()
    
    
    var ongoingTransactionId: String!
    var ongoingTransactionPrice: Double!
    var ongoingTransactionRemarks = "No comments."
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var trendingLabelsCollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorStyle = .None
        self.tableView.showsVerticalScrollIndicator = false
        searchBar.searchBarStyle = .Minimal
        searchBar.delegate = self
        trendingLabelsCollectionView.delegate = self
        trendingLabelsCollectionView.dataSource = self
        let backButton = UIButton(frame: CGRectMake(0,0,30,30))
        backButton.setImage(UIImage(named: "back"), forState: .Normal)
        backButton.addTarget(self, action: "popCurrentVC", forControlEvents: .TouchUpInside)
        let backItem = UIBarButtonItem(customView: backButton)
        self.navigationItem.leftBarButtonItem = backItem
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.navigationBar.translucent = false
        self.title = "搜索"
       fetchTrendingLabels()
    }

    func popCurrentVC() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func fetchTrendingLabels() {
        let query = BmobQuery(className: "TrendingLabel")
        query.whereKey("isVisibleToUsers", equalTo: true)
        query.findObjectsInBackgroundWithBlock { (labels, error) -> Void in
            if labels.count > 0{
                for label in labels {
                    let labelName = label.objectForKey("Label") as! String
               
                    let labelFile = label.objectForKey("Image") as! BmobFile
                    let labelImageURL = NSURL(string: labelFile.url)!
                    self.labelNames.append(labelName)
                    self.labelImageURLs.append(labelImageURL)
                    self.trendingLabelsCollectionView.reloadData()
                }
            }
        }
    }
    
    func fetchOrdersInformation() {
        let query = BmobQuery(className: "Orders")
        query.whereKey("CustomerObjectId", equalTo: currentUser.objectId)
        query.findObjectsInBackgroundWithBlock { (orders, error) -> Void in
            if error == nil {
                for order in orders {
                    print(order.objectId)
                    self.registeredActivitiesIds.append(order.objectForKey("ParentActivityObjectId") as! String)
                }
            }
        }
    }

    
    func fetchSearchResults() {
        activities = []
        coverImgURLs = []
        fetchOrdersInformation()
        let query = BmobQuery(className: "Activity")
        query.findObjectsInBackgroundWithBlock { (activities, error) -> Void in
            if activities.count > 0 {
                for activity in activities {
                    let coverImg = activity.objectForKey("CoverImg") as! BmobFile
                    let imageURL = NSURL(string:coverImg.url)!

                    let org = activity.objectForKey("Org") as! String
                    let title = activity.objectForKey("Title") as! String
                    let description = activity.objectForKey("Description") as! String
                    
                    if org.rangeOfString(self.searchBar.text!, options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil, locale: nil) != nil || title.rangeOfString(self.searchBar.text!, options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil, locale: nil) != nil || description.rangeOfString(self.searchBar.text!, options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil, locale: nil) != nil  {
                        self.activities.append(activity as! BmobObject)
                        self.coverImgURLs.append(imageURL)
                    }
                    
                }
            }
            
            self.tableView.reloadData()
        }
        
        if let _likedlist = currentUser.objectForKey("LikedActivities") as? [String] {
            likedActivitiesIds = _likedlist
        }

        
    }
    // MARK: - Table view data source
    
    func checkPersonalInfoIntegrity() -> Bool {
        currentUser = BmobUser.getCurrentUser()
        if currentUser.objectForKey("LegalName") == nil || currentUser.objectForKey("LegalName") as! String == "" {
            return false
        }
        
        if currentUser.objectForKey("School") == nil || currentUser.objectForKey("School") as! String == ""{
            return false
        }
        
        if currentUser.objectForKey("username") == nil || currentUser.objectForKey("username") as! String == ""{
            return false
        }
        
        if currentUser.objectForKey("email") == nil || currentUser.objectForKey("email") as! String == ""{
            return false
        }
        
        return true
    }
    
    
    func presentSettingsVC() {
        let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let settingsVC = storyBoard.instantiateViewControllerWithIdentifier("SettingsVC")
        let navigationController = UINavigationController(rootViewController: settingsVC)
        self.navigationController?.presentViewController(navigationController, animated: true, completion: nil)
        
    }


    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if activities.count != 0 {
            self.tableView.separatorStyle = .SingleLine
        }else{
            self.tableView.separatorStyle = .None
        }
        return activities.count
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (activities[indexPath.row].objectForKey("isFeatured") as! Bool) == true {
            let cell = tableView.dequeueReusableCellWithIdentifier("fullCellReuseIdentifier", forIndexPath: indexPath) as! RMFullCoverCell
            cell.delegate = self
            cell.parentViewController = self
            if let price = activities[indexPath.row].objectForKey("Price") as? Double {
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

            cell.titleLabel.text = activities[indexPath.row].objectForKey("Title") as? String
            cell.orgLabel.text = activities[indexPath.row].objectForKey("Org") as? String
            cell.timeLabel.text = activities[indexPath.row].objectForKey("Date") as? String
            cell.likesNumberLabel.text = String(activities[indexPath.row].objectForKey("LikesNumber") as! Int)
            cell.fullImageView.sd_setImageWithURL(coverImgURLs[indexPath.row], placeholderImage: UIImage(named: "SDPlaceholder"))
            let _objId = activities[indexPath.row].objectId
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
        if let price = activities[indexPath.row].objectForKey("Price") as? Double {
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

        cell.titleLabel.text = activities[indexPath.row].objectForKey("Title") as? String
        cell.desLabel.text = activities[indexPath.row].objectForKey("Description") as? String
        cell.orgLabel.text = activities[indexPath.row].objectForKey("Org") as? String
        cell.timeLabel.text = activities[indexPath.row].objectForKey("Date") as? String
        cell.likesNumberLabel.text = String(activities[indexPath.row].objectForKey("LikesNumber") as! Int)
        cell.themeImg.sd_setImageWithURL(coverImgURLs[indexPath.row], placeholderImage: UIImage(named: "SDPlaceholder"))
        let _objId = activities[indexPath.row].objectId
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
                let activity = self.activities[indexPath!.row]
                let coverImageURL = self.coverImgURLs[indexPath!.row]
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
                
                self.prepareForActivityRegistration(cell)
                
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
                    cell.rightButtons[2].setTitle(_cell.likeButtonTitle, forState: .Normal)
                }
                if let _cell = cell as? RMFullCoverCell {
                    cell.rightButtons[2].setTitle(_cell.likeButtonTitle, forState: .Normal)
                }
                return true
            })
            shareButton.setTitleColor(.blackColor(), forState: .Normal)
            registerButton.setTitleColor(.blackColor(), forState: .Normal)
            return [shareButton, registerButton, likeButton] }else{
            return  nil
        }
        
        
    }
    

    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if activities.count > 0  {
            if let isFeatured = activities[indexPath.row].objectForKey("isFeatured") as? Bool  {
                if isFeatured == true {
                    return DEVICE_SCREEN_WIDTH
                }
            }
        }
        return DEVICE_SCREEN_WIDTH*0.4426
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    
    //    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
    //         return UIEdgeInsetsMake(35, 20, 5, 20)
    //    }
    //
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return CGSizeMake(collectionView.frame.size.width/3, 140)
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return labelNames.count
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = trendingLabelsCollectionView.dequeueReusableCellWithReuseIdentifier("reuseIdentifier", forIndexPath: indexPath) as! TrendingLabelCell
        cell.imageView.sd_setImageWithURL(labelImageURLs[indexPath.row], placeholderImage: UIImage(named: "SDPlaceholder"))
        cell.nameLabel.text = labelNames[indexPath.row]
        
        
        return cell
        
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        trendingLabelsCollectionView.deselectItemAtIndexPath(indexPath, animated: false)
        searchBar.resignFirstResponder()
        self.labelName = labelNames[indexPath.row]
        self.labelImageURL = labelImageURLs[indexPath.row]
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        self.performSegueWithIdentifier("showLabelFilteredVC", sender: nil)
        
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        searchBar.resignFirstResponder()
        if tableView == self.tableView {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            var query = BmobQuery(className: "Activity")
            let objectId = activities[indexPath.row].objectId
            query.getObjectInBackgroundWithId(objectId) { (activity, error) -> Void in
                activity.incrementKey("PageView", byAmount: 1)
                activity.updateInBackground()
            }
            if #available(iOS 9.0, *) {
                let safariView = SFSafariViewController(URL: NSURL(string: activities[indexPath.row].objectForKey("URL") as! String)!, entersReaderIfAvailable: false)
                safariView.view.tintColor = UIColor(red: 74/255, green: 144/255, blue: 224/255, alpha: 1)
                self.navigationController?.presentViewController(safariView, animated: true, completion: nil)
            } else {
                let webView = RxWebViewController(url: NSURL(string: activities[indexPath.row].objectForKey("URL") as! String)!)
                self.navigationController?.pushViewController(webView, animated: true)
            }
            
        }
    }
    

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        fetchSearchResults()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showLabelFilteredVC" {
            if let fVC = segue.destinationViewController as? LabelFilteredViewController {
                
                self.delegate = fVC
                self.delegate.filterQueryWithCategoryOrLabelName(labelName)
                self.delegate.setParallaxHeaderImage(labelImageURL)
                
                
            }
        }
    }
    
    func prepareForActivityRegistration(cell: MGSwipeTableCell) {
        let indexPath = self.tableView.indexPathForCell(cell)
        let activity = self.activities[indexPath!.row]
        if registeredActivitiesIds.contains(activity.objectId) {
            let alert = UIAlertController(title: "报名提示", message: "你已报名了这个活动，请进入我的订单查看。", preferredStyle: .Alert)
            let action = UIAlertAction(title: "立即查看", style: .Default, handler: { (action) -> Void in
                self.presentSettingsVC()
            })
            let cancel = UIAlertAction(title: "继续逛逛", style: .Cancel, handler: nil)
            alert.addAction(action)
            alert.addAction(cancel)
            self.presentViewController(alert, animated: true, completion: nil)
            
        }else{
            if let _isRegOpen = activity.objectForKey("isRegistrationOpen") as? Bool {
                if _isRegOpen == true {
                    if checkPersonalInfoIntegrity() {
                        
                        
                        if let _needInfo = activity.objectForKey("isRequireRemarks") as? Bool {
                            if _needInfo == true {
                                let prompt = activity.objectForKey("AdditionalPrompt") as? String
                                let alert = UIAlertController(title: "附加信息", message: "除了你的基本信息外，此活动需要以下附加的报名信息: \n" + prompt!, preferredStyle: .Alert)
                                let action = UIAlertAction(title: "继续报名", style: .Default, handler: { (action) -> Void in
                                    self.ongoingTransactionRemarks = alert.textFields![0].text!
                                    self.registerForActivity(cell)
                                })
                                let cancel = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
                                alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
                                    textField.placeholder = "请输入附加报名信息"
                                    
                                })
                                alert.addAction(action)
                                alert.addAction(cancel)
                                self.presentViewController(alert, animated: true, completion: nil)
                                
                            }else{
                                registerForActivity(cell)
                            }
                        }else{
                            registerForActivity(cell)
                        }
                        
                        
                    }else{
                        let alert = UIAlertController(title: "完善信息", message: "请先进入账户设置完善个人信息后再继续报名参加活动。", preferredStyle: .Alert)
                        let action = UIAlertAction(title: "去设置", style: .Default, handler: { (action) -> Void in
                            self.presentSettingsVC()
                        })
                        let cancel = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
                        alert.addAction(action)
                        alert.addAction(cancel)
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                    
                }else{
                    let alert = UIAlertController(title: "提示", message: "这个活动太火爆啦！参与活动人数已满(Ｔ▽Ｔ)再看看别的活动吧~下次记得早早下手哦。", preferredStyle: .Alert)
                    let action = UIAlertAction(title: "好吧", style: .Default, handler: nil)
                    alert.addAction(action)
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }else{
                let alert = UIAlertController(title: "提示", message: "这个活动太火爆啦！参与活动人数已满(Ｔ▽Ｔ)再看看别的活动吧~下次记得早早下手哦。", preferredStyle: .Alert)
                let action = UIAlertAction(title: "好吧", style: .Default, handler: nil)
                alert.addAction(action)
                self.presentViewController(alert, animated: true, completion: nil)
            }
            
        }
        
    }
    
    
    func registerForActivity(cell: MGSwipeTableCell) {
        
        
        let indexPath = self.tableView.indexPathForCell(cell)
        let activity = self.activities[indexPath!.row]
        let orgName = activity.objectForKey("Org") as? String
        
        if let price = activity.objectForKey("Price") as? Double {
            if price != 0 {
                ongoingTransactionId = activity.objectId
                ongoingTransactionPrice = price
                let bPay = BmobPay()
                bPay.delegate = self
                bPay.price = NSNumber(double: price)
                bPay.productName = orgName! + "活动报名费"
                bPay.body = (activity.objectForKey("ItemName") as! String) + "用户姓名" + (currentUser.objectForKey("LegalName") as! String)
                bPay.appScheme = "BmobPay"
                bPay.payInBackgroundWithBlock({ (isSuccessful, error) -> Void in
                    if isSuccessful == false {
                        let alert = UIAlertController(title: "支付状态", message: "支付失败！请检查网络连接。", preferredStyle: .Alert)
                        let action = UIAlertAction(title: "好的", style: .Default, handler: nil)
                        alert.addAction(action)
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                })
                
                //                }
                
            }else{
                ongoingTransactionId = activity.objectId
                ongoingTransactionPrice = 0
                let alert = UIAlertController(title: "Remix报名确认", message: "确定要报名参加这个活动吗？(●'◡'●)ﾉ♥", preferredStyle: .Alert)
                let action = UIAlertAction(title: "确认", style: .Default, handler: { (action) -> Void in
                    self.paySuccess()
                })
                let cancel = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
                alert.addAction(action)
                alert.addAction(cancel)
                self.presentViewController(alert, animated: true, completion: nil)
            }
            
            
        }else{
            ongoingTransactionId = activity.objectId
            ongoingTransactionPrice = 0
            let alert = UIAlertController(title: "Remix报名确认", message: "确定要报名参加这个活动吗？(●'◡'●)ﾉ♥", preferredStyle: .Alert)
            let action = UIAlertAction(title: "确认", style: .Default, handler: { (action) -> Void in
                self.paySuccess()
            })
            let cancel = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
            alert.addAction(action)
            alert.addAction(cancel)
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        
    }
    
    
    func paymentAuthorizationViewController(controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: (PKPaymentAuthorizationStatus) -> Void) {
        completion(PKPaymentAuthorizationStatus.Success)
    }
    
    func paymentAuthorizationViewControllerDidFinish(controller: PKPaymentAuthorizationViewController) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func paySuccess() {
        let newOrder = BmobObject(className: "Orders")
        newOrder.setObject(ongoingTransactionId, forKey: "ParentActivityObjectId")
        newOrder.setObject(ongoingTransactionPrice, forKey: "Amount")
        newOrder.setObject(currentUser.objectId, forKey: "CustomerObjectId")
        newOrder.setObject(ongoingTransactionRemarks, forKey: "Remarks")
        newOrder.setObject(true, forKey: "isVisibleToUsers")
        newOrder.saveInBackgroundWithResultBlock { (isSuccessful, error) -> Void in
            if isSuccessful {
                self.fetchOrdersInformation()
                let alert = UIAlertController(title: "支付状态", message: "报名成功！Remix已经把你的基本信息发送给了活动主办方。请进入 \"我参加的活动\" 查看", preferredStyle: .Alert)
                let cancel = UIAlertAction(title: "继续逛逛", style: .Cancel, handler: nil)
                let action = UIAlertAction(title: "立即查看", style: .Default) { (action) -> Void in
                    self.presentSettingsVC()
                }
                alert.addAction(action)
                alert.addAction(cancel)
                self.presentViewController(alert, animated: true, completion: nil)
            }else {
                let alert = UIAlertController(title: "支付状态", message: "Something is wrong. 这是一个极小概率的错误。不过别担心，如果已经被扣款, 请联系Remix客服让我们为你解决。（181-4977-0476）", preferredStyle: .Alert)
                let cancel = UIAlertAction(title: "稍后在说", style: .Cancel, handler: nil)
                let action = UIAlertAction(title: "立即拨打", style: .Default) { (action) -> Void in
                    UIApplication.sharedApplication().openURL(NSURL(string: "tel://18149770476")!)
                }
                alert.addAction(action)
                alert.addAction(cancel)
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
        
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
