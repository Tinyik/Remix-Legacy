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
import TTGSnackbar
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
        
        let sheet = LCActionSheet(title: "添加活动或地点至Remix。审核通过后其他用户将看到你的推荐。", buttonTitles: ["添加一条活动", "推荐一家店或地点", "添加往期活动报道", "入驻Remix"], redButtonIndex: -1) { (buttonIndex) -> Void in
            if self.checkPersonalInfoIntegrity() {
                if buttonIndex == 0 {
                    let submVC = ActivitySubmissionViewController()
                    let navigationController = UINavigationController(rootViewController: submVC)
                    self.presentViewController(navigationController, animated: true, completion: nil)
                }
                
                if buttonIndex == 1 {
                    let submVC = LocationSubmissionViewController()
                    let navigationController = UINavigationController(rootViewController: submVC)
                    self.presentViewController(navigationController, animated: true, completion: nil)
                    
                }
                
                if buttonIndex == 2 {
                    let submVC = GallerySubmissionViewController()
                    let navigationController = UINavigationController(rootViewController: submVC)
                    self.presentViewController(navigationController, animated: true, completion: nil)
                }
                
                if buttonIndex == 3 {
                    let submVC = OrganizationSubmissionViewController()
                    let navigationController = UINavigationController(rootViewController: submVC)
                    self.presentViewController(navigationController, animated: true, completion: nil)
                    
                }
            }else{
                let alert = UIAlertController(title: "完善信息", message: "(●'◡'●)ﾉ♥请先进入账户设置完善个人信息后再提交活动或地点", preferredStyle: .Alert)
                let action = UIAlertAction(title: "去设置", style: .Default, handler: { (action) -> Void in
                    self.presentSettingsVCFromNaviController()
                })
                let cancel = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
                alert.addAction(action)
                alert.addAction(cancel)
                self.presentViewController(alert, animated: true, completion: nil)
                
            }
            
        }
        
        sheet.show()
        
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
    
    
    override func switchRemixCity() {
        cityNameArray = []
        if self.cityLabel != nil {
            self.cityLabel.text = "切换中..."
            self.cityLabel.sizeToFit()
        }
        self.view.userInteractionEnabled = false
        let query = BmobQuery(className: "SupportedCities")
        query.whereKey("isVisibleToUsers", equalTo: true)
        query.findObjectsInBackgroundWithBlock { (cities, error) -> Void in
            self.cityLabel.text = REMIX_CITY_NAME
            self.cityLabel.sizeToFit()
            self.view.userInteractionEnabled = true
            if error == nil {
                for city in cities {
                    self.cityNameArray.append(city.objectForKey("CityName") as! String)
                }
                let sheet = LCActionSheet(title: "请选择你所在的城市。Remix团队将积极更新并尽快支持更多城市。", buttonTitles: self.cityNameArray + ["全国", "申请开通城市"], redButtonIndex: self.cityNameArray.count + 1, delegate: self)
                sheet.show()
                print("COUNT")
                print(self.cityNameArray)
            }else{
                let alert = UIAlertController(title: "Remix提示", message: "切换城市失败，请检查你的网络连接后重试", preferredStyle: .Alert)
                let action = UIAlertAction(title: "好的", style: .Default, handler: nil)
                alert.addAction(action)
                self.presentViewController(alert, animated: true, completion: nil)
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
                }else{
                    let snackBar = TTGSnackbar.init(message: "获取数据失败。请检查网络连接后重试。", duration: .Middle)
                    snackBar.backgroundColor = FlatWatermelonDark()
                    snackBar.show()
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
                }else{
                    let snackBar = TTGSnackbar.init(message: "获取数据失败。请检查网络连接后重试。", duration: .Middle)
                    snackBar.backgroundColor = FlatWatermelonDark()
                    snackBar.show()
                }
            })
            self.rm_delegate.refreshViewContentForCityChange()
            self.rm_delegate2.refreshViewContentForCityChange()
            self.cityLabel.text = REMIX_CITY_NAME
            self.cityLabel.sizeToFit()
        }
    }
    
}
