//
//  RMSwipeBetweenViewControllers.swift
//  Remix
//
//  Created by fong tinyik on 3/2/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit
import SafariServices
import MessageUI

class RMSwipeBetweenViewControllers: RKSwipeBetweenViewControllers, MFMailComposeViewControllerDelegate {

    
    override func recommendActivityAndLocation() {
        print("Clikced")
        let sheet = LCActionSheet(title: "添加活动或地点至Remix。审核通过后其他用户将看到你的推荐。", buttonTitles: ["添加一条活动", "推荐一家店或地点", "入驻Remix"], redButtonIndex: -1) { (buttonIndex) -> Void in
            if buttonIndex == 0 {
                 let webVC = RxWebViewController(url:NSURL(string: "http://jsform.com/f/v5pfam")!)
                 self.pushViewController(webVC, animated: true)
            }
            
            if buttonIndex == 1 {
                let webVC = RxWebViewController(url:NSURL(string: "http://jsform.com/f/j49bk8")!)
                self.pushViewController(webVC, animated: true)
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
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
   
}
