//
//  SettingsViewController.swift
//  Remix
//
//  Created by fong tinyik on 2/6/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit
import MessageUI
import SDWebImage
import TTGSnackbar


class SettingsViewController: UITableViewController, MFMailComposeViewControllerDelegate, ModalTransitionDelegate, ZCSAvatarCaptureControllerDelegate {
    
    
    
    
    var avatarController: ZCSAvatarCaptureController!
    var tr_presentTransition: TRViewControllerTransitionDelegate?
    let headerView = UIView.loadFromNibNamed("SettingsHeaderView") as! SettingsHeaderView
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpParallaxHeaderView()
        self.title = "个人中心"
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 55, bottom: 0, right: 0)
        self.navigationController?.navigationBar.translucent = false
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "关闭", style: .Plain, target: self, action: "popCurrentVC")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "扫一扫", style: .Plain, target: self, action: "showScanner")
        self.navigationController?.navigationBar.tintColor = .blackColor()
        self.navigationController?.hidesNavigationBarHairline = true
        self.headerView.settingsButton.addTarget(self, action: "showPersonalInfo", forControlEvents: .TouchUpInside)
        
        if let avatar = CURRENT_USER.objectForKey("Avatar") as? AVFile {
            let avatarURL = NSURL(string:avatar.url)
            let manager = SDWebImageManager()
            manager.downloadImageWithURL(avatarURL, options: SDWebImageOptions.RetryFailed, progress: nil) { (avatar, error, cacheType, finished, url) -> Void in
                self.avatarController = ZCSAvatarCaptureController()
                self.avatarController.delegate = self
                self.avatarController.image = avatar
                self.headerView.avatarView.image = avatar
                self.headerView.blurredAvatarView.image = avatar
                self.headerView.avatarView.addSubview(self.avatarController.view)
                
            }
        }else{
            self.avatarController = ZCSAvatarCaptureController()
            self.avatarController.delegate = self
            self.headerView.avatarView.addSubview(self.avatarController.view)
        }
        
        
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        (tableView.tableHeaderView as! ParallaxHeaderView).refreshBlurViewForNewImage()
        super.viewDidAppear(animated)
    }
    
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
       
        let header: ParallaxHeaderView = tableView.tableHeaderView as! ParallaxHeaderView
        header.layoutHeaderViewForScrollViewOffset(scrollView.contentOffset)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        headerView.userNameLabel.text = CURRENT_USER.objectForKey("username") as? String
    }
    
    func setUpParallaxHeaderView() {
        let _headerView = ParallaxHeaderView.parallaxHeaderViewWithSubView(headerView) as! ParallaxHeaderView
        self.tableView.tableHeaderView = _headerView
        
        // Fixes header width problem
        _headerView.layoutHeaderViewForScrollViewOffset(tableView.contentOffset)
    }

    func showScanner() {

        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let vc = storyboard.instantiateViewControllerWithIdentifier("ScannerVC")
        let navi = RMNavigationController(rootViewController: vc)
        self.presentViewController(navi, animated: true, completion: nil)
    }
    
    func showPersonalInfo() {
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let vc = storyboard.instantiateViewControllerWithIdentifier("PersonalInfoVC")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func imageSelected(image: UIImage!) {
        self.headerView.blurredAvatarView.image = image
        let avatarData = UIImageJPEGRepresentation(image, 0.05)
        let newAvatar = AVFile(name: "Avatar.jpg", data: avatarData!)
        newAvatar.saveInBackgroundWithBlock { (isSuccessful, error) -> Void in
            if isSuccessful {
                CURRENT_USER.setObject(newAvatar, forKey: "Avatar")
                CURRENT_USER.saveInBackground()
            }else{
                let snackBar = TTGSnackbar.init(message: "获取数据失败。请检查网络连接后重试。", duration: .Middle)
                snackBar.backgroundColor = FlatWatermelonDark()
                snackBar.show()
            }
        }
        
        
        
    }
    
    func imageSelectionCancelled() {
        print("Canc")
    }
    
    func popCurrentVC() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let emptyCell = tableView.dequeueReusableCellWithIdentifier("detailedIdentifier") as! DetailedSettingsCell
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("detailedIdentifier") as! DetailedSettingsCell
            if indexPath.row == 3 {
                
                cell.titleLabel.text = "向Remix推荐活动"
                cell.titleLabel.textColor = FlatRed()
                cell.detailsLabel.text = "审核通过后你的推荐将出现在首页。"
                cell.icon.image = UIImage(named: "SubmActivity")
                return cell
            }else if indexPath.row == 1 {
                let cell2 = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier") as! SettingsCell
                cell2.label.text = "我的订单"
                cell2.icon.image = UIImage(named: "Orders")
                return cell2
            }else if indexPath.row == 4{
                cell.titleLabel.text = "向Remix推荐好店/地点"
                cell.titleLabel.textColor = FlatRed()
                cell.detailsLabel.text = "你的推荐将出现在首页地点推荐中。"
                cell.icon.image = UIImage(named: "SubmLocation")
                return cell
            }else if indexPath.row == 2{
                cell.titleLabel.text = "我发起的活动"
                cell.titleLabel.textColor = FlatRed()
                cell.detailsLabel.text = "在这里你将能管理、联系活动报名者和提取报名费到你的账户。"
                cell.icon.image = UIImage(named: "MyActivity")
                return cell
            }else if indexPath.row == 0 {
                let cell2 = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier") as! SettingsCell
                cell2.label.text = "REMIX PASS"
                cell2.icon.image = UIImage(named: "Pass")
                return cell2
            }
            
            
        }
        
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier") as! SettingsCell
            switch indexPath.row {
            case 0: cell.label.text = "告诉朋友"
                    cell.icon.image = UIImage(named: "Share")
            case 1: cell.label.text = "反馈"
                    cell.icon.image = UIImage(named: "Feedback")
            case 2: cell.label.text = "入驻Remix"
                    cell.icon.image = UIImage(named: "Join")
            default: break
            }
            
            return cell
        }
        
        
        if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier") as! SettingsCell
            switch indexPath.row {
            case 0: cell.label.text = "清除缓存"
                    cell.icon.image = UIImage(named: "ClearCache")
            case 1: cell.label.text = "显示使用指南"
                    cell.icon.image = UIImage(named: "Manual")
            case 2: cell.label.text = "退出登录"
                    cell.icon.image = UIImage(named: "Logout")
                
            default: break
            }
            
            return cell
        }
        
        return emptyCell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 65
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 5
        }
        
        return 3
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 10
    }
    
    
    
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 2{
            return "Remix 1.0 Build 12 Public Testing Version.\n Copyright © 2016 Tianyi Fang.\n All rights reserved."
        }
        
        return nil
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.section == 0 {
            let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
            switch indexPath.row {
            case 0 : let passVC = storyBoard.instantiateViewControllerWithIdentifier("PassVC")
                     self.navigationController?.pushViewController(passVC, animated: true)
            case 2 : let manVC = storyBoard.instantiateViewControllerWithIdentifier("ManVC")
                     self.navigationController?.pushViewController(manVC, animated: true)
            case 1 : let ordersVC = storyBoard.instantiateViewControllerWithIdentifier("OrdersVC")
                     self.navigationController?.pushViewController(ordersVC, animated: true)
            case 3:  let subm = ActivitySubmissionViewController()
                     subm.isModal = false
                     self.navigationController?.pushViewController(subm, animated: true)
            case 4:  let subm = LocationSubmissionViewController()
                     subm.isModal = false
                     self.navigationController?.pushViewController(subm, animated: true)
            default: break
            }
        }
        if indexPath.section == 1 {
            switch indexPath.row {
                //FIXME: Remix Official Website
            case 0:  let url = "http://fongtinyik.tumblr.com"
            let handler = UMSocialWechatHandler.setWXAppId("wx6e2c22b24588e0e1", appSecret: "e085edb726c5b92bf443f1e3da3f838e", url: url)
            UMSocialSnsService.presentSnsIconSheetView(self, appKey: "56ba8fa2e0f55a1071000931", shareText: "马上下载Remix来发现魔都最in学生活动与地点(●'◡'●)ﾉ♥", shareImage: UIImage(named: "Icon"), shareToSnsNames: [UMShareToWechatSession,UMShareToWechatTimeline, UMShareToQQ, UMShareToQzone, UMShareToTwitter], delegate: nil)
            case 1: if MFMailComposeViewController.canSendMail() {
                let composer = MFMailComposeViewController()
                composer.mailComposeDelegate = self
                let device = UIDevice.currentDevice()
                let identifierDictionary = DeviceInformation.appIdentifiers()
                let subjectString = NSString(format: "Support for Remix %@ %@", identifierDictionary["shortString"]!, identifierDictionary["buildString"]!)
                let bodyString = NSString(format: "\n\n\n-----\niOS Version: %@\nDevice: %@\n", device.systemVersion, DeviceInformation.hardwareIdentifier())
                composer.setMessageBody(bodyString as String, isHTML: false)
                composer.setSubject(subjectString as String)
                composer.setToRecipients(["fongtinyik@gmail.com", "remixapp@163.com"])
                self.presentViewController(composer, animated: true, completion: nil)
                }
            case 2 : let subm = OrganizationSubmissionViewController()
                     subm.isModal = false
                     self.navigationController?.pushViewController(subm, animated: true)
            
            default: break
            }
        }
        if indexPath.section == 2 {
            switch indexPath.row {
            case 0: SDImageCache.sharedImageCache().clearDisk()
            let alertController = UIAlertController(title: nil, message: "缓存清理成功", preferredStyle: .Alert)
            let actionButton = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
            alertController.addAction(actionButton)
            self.presentViewController(alertController, animated: true, completion: nil)
            case 1:  let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let guideViewController = storyboard.instantiateViewControllerWithIdentifier("GuideViewController") as! GuideViewController
            self.presentViewController(guideViewController, animated: true, completion: nil)
            case 2: let alert = UIAlertController(title: "Remix提示", message: "确认要登出当前Remix账户吗？", preferredStyle: .Alert)
                    let action = UIAlertAction(title: "是", style: .Destructive, handler: { (action) -> Void in
                        AVUser.logOut()
                        let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                        let regLoginController = storyBoard.instantiateViewControllerWithIdentifier("RegLoginVC")
                        self.tr_presentViewController(regLoginController, method: TRPresentTransitionMethod.Fade)
                    })
                    let cancel = UIAlertAction(title: "否", style: .Cancel, handler: nil)
                     alert.addAction(action)
                     alert.addAction(cancel)
                     self.presentViewController(alert, animated: true, completion: nil)
                
                
            default: break
            }
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}