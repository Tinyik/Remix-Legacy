//
//  RMSwipeBetweenViewControllers.swift
//  Remix
//
//  Created by fong tinyik on 3/2/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit
import MessageUI
import CBZSplashView

protocol RMSwipeBetweenViewControllersDelegate {
    func refreshViewContentForCityChange()
}

class RMSwipeBetweenViewControllers: RKSwipeBetweenViewControllers, MFMailComposeViewControllerDelegate, LCActionSheetDelegate {

    var cityNameArray: [String] = []
    var rm_delegate: RMSwipeBetweenViewControllersDelegate!
    var rm_delegate2: RMSwipeBetweenViewControllersDelegate!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.cityLabel.text = REMIX_CITY_NAME
        self.cityLabel.sizeToFit()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let image = UIImage(named: "SplashLogo")
        let bgColor = FlatBlueDark()
        let splashView = CBZSplashView(icon: image, backgroundColor: bgColor)
        self.view.addSubview(splashView)
        splashView.animationDuration = 1.2
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            splashView.startAnimation()
        }

    }
    
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
                    let bodyString = NSString(format: "简介:\n\n\n\n\n\n-----\n组织所在城市: \n组织成立时间: \n组织名称:\n微信公众号ID:\n负责人联系方式:\n组织性质及分类:\n-----")
                    composer.setMessageBody(bodyString as String, isHTML: false)
                    composer.setSubject(subjectString as String)
                    composer.setToRecipients(["fongtinyik@gmail.com", "remixapp@163.com"])
                    self.presentViewController(composer, animated: true, completion: nil)
                }

            }
        }
        
        sheet.show()
    }
    
    override func switchRemixCity() {
        cityNameArray = []
        print("Switch")
        let query = BmobQuery(className: "SupportedCities")
        query.whereKey("isVisibleToUsers", equalTo: true)
        query.findObjectsInBackgroundWithBlock { (cities, error) -> Void in
            if error == nil {
                for city in cities {
                    self.cityNameArray.append(city.objectForKey("CityName") as! String)
                }
                let sheet = LCActionSheet(title: "请选择你所在的城市。Remix团队将积极更新并尽快支持更多城市。", buttonTitles: self.cityNameArray + ["全国", "申请开通城市"], redButtonIndex: self.cityNameArray.count + 1, delegate: self)
                sheet.show()
                print("COUNT")
                print(self.cityNameArray)
            }
        }
       
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func actionSheet(actionSheet: LCActionSheet!, didClickedButtonAtIndex buttonIndex: Int) {
       
        if buttonIndex == cityNameArray.count {
            REMIX_CITY_NAME = "全国"
            CURRENT_USER.setObject(REMIX_CITY_NAME, forKey: "City")
            CURRENT_USER.updateInBackgroundWithResultBlock({ (isSuccessful, error) -> Void in
                if error == nil {
                    sharedOneSignalInstance.sendTag("City", value: REMIX_CITY_NAME)
                }
            })
            self.rm_delegate.refreshViewContentForCityChange()
            self.rm_delegate2.refreshViewContentForCityChange()
            self.cityLabel.text = REMIX_CITY_NAME
            self.cityLabel.sizeToFit()
        }else if buttonIndex == cityNameArray.count + 1{
            //Apply for new city...
            
        }else if buttonIndex != cityNameArray.count + 2{
            REMIX_CITY_NAME = cityNameArray[buttonIndex]
            CURRENT_USER.setObject(REMIX_CITY_NAME, forKey: "City")
            CURRENT_USER.updateInBackgroundWithResultBlock({ (isSuccessful, error) -> Void in
                if error == nil {
                    sharedOneSignalInstance.sendTag("City", value: REMIX_CITY_NAME)
                }
            })
            self.rm_delegate.refreshViewContentForCityChange()
            self.rm_delegate2.refreshViewContentForCityChange()
            self.cityLabel.text = REMIX_CITY_NAME
            self.cityLabel.sizeToFit()
        }
    }
    
}
