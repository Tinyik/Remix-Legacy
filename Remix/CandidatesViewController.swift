//
//  CandidatesViewController.swift
//  Remix
//
//  Created by fong tinyik on 3/8/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit
import MessageUI
import SDWebImage
import TTGSnackbar

class CandidatesViewController: UITableViewController, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate{
    
    var objectId: String = ""
    var coverImgURL: NSURL!
    var revenue: Double = 0
    var orders: [AVObject] = []
    var customers: [AVUser] = []
    var parentActivity: AVObject!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        self.tableView.tableFooterView = UIView()
        let refreshCtrl = UIRefreshControl()
        refreshCtrl.addTarget(self, action: "refreshAllData", forControlEvents: .ValueChanged)
        self.refreshControl = refreshCtrl
        let b1 = UIBarButtonItem(title: "活动页面", style: .Plain, target: self, action: "showActivity")
        let b2 = UIBarButtonItem(title: "管理", style: .Plain, target: self, action: "showUtilities")
        self.navigationItem.rightBarButtonItems = [b2,b1]
        refreshAllData()
    }
    
    func refreshAllData() {
        let query = AVQuery(className: "Activity")
        query.getObjectInBackgroundWithId(objectId) { (activity, error) -> Void in
            if error == nil {
                self.parentActivity = activity
            }
        }
            fetchCloudData()
    
        
    }
    
    func refreshActivityStatus() {
        let query = AVQuery(className: "Activity")
        query.getObjectInBackgroundWithId(objectId) { (activity, error) -> Void in
            if error == nil {
                self.parentActivity = activity
            }else{
                let snackBar = TTGSnackbar.init(message: "数据价值失败。请检查网络连接后重试", duration: .Middle)
                snackBar.backgroundColor = FlatWatermelonDark()
                snackBar.show()
                self.navigationController?.popViewControllerAnimated(true)
            }
        }

    }
    
    func showActivity() {
        let activityView = RMActivityViewController(url:NSURL(string: self.parentActivity.objectForKey("URL") as! String)!)
        activityView.toolBar.likeButton.hidden = true
        activityView.shouldApplyWhiteTint = false
        activityView.activity = self.parentActivity
        self.navigationController?.pushViewController(activityView, animated: true)
    }
    
    func showUtilities() {
        let sheet = LCActionSheet(title: nil, buttonTitles: ["扫码签到", "群发Remix推送消息", "群发邮件", "群发短信", "导出报名信息为表格"], redButtonIndex: -1) { (buttonIndex) -> Void in
            
            let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
            
            if buttonIndex == 0 {
                let vc = storyboard.instantiateViewControllerWithIdentifier("CodeVC") as! QRCodeViewController
                vc.activityObjectId = self.objectId
                vc.backgroundURL = self.coverImgURL
                let navi = UINavigationController(rootViewController: vc)
                self.presentViewController(navi, animated: true, completion: nil)
            }
            
            if buttonIndex == 1 {
                let vc = storyboard.instantiateViewControllerWithIdentifier("NotifInputVC") as! NotifInputViewController
                vc.objectId = self.objectId
                self.navigationController?.pushViewController(vc, animated: true)
            }
            if buttonIndex == 2 {
                self.sendGroupEmails()
            }
            
            if buttonIndex == 3 {
                self.sendGroupMessages()
            }
            
            if buttonIndex == 4 {
                self.exportToMail()
            }
           
        }
        
        sheet.show()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        refreshActivityStatus()
        self.navigationController?.navigationBar.translucent = false
    }
    
    func exportToMail() {
        if MFMailComposeViewController.canSendMail() {
            var emails: [String] = []
            var phoneNumbers: [String] = []
            var names: [String] = []
            var remarks: [String] = []
            var wechats: [String] = []
            var schools: [String] = []
            var weibos: [String] = []
            for o in orders{
                if let r = o.objectForKey("Remarks") as? String {
                    remarks.append(r)
                }else{
                    remarks.append("无")
                }
            }
            for c in customers {
                emails.append(c.email)
                phoneNumbers.append(c.mobilePhoneNumber)
                names.append(c.objectForKey("LegalName") as! String)
                schools.append(c.objectForKey("School") as! String)
                if let wechat = c.objectForKey("Wechat") as? String {
                    wechats.append(wechat)
                }else{
                    wechats.append("无")
                }
                
                if let weibo = c.objectForKey("Weibo") as? String {
                    weibos.append(weibo)
                }else{
                    weibos.append("无")
                }
            }
            let controller = MFMailComposeViewController()
            controller.mailComposeDelegate = self
            var bodyTitle = "//在电脑端查看即可正常显示\n\n\n     姓名     学校     手机号     邮箱     微信     备注\n\n"
            for var i = 0; i < customers.count; ++i {
                bodyTitle = bodyTitle +  "\n     " + names[i] + "     " + schools[i] + "     " + phoneNumbers[i] + "     " + emails[i] + "     " + wechats[i] + "     " + remarks[i]
            }
            controller.setSubject("活动报名情况")
            controller.setMessageBody(bodyTitle, isHTML: false)
            self.presentViewController(controller, animated: true, completion: nil)
            
        }
    }
    
    func sendGroupEmails() {
        if MFMailComposeViewController.canSendMail() {
            let controller = MFMailComposeViewController()
            var recipients: [String] = []
            for customer in customers {
                recipients.append(customer.email)
            }
            controller.setToRecipients(recipients)
            controller.mailComposeDelegate = self
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    func sendGroupMessages() {
        if MFMessageComposeViewController.canSendText() {
            let controller = MFMessageComposeViewController()
            var recipients: [String] = []
            for customer in customers {
                recipients.append(customer.mobilePhoneNumber)
            }
            controller.recipients = recipients
            controller.messageComposeDelegate = self
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func fetchCloudData() {
        orders = []
        customers = []
        revenue = 0
        let query = AVQuery(className: "Orders")
        query.whereKey("ParentActivityObjectId", equalTo: AVObject(withoutDataWithObjectId: objectId))
        query.findObjectsInBackgroundWithBlock { (orders, error) -> Void in
            if self.refreshControl?.refreshing == true {
                self.refreshControl?.endRefreshing()
            }
            if error == nil {
                for order in orders {
                    print("ORDER")
                    self.orders.append(order as! AVObject)
                    let query2 = AVQuery(className: "_User")
                    if let u = order.objectForKey("CustomerObjectId") as? AVUser {
                        query2.getObjectInBackgroundWithId(u.objectId, block: { (user, error) -> Void in
                            print("USER")
                            if error == nil {
                                self.customers.append(user as! AVUser)
                                self.tableView.reloadData()
                            }
                        })

                    }
                    
                    self.revenue += order.objectForKey("Amount") as! Double
                }
              self.setUpParallaxHeaderView()
            }
        }
    }
    
    
    
    func setUpParallaxHeaderView() {
        let headerView = UIView.loadFromNibNamed("ActivityHeaderView") as! ActivityHeaderView
        headerView.activity = parentActivity
        headerView.coverImgURL = coverImgURL
        headerView.cashButton.addTarget(self, action: "withdrawCash", forControlEvents: .TouchUpInside)
        let numberFont = UIFont(name: "AvenirNext-UltraLight", size: 80)
        let attrDic1 = [NSFontAttributeName:numberFont!]
        let ordersString = NSMutableAttributedString(string: String(orders.count), attributes: attrDic1)
        let unitFont = UIFont.systemFontOfSize(18)
        let attrDic2 = [NSFontAttributeName:unitFont]
        let unitString = NSMutableAttributedString(string: "人", attributes: attrDic2)
        ordersString.appendAttributedString(unitString)
        headerView.ordersNumberLabel.attributedText = ordersString
        let revenueString = NSMutableAttributedString(string: String(Int(revenue)), attributes: attrDic1)
        let currencyString = NSMutableAttributedString(string: "元", attributes: attrDic2)
        revenueString.appendAttributedString(currencyString)
        headerView.revenueLabel.attributedText = revenueString
        headerView.fetchActivityInfo()
        self.tableView.tableHeaderView = headerView
        
    }
    
    func withdrawCash() {
        refreshActivityStatus()
        if checkEligibility() {
            if parentActivity.objectForKey("hasRequestedWithdrawal") as! Bool == false {
                if parentActivity.objectForKey("hasWithdrawn") as! Bool == false{
                    let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                    let vc = storyboard.instantiateViewControllerWithIdentifier("WithdrawInputVC") as! WithdrawInputViewController
                    vc.hasRequestedWithdrawal = false
                    vc.activityObjectId = self.objectId
                    vc.amount = self.revenue
                    self.navigationController?.pushViewController(vc, animated: true)
                }else{
                    let alert = UIAlertController(title: "Remix提示", message: "当前活动已提现。若款项未到账请联系Remix客服。", preferredStyle: .Alert)
                    let action = UIAlertAction(title: "好的", style: .Default, handler: nil)
                    alert.addAction(action)
                    self.presentViewController(alert, animated: true, completion: nil)
                }

            }else{
                if parentActivity.objectForKey("hasWithdrawn") as! Bool == false{
                    let alert = UIAlertController(title: "Remix提示", message: "当前活动已申请提现。需要更改申请提现目标账户吗？", preferredStyle: .Alert)
                    let cancel = UIAlertAction(title: "否", style: .Cancel, handler: nil)
                    let action = UIAlertAction(title: "是", style: .Default, handler: { (action) -> Void in
                        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                        let vc = storyboard.instantiateViewControllerWithIdentifier("WithdrawInputVC") as! WithdrawInputViewController
                        vc.hasRequestedWithdrawal = true
                        vc.activityObjectId = self.objectId
                        self.navigationController?.pushViewController(vc, animated: true)
                    })
                    alert.addAction(action)
                    alert.addAction(cancel)
                    self.presentViewController(alert, animated: true, completion: nil)

                }else{
                    let alert = UIAlertController(title: "Remix提示", message: "当前活动已提现。若款项未到账请联系Remix客服。", preferredStyle: .Alert)
                    let action = UIAlertAction(title: "好的", style: .Default, handler: nil)
                    alert.addAction(action)
                    self.presentViewController(alert, animated: true, completion: nil)
                }

            }
        }
    }
    
    func checkEligibility() -> Bool {
        if parentActivity.objectForKey("isVisibleToUsers") as! Bool == true && parentActivity.objectForKey("UnderReview") as! Bool == false {
            print("you")
            if parentActivity.objectForKey("hasWithdrawn") as! Bool == false {
                let alert = UIAlertController(title: "Remix提示", message: "当前活动正在接受报名, 无法提现。请先对活动进行下架操作。", preferredStyle: .Alert)
                let action = UIAlertAction(title: "好的", style: .Default, handler: { (action) -> Void in
                    self.navigationController?.popViewControllerAnimated(true)
                })
                alert.addAction(action)
                self.presentViewController(alert, animated: true, completion: nil)
            }else{
                let alert = UIAlertController(title: "Remix提示", message: "当前活动无法提现。如有疑问请联系Remix客服。", preferredStyle: .Alert)
                let action = UIAlertAction(title: "好的", style: .Default, handler: nil)
                alert.addAction(action)
                self.presentViewController(alert, animated: true, completion: nil)
            }
           
            return false
        }else if parentActivity.objectForKey("isVisibleToUsers") as! Bool == false && parentActivity.objectForKey("UnderReview") as! Bool == true{
            if parentActivity.objectForKey("hasWithdrawn") as! Bool == false {
                let alert = UIAlertController(title: "Remix提示", message: "当前活动仍在审核中, 无法进行提现操作。", preferredStyle: .Alert)
                let action = UIAlertAction(title: "好的", style: .Default, handler: nil)
                alert.addAction(action)
                self.presentViewController(alert, animated: true, completion: nil)
            }else{
                let alert = UIAlertController(title: "Remix提示", message: "当前活动无法提现。如有疑问请联系Remix客服。", preferredStyle: .Alert)
                let action = UIAlertAction(title: "好的", style: .Default, handler: nil)
                alert.addAction(action)
                self.presentViewController(alert, animated: true, completion: nil)
            }
          
            return false
        }
        
        

        
        return true
    }

    
//    override func scrollViewDidScroll(scrollView: UIScrollView) {
//        let header: ParallaxHeaderView = tableView.tableHeaderView as! ParallaxHeaderView
//        header.layoutHeaderViewForScrollViewOffset(scrollView.contentOffset)
//        
//        //        self.tableView.tableHeaderView = header
//    }
    
//    override func viewDidAppear(animated: Bool) {
//        (tableView.tableHeaderView as! ParallaxHeaderView).refreshBlurViewForNewImage()
//        super.viewDidAppear(animated)
//    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "报名者一览"
        }
        return nil
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return customers.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier") as! CandidateCell
        cell.nameLabel.text = customers[indexPath.row].objectForKey("LegalName") as? String
        cell.detailLabel.text = "订单号: " + orders[indexPath.row].objectId.substringFromIndex(orders[indexPath.row].objectId.startIndex.advancedBy(17))
        cell.detailLabel.textColor = FlatGrayDark()
        if orders[indexPath.row].objectForKey("CheckIn") as! Bool == false {
            cell.statusLabel.text = "未签到"
            cell.statusLabel.textColor = FlatGrayDark()
        }else{
            cell.statusLabel.text = "已签到"
            cell.statusLabel.textColor = FlatRed()
        }
        let url = NSURL(string: (customers[indexPath.row].objectForKey("Avatar") as! AVFile).url)
        cell.avatarView.sd_setImageWithURL(url, placeholderImage: UIImage(named: "DefaultAvatar"))
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let detailVC = storyBoard.instantiateViewControllerWithIdentifier("CandidateDetailVC") as! CandidateDetailViewController
        detailVC.customer = customers[indexPath.row]
        detailVC.order = orders[indexPath.row]
        self.navigationController?.pushViewController(detailVC, animated: true)
        
    }
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        
        let attrDic = [NSFontAttributeName: UIFont.systemFontOfSize(17)]
        return NSAttributedString(string: "\n\n\n\n\n\n\n\n\n\n\n\n当前活动还没有人报名。(・_・ヾ\n", attributes: attrDic)
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let attrDic = [NSFontAttributeName: UIFont.systemFontOfSize(15)]
        return NSAttributedString(string: "有人报名后，你可以在这里管理参与者并与他们取得联系。快试试: ", attributes: attrDic)
    }
    
    func buttonTitleForEmptyDataSet(scrollView: UIScrollView!, forState state: UIControlState) -> NSAttributedString! {
        let attrDic = [NSFontAttributeName: UIFont.systemFontOfSize(16), NSForegroundColorAttributeName: FlatRed()]
        return NSAttributedString(string: "分享这个活动给好友", attributes: attrDic)
    }
    
    func emptyDataSetShouldAllowScroll(scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func emptyDataSet(scrollView: UIScrollView!, didTapButton button: UIButton!) {
        let coverImageURL = NSURL(string: (parentActivity.objectForKey("CoverImg") as! AVFile).url)
        let shareText = "Remix活动推荐: " + (parentActivity.objectForKey("Title") as! String)
        let manager = SDWebImageManager()
        manager.downloadImageWithURL(coverImageURL, options: .RetryFailed, progress: nil, completed: { (coverImage, error, cache, finished, url) -> Void in
            if error == nil {
                let url = self.parentActivity.objectForKey("URL") as! String
                let handler = UMSocialWechatHandler.setWXAppId("wx6e2c22b24588e0e1", appSecret: "e085edb726c5b92bf443f1e3da3f838e", url: url)
                UMSocialSnsService.presentSnsIconSheetView(self, appKey: "56ba8fa2e0f55a1071000931", shareText: shareText, shareImage: coverImage, shareToSnsNames: [UMShareToWechatSession,UMShareToWechatTimeline, UMShareToQQ, UMShareToQzone, UMShareToTwitter], delegate: nil)
            }
        })

        
    }


    
}
