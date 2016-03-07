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

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate, ModalTransitionDelegate, ZCSAvatarCaptureControllerDelegate {
   
    
    @IBOutlet weak var blurredAvatarView: UIImageView!
    
    @IBOutlet weak var firstTableView: UITableView!
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    var avatarController: ZCSAvatarCaptureController!
    var tr_presentTransition: TRViewControllerTransitionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.translucent = false
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "关闭", style: .Plain, target: self, action: "popCurrentVC")
        self.navigationController?.navigationBar.tintColor = FlatBlueDark()
        blurredAvatarView.contentMode = .ScaleAspectFill
        blurredAvatarView.clipsToBounds = true
        firstTableView.scrollEnabled = true
        firstTableView.separatorInset = UIEdgeInsetsZero
        avatarView.image = UIImage(named: "DefaultAvatar")
        avatarView.layer.cornerRadius = avatarView.frame.size.width/2
        avatarView.clipsToBounds = true
        blurredAvatarView.image = UIImage(named: "DefaultAvatar")
        
        if let avatar = CURRENT_USER.objectForKey("Avatar") as? BmobFile {
            let avatarURL = NSURL(string:avatar.url)
            let manager = SDWebImageManager()
            manager.downloadImageWithURL(avatarURL, options: SDWebImageOptions.RetryFailed, progress: nil) { (avatar, error, cacheType, finished, url) -> Void in
                self.avatarController = ZCSAvatarCaptureController()
                self.avatarController.delegate = self
                self.avatarController.image = avatar
                self.avatarView.image = avatar
                self.blurredAvatarView.image = avatar
                self.avatarView.userInteractionEnabled = true
                self.avatarView.addSubview(self.avatarController.view)
                
            }
        }else{
            self.avatarController = ZCSAvatarCaptureController()
            self.avatarController.delegate = self
            self.avatarView.userInteractionEnabled = true
            self.avatarView.addSubview(self.avatarController.view)
        }
        

      
    }
    
    override func viewWillAppear(animated: Bool) {
 
        userNameLabel.text = CURRENT_USER.objectForKey("username") as? String
    }
    
    func imageSelected(image: UIImage!) {
        self.blurredAvatarView.image = image
        let avatarData = UIImageJPEGRepresentation(image, 0.05)
        let newAvatar = BmobFile(fileName: "Avatar.jpg", withFileData: avatarData!)
        newAvatar.saveInBackground { (isSuccessful, error) -> Void in
            if isSuccessful {
                CURRENT_USER.setObject(newAvatar, forKey: "Avatar")
                CURRENT_USER.updateInBackground()
            }
        }
        
    

    }
    
    func imageSelectionCancelled() {
        print("Canc")
    }
    
    func popCurrentVC() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
   
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("detailedIdentifier") as! DetailedSettingsCell
            if indexPath.row == 1 {
           
                cell.titleLabel.text = "向我们推荐活动"
                 cell.titleLabel.textColor = FlatRed()
                cell.detailsLabel.text = "审核通过后你的推荐将出现在首页。"
              
                return cell
            }else if indexPath.row == 0 {
                let cell2 = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier") as! SettingsCell
                cell2.label.text = "我的订单"
                return cell2
            }else{
                cell.titleLabel.text = "向我们推荐好店/地点"
                cell.titleLabel.textColor = FlatRed()
                cell.detailsLabel.text = "你的推荐将出现在首页地点推荐中。"
                return cell
            }
            
        
    }
    
        if indexPath.section == 1 {
     let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier") as! SettingsCell
        switch indexPath.row {
        case 0: cell.label.text = "告诉朋友"
        case 1: cell.label.text = "反馈"
        case 2: cell.label.text = "入驻Remix"
        default: break
        }
       
        return cell
        }
        
    
            let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier") as! SettingsCell
            switch indexPath.row {
            case 0: cell.label.text = "清除缓存"
            case 1: cell.label.text = "显示使用指南"
            case 2: cell.label.text = "退出登录"

            default: break
            }
            
            return cell
        
        
}

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return 3
}
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 10
    }
    
  
    
    func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 2{
            return "    Remix 1.0, by Tianyi Fang. \n    Visit fongtinyik.tumblr.com for more info."
        }
        
        return nil
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0 : let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                let ordersVC = storyBoard.instantiateViewControllerWithIdentifier("OrdersVC")
                self.navigationController?.pushViewController(ordersVC, animated: true)
                
            case 1:
                let subm = ActivitySubmissionViewController()
                subm.isModal = false
                self.navigationController?.pushViewController(subm, animated: true)
                
            case 2:
                let subm = LocationSubmissionViewController()
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
            case 2 : if MFMailComposeViewController.canSendMail() {
                let composer = MFMailComposeViewController()
                composer.mailComposeDelegate = self
                let subjectString = NSString(format: "Remix平台组织入驻申请")
                let bodyString = NSString(format: "简介:\n\n\n\n\n\n-----\n组织所在城市: \n组织成立时间: \n组织名称:\n微信公众号ID:\n负责人联系方式:\n组织性质及分类:\n-----")
                composer.setMessageBody(bodyString as String, isHTML: false)
                composer.setSubject(subjectString as String)
                composer.setToRecipients(["fongtinyik@gmail.com", "remixapp@163.com"])
                self.presentViewController(composer, animated: true, completion: nil)
                }
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
            case 2: BmobUser.logout()
            let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
            let regLoginController = storyBoard.instantiateViewControllerWithIdentifier("RegLoginVC")
            self.tr_presentViewController(regLoginController, method: TRPresentTransitionMethod.Fade)
                
            default: break
            }
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}