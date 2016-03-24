//
//  RMWebViewController.swift
//  Remix
//
//  Created by fong tinyik on 2/13/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit
import SDWebImage
import TTGSnackbar
protocol RMActivityViewControllerDelegate{
    func reloadRowForActivity(activity: AVObject, isFloating: Bool)
}

class RMActivityViewController: RxWebViewController, UIGestureRecognizerDelegate, BmobPayDelegate, ModalTransitionDelegate {
   
    var tr_presentTransition: TRViewControllerTransitionDelegate?
    var delegate: RMActivityViewControllerDelegate!
    var activity: AVObject!
    var isFloating = false
    var shouldApplyWhiteTint = true
    var isLiked: Bool = false {
        didSet {
   
            if isLiked == true {
                toolBar.likeButton.setBackgroundImage(UIImage(named: "Like"), forState: .Normal)
                
            }else{
                toolBar.likeButton.setBackgroundImage(UIImage(named: "Unlike"), forState: .Normal)
            }
        }
    }
    var registeredActivitiesIds: [String] = []
    var likedActivitiesIds: [String] = []
    var ongoingTransactionId: String!
    var ongoingTransactionPrice: Double!
    var ongoingTransactionRemarks = "No comments."
    var toolBar = UIView.loadFromNibNamed("RMToolBarView") as! RMToolBarView
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.translucent = true
        if shouldApplyWhiteTint == true {
        self.navigationController?.navigationBar.tintColor = .whiteColor()
        }else{
        self.navigationController?.navigationBar.tintColor = .blackColor()
        }
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: "sharePresentingActivity")
        self.progressViewColor = FlatRed()
        let containerView = UIView(frame: CGRectMake(0, DEVICE_SCREEN_HEIGHT - 50 , DEVICE_SCREEN_WIDTH, 50))
        containerView.backgroundColor = .clearColor()
        self.view.addSubview(containerView)
        toolBar.likeButton.contentHorizontalAlignment = .Fill
        toolBar.likeButton.contentVerticalAlignment = .Fill
        toolBar.likesNumberLabel.text = String(activity.objectForKey("LikesNumber") as! Int) + "人已喜欢"
        toolBar.registerButton.addTarget(self, action: "prepareForActivityRegistration", forControlEvents: .TouchUpInside)
        if let price = activity.objectForKey("Price") as? Double {
            if price != 0 {
                toolBar.registerButton.setTitle("报名： ￥" + String(price), forState: .Normal)
            }else{
                toolBar.registerButton.setTitle("报名： 免费", forState: .Normal)
            }
        }
        if let isOpen = activity.objectForKey("isRegistrationOpen") as? Bool {
            if isOpen == false {
                self.toolBar.registerButton.backgroundColor = .grayColor()
                toolBar.registerButton.setTitle("暂不支持报名", forState: .Normal)
            }
        }
        toolBar.likeButton.addTarget(self, action: "likePresentingActivity", forControlEvents: .TouchUpInside)
        toolBar.showComments.addTarget(self, action: "showCommentsVC", forControlEvents: .TouchUpInside)
        toolBar.frame = containerView.bounds
        self.webView.frame.size.height -= 50
        containerView.addSubview(toolBar)
        toolBar.clipsToBounds = true
        fetchOrdersInformation()
    }
    
//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
//        self.navigationController?.hidesBarsOnSwipe = true
//    }
//    override func viewWillDisappear(animated: Bool) {
//        super.viewWillDisappear(animated)
//        self.navigationController?.hidesBarsOnSwipe = false
//    }
    
    func fetchOrdersInformation() {
        let query = AVQuery(className: "Orders")
        query.whereKey("CustomerObjectId", equalTo: AVUser(withoutDataWithObjectId: CURRENT_USER.objectId))

        query.findObjectsInBackgroundWithBlock { (orders, error) -> Void in
            if error == nil {
                for order in orders {
                    
                    if let o = order.objectForKey("ParentActivityObjectId") as? AVObject {
                        self.registeredActivitiesIds.append(o.objectId)
                    }

                }
            }else{
                let snackBar = TTGSnackbar.init(message: "获取数据失败。请检查网络连接后重试。", duration: .Middle)
                snackBar.backgroundColor = FlatWatermelonDark()
                snackBar.show()
            }

        }
    }
    
    override func webViewDidFinishLoad(webView: UIWebView!) {
        super.webViewDidFinishLoad(webView)
        self.title = activity.objectForKey("Org") as! String + "活动详情"
    }
    
    func showCommentsVC() {
        let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let commentsVC = storyBoard.instantiateViewControllerWithIdentifier("CommentsVC") as! CommentsTableViewController
        commentsVC.presentingActivity = self.activity
        commentsVC.parentActivityVC = self
        let naviController = RMNavigationController(rootViewController: commentsVC)
        
        self.tr_presentViewController(naviController, method: TRPresentTransitionMethod.PopTip(visibleHeight: COMMENTS_TABLE_VIEW_VISIBLE_HEIGHT))

    }
    
    func prepareForActivityRegistration() {
 
        if registeredActivitiesIds.contains(activity.objectId) {
            let alert = UIAlertController(title: "报名提示", message: "你已报名了这个活动，请进入我的订单查看。", preferredStyle: .Alert)
            let action = UIAlertAction(title: "立即查看", style: .Cancel, handler: { (action) -> Void in
                self.presentSettingsVC()
            })
            let cancel = UIAlertAction(title: "继续逛逛", style: .Default, handler: nil)
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
                                    self.registerForActivity()
                                })
                                let cancel = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
                                alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
                                    textField.placeholder = "请输入附加报名信息"
                                    
                                })
                                alert.addAction(action)
                                alert.addAction(cancel)
                                self.presentViewController(alert, animated: true, completion: nil)
                                
                            }else{
                                registerForActivity()
                            }
                        }else{
                            registerForActivity()
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
                    let alert = UIAlertController(title: "Remix提示", message: "Sorry.._(:qゝ∠)_此活动暂时不支持在Remix报名或报名人数已达上限。", preferredStyle: .Alert)
                    let action = UIAlertAction(title: "好吧", style: .Default, handler: nil)
                    alert.addAction(action)
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }else{
                let alert = UIAlertController(title: "Remix提示", message: "Sorry.._(:qゝ∠)_此活动暂时不支持在Remix报名或报名人数已达上限。", preferredStyle: .Alert)
                let action = UIAlertAction(title: "好吧", style: .Default, handler: nil)
                alert.addAction(action)
                self.presentViewController(alert, animated: true, completion: nil)
            }
            
        }

    }
    
    func checkPersonalInfoIntegrity() -> Bool {

        if CURRENT_USER.objectForKey("LegalName") == nil || CURRENT_USER.objectForKey("LegalName") as! String == "" {
            return false
        }
        
        if CURRENT_USER.objectForKey("Sex") == nil || CURRENT_USER.objectForKey("Sex") as! String == "" {
            return false
        }

        
        if CURRENT_USER.objectForKey("School") == nil || CURRENT_USER.objectForKey("School") as! String == ""{
            return false
        }
        
        if CURRENT_USER.objectForKey("username") == nil || CURRENT_USER.objectForKey("username") as! String == ""{
            return false
        }
        
        if CURRENT_USER.objectForKey("email") == nil || CURRENT_USER.objectForKey("email") as! String == ""{
            return false
        }
        
        return true
    }

    
    func presentSettingsVC() {
        let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let settingsVC = storyBoard.instantiateViewControllerWithIdentifier("SettingsVC")
        let navigationController = RMNavigationController(rootViewController: settingsVC)
        self.navigationController?.presentViewController(navigationController, animated: true, completion: nil)
        
    }
    
    func fetchLikedActivitiesList() {
        if let _likedlist = CURRENT_USER.objectForKey("LikedActivities") as? [String] {
            likedActivitiesIds = _likedlist
        }
    }
    func likePresentingActivity() {
        isLiked = !isLiked
        if isLiked == true {
            
            fetchLikedActivitiesList()
            if likedActivitiesIds.contains(activity.objectId) == false {
                likedActivitiesIds.append(activity.objectId)
                toolBar.likesNumberLabel.text = String(Int(toolBar.likesNumberLabel.text!.stringByReplacingOccurrencesOfString("人已喜欢", withString: ""))!+1) + "人已喜欢"
                sharedOneSignalInstance.sendTag(self.activity.objectId, value: "Liked")
                let query = AVQuery(className: "Activity")
                query.whereKey("Cities", containedIn: [REMIX_CITY_NAME])
                query.getObjectInBackgroundWithId(activity.objectId, block: { (activity, error) -> Void in
                    if error == nil {
                        activity.incrementKey("LikesNumber", byAmount: 1)
                        activity.saveInBackgroundWithBlock({ (isSuccessful, error) -> Void in
                            if error == nil {
                                self.delegate.reloadRowForActivity(self.activity, isFloating: self.isFloating)
                            }else{
                                let snackBar = TTGSnackbar.init(message: "获取数据失败。请检查网络连接后重试。", duration: .Middle)
                                snackBar.backgroundColor = FlatWatermelonDark()
                                snackBar.show()
                            }
                            
                        })

                    }else{
                        let snackBar = TTGSnackbar.init(message: "获取数据失败。请检查网络连接后重试。", duration: .Middle)
                        snackBar.backgroundColor = FlatWatermelonDark()
                        snackBar.show()
                    }

                })
                
            }
        }else{
            fetchLikedActivitiesList()
            if likedActivitiesIds.contains(activity.objectId) == true {
                likedActivitiesIds.removeAtIndex(likedActivitiesIds.indexOf(activity.objectId)!)
                toolBar.likesNumberLabel.text = String(Int(toolBar.likesNumberLabel.text!.stringByReplacingOccurrencesOfString("人已喜欢", withString: ""))!-1) + "人已喜欢"
                let query = AVQuery(className: "Activity")
                query.whereKey("Cities", containedIn: [REMIX_CITY_NAME])
                query.getObjectInBackgroundWithId(activity.objectId, block: { (activity, error) -> Void in
                    if error == nil {
                        activity.incrementKey("LikesNumber", byAmount: -1)
                        activity.saveInBackgroundWithBlock({ (isSuccessful, error) -> Void in
                            if error == nil {
                                self.delegate.reloadRowForActivity(self.activity, isFloating: self.isFloating)
                            }else{
                                let snackBar = TTGSnackbar.init(message: "获取数据失败。请检查网络连接后重试。", duration: .Middle)
                                snackBar.backgroundColor = FlatWatermelonDark()
                                snackBar.show()
                            }
                           
                        })
                    }else{
                        let snackBar = TTGSnackbar.init(message: "获取数据失败。请检查网络连接后重试。", duration: .Middle)
                        snackBar.backgroundColor = FlatWatermelonDark()
                        snackBar.show()
                    }
                   
                })
                
                
            }
        }
       
        
        CURRENT_USER.setObject(self.likedActivitiesIds, forKey: "LikedActivities")
        CURRENT_USER.saveInBackgroundWithBlock { (isSuccessful, error) -> Void in
            if error == nil {
               self.delegate.reloadRowForActivity(self.activity, isFloating: self.isFloating)
            }else{
                let snackBar = TTGSnackbar.init(message: "获取数据失败。请检查网络连接后重试。", duration: .Middle)
                snackBar.backgroundColor = FlatWatermelonDark()
                snackBar.show()
            }

        }
        
        
    }

    
    func registerForActivity() {
        
        
      
        let orgName = activity.objectForKey("Org") as? String
        
        if let price = activity.objectForKey("Price") as? Double {
            if price != 0 {
                ongoingTransactionId = activity.objectId
                ongoingTransactionPrice = price
                
                let alert = UIAlertController(title: "Remix报名确认", message: "确定要报名参加这个活动吗？(●'◡'●)ﾉ♥", preferredStyle: .Alert)
                let action = UIAlertAction(title: "确认", style: .Default, handler: { (action) -> Void in
                    let bPay = BmobPay()
                    bPay.delegate = self
                    bPay.price = NSNumber(double: price)
                    bPay.productName = orgName! + "活动报名费"
                    bPay.body = (self.activity.objectForKey("ItemName") as! String) + "用户姓名" + (CURRENT_USER.objectForKey("LegalName") as! String)
                    bPay.appScheme = "BmobPay"
                    bPay.payInBackgroundWithBlock({ (isSuccessful, error) -> Void in
                        if isSuccessful == false {
                            let alert = UIAlertController(title: "支付状态", message: "支付失败！请检查网络连接。", preferredStyle: .Alert)
                            let action = UIAlertAction(title: "好的", style: .Default, handler: nil)
                            alert.addAction(action)
                            self.presentViewController(alert, animated: true, completion: nil)
                        }
                    })
                })
                let cancel = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
                alert.addAction(action)
                alert.addAction(cancel)
                self.presentViewController(alert, animated: true, completion: nil)

                
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
    
    func sharePresentingActivity() {
        let coverImageURL = NSURL(string: (activity.objectForKey("CoverImg") as! AVFile).url)
        let shareText = "Remix活动推荐: " + (activity.objectForKey("Title") as! String)
        let manager = SDWebImageManager()
        manager.downloadImageWithURL(coverImageURL, options: .RetryFailed, progress: nil, completed: { (coverImage, error, cache, finished, url) -> Void in
            if error == nil {
                let url = self.activity.objectForKey("URL") as! String
                let handler = UMSocialWechatHandler.setWXAppId("wx6e2c22b24588e0e1", appSecret: "e085edb726c5b92bf443f1e3da3f838e", url: url)
                UMSocialSnsService.presentSnsIconSheetView(self, appKey: "56ba8fa2e0f55a1071000931", shareText: shareText, shareImage: coverImage, shareToSnsNames: [UMShareToWechatSession,UMShareToWechatTimeline, UMShareToQQ, UMShareToQzone, UMShareToTwitter], delegate: nil)
            }
        })

    }
    
    
    func paySuccess() {
        let newOrder = AVObject(className: "Orders")

         newOrder.setObject(AVObject(withoutDataWithClassName: "Activity", objectId: ongoingTransactionId), forKey: "ParentActivityObjectId")
        newOrder.setObject(ongoingTransactionPrice, forKey: "Amount")
        newOrder.setObject(AVUser(withoutDataWithObjectId: CURRENT_USER.objectId)
, forKey: "CustomerObjectId")
        newOrder.setObject(false, forKey: "CheckIn")
        newOrder.setObject(ongoingTransactionRemarks, forKey: "Remarks")
        newOrder.setObject(true, forKey: "isVisibleToUsers")
        newOrder.saveInBackgroundWithBlock { (isSuccessful, error) -> Void in
            if isSuccessful {
                sharedOneSignalInstance.sendTag(self.ongoingTransactionId, value: "PaySuccess")
                self.fetchOrdersInformation()
                let c = CURRENT_USER.objectForKey("Credit") as! Int
                CURRENT_USER.setObject(c+(Int(self.activity.objectForKey("Duration") as! String)!)*2, forKey: "Credit")
                CURRENT_USER.saveInBackground()
                let smsDict = ["Org": self.activity.objectForKey("Org") as! String, "Date": self.activity.objectForKey("Date") as! String, "Price": String(self.ongoingTransactionPrice), "Contact": self.activity.objectForKey("Contact") as! String]
                AVOSCloud.requestSmsCodeWithPhoneNumber(CURRENT_USER.mobilePhoneNumber, templateName: "Registration_Success", variables: smsDict, callback: nil)
                let alert = UIAlertController(title: "支付状态", message: "报名成功！Remix已经把你的基本信息发送给了活动主办方。请进入 \"我的订单\" 查看", preferredStyle: .Alert)
                let cancel = UIAlertAction(title: "继续逛逛", style: .Default, handler: nil)
                let action = UIAlertAction(title: "立即查看", style: .Cancel) { (action) -> Void in
                    self.presentSettingsVC()
                }
                alert.addAction(action)
                alert.addAction(cancel)
                let notif = UIView.loadFromNibNamed("NotifView") as! NotifView
                notif.parentvc = self
                notif.promptUserCreditUpdate(String((Int(self.activity.objectForKey("Duration") as! String))!*2), withContext: "报名活动", andAlert: alert)

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
        
        let alert = UIAlertController(title: "支付状态", message: "支付失败。", preferredStyle: .Alert)
        let action = UIAlertAction(title: "好的", style: .Default, handler: nil)
        alert.addAction(action)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    


    
    
}
