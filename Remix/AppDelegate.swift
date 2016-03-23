//
//  AppDelegate.swift
//  Remix
//
//  Created by fong tinyik on 2/5/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit
import ChameleonFramework

@UIApplicationMain


class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        application.applicationSupportsShakeToEdit = true
        sharedOneSignalInstance = OneSignal(launchOptions: launchOptions, appId: "7a1e4c8b-51f0-49f1-b50a-72cc581121a0", handleNotification: nil, autoRegister: false)
        OneSignal.defaultClient().enableInAppAlertNotification(true)
       // Bmob.registerWithAppKey("08329e2e3a8d3cdde96bf91d7459e8ab")
        AVOSCloud.setApplicationId("pMgQDhdomi8mGsWMyaVYHwfd-gzGzoHsz", clientKey: "UrHd4YHc9sjdgxNXhNbDh5dR")
        BmobPaySDK.registerWithAppKey("08329e2e3a8d3cdde96bf91d7459e8ab")
        MobClick.startWithAppkey("56ba8fa2e0f55a1071000931", reportPolicy: BATCH, channelId: nil)
        if AVUser.currentUser() == nil {
            
            let infoDictionary = NSBundle.mainBundle().infoDictionary
            let currentAppVersion = infoDictionary!["CFBundleShortVersionString"] as! String
            
            
            let userDefaults = NSUserDefaults.standardUserDefaults()
            
            let appVersion = userDefaults.stringForKey("appVersion")
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            if appVersion == nil || appVersion != currentAppVersion {
                
                userDefaults.setValue(currentAppVersion, forKey: "appVersion")
                
                let guideViewController = storyboard.instantiateViewControllerWithIdentifier("GuideViewController") as! GuideViewController
                self.window?.rootViewController = guideViewController
               
            }else{
               
                let rootVC = storyboard.instantiateViewControllerWithIdentifier("RegLoginVC") as! RegLoginViewController
                self.window?.rootViewController = rootVC
                
            }

           
            
        }else{
        CURRENT_USER = AVUser.currentUser()
        let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let vc1 = storyBoard.instantiateViewControllerWithIdentifier("MainVC")
        let vc2 = storyBoard.instantiateViewControllerWithIdentifier("CategoryVC")
        let vc3 = storyBoard.instantiateViewControllerWithIdentifier("OrgsVC")
        let pageController = RMPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
        naviController = RMSwipeBetweenViewControllers(rootViewController: pageController)
        naviController.viewControllerArray.addObjectsFromArray([vc1, vc2, vc3])
        naviController.buttonText = ["活动", "分类", "组织"]
        REMIX_CITY_NAME = CURRENT_USER.objectForKey("City") as! String
        sharedOneSignalInstance.sendTag("City", value: REMIX_CITY_NAME)
        naviController.navigationBar.translucent = true
        naviController.rm_delegate = vc1 as! RMSwipeBetweenViewControllersDelegate
        naviController.rm_delegate2 = vc3 as! RMSwipeBetweenViewControllersDelegate
        self.window?.rootViewController = naviController

        }
        
        self.window?.makeKeyAndVisible()
        
        return true
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let currentInstallation = AVInstallation.currentInstallation()
        currentInstallation.setDeviceTokenFromData(deviceToken)
        currentInstallation.saveInBackground()
        
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        if url.host == "safepay" {
            AlipaySDK.defaultService().processOrderWithPaymentResult(url, standbyCallback: { (resultDic) -> Void in
              
            })
            
        }
        
       
        
        if url.scheme == "remix" && url.host?.containsString("www.") == true{
            
            if AVUser.currentUser() != nil {
                if url.path != "" {
                    let targetURL = url.host! + url.path!
                    let webView = RxWebViewController(url: NSURL(string: "http://" + targetURL))
                    (self.window?.rootViewController as! RMSwipeBetweenViewControllers).pushViewController(webView, animated: true)
                }else{
                
                    let webView = RxWebViewController(url: NSURL(string: "http://" + url.host!))
                    if let vc = self.window?.rootViewController as? RMSwipeBetweenViewControllers {
                        vc.pushViewController(webView, animated: true)
                    }else{
                        let alert = UIAlertController(title: "Remix提示", message: "请重启Remix后再次打开此链接。", preferredStyle: .Alert)
                        let action = UIAlertAction(title: "好的", style: .Default, handler: nil)
                        alert.addAction(action)
                        self.window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
                    }
                    
                }
                
            }else{
                let alert = UIAlertController(title: "Remix提示", message: "(:3[____] 登录Remix来查看网页的详细信息。", preferredStyle: .Alert)
                let action = UIAlertAction(title: "好的", style: .Default, handler: nil)
                alert.addAction(action)
                self.window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
                
            }
            
            
        }else if url.scheme == "remix" && url.host?.characters.count > 0 && url.path?.characters.count > 0 && url.query?.characters.count > 0 {
            if AVUser.currentUser() != nil {
                let newActivity = AVObject(className: "UnderReview")
                newActivity.setObject(url.host, forKey: "URL")
                newActivity.setObject(url.path, forKey: "Org")
                newActivity.setObject(url.query, forKey: "Price")
                newActivity.setObject(AVUser.currentUser().objectId, forKey: "UserObjectId")
                newActivity.setObject(AVUser.currentUser().mobilePhoneNumber, forKey: "PhoneNumber")
                newActivity.saveInBackgroundWithBlock({ (isSuccessul, error) -> Void in
                    if error == nil {
                        let alert = UIAlertController(title: "Remix提示", message: "活动添加成功。审核通过后活动将在Remix中显示。", preferredStyle: .Alert)
                        let action = UIAlertAction(title: "好的", style: .Default, handler: nil)
                        alert.addAction(action)
                        self.window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)

                    }else{
                        let alert = UIAlertController(title: "Remix提示", message: "活动添加失败，请检查你的网络后再试一次。", preferredStyle: .Alert)
                        let action = UIAlertAction(title: "好的", style: .Default, handler: nil)
                        alert.addAction(action)
                        self.window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
                    }
                })
                
            }else{
                let alert = UIAlertController(title: "Remix提示", message: "请先登录Remix再提交活动。", preferredStyle: .Alert)
                let action = UIAlertAction(title: "好的", style: .Default, handler: nil)
                alert.addAction(action)
                self.window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
            }
        }else if url.scheme == "remix" && url.host == "join"{
            if AVUser.currentUser() != nil {
                let subm = OrganizationSubmissionViewController()
                let navi = RMNavigationController(rootViewController: subm)
                self.window?.rootViewController?.presentViewController(navi, animated: true, completion: nil)
            }else{
                let alert = UIAlertController(title: "Remix提示", message: "请先登录Remix再提交组织信息。", preferredStyle: .Alert)
                let action = UIAlertAction(title: "好的", style: .Default, handler: nil)
                alert.addAction(action)
                self.window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)

            }
                
        }else if url.scheme == "remix" && url.host?.characters.count > 0 && url.path?.characters.count == 0 && url.query == nil {
            if AVUser.currentUser() != nil {
                let query = AVQuery(className: "Activity")
                var activity = AVObject()
                query.whereKey("ShortId", equalTo: url.host!)
                query.findObjectsInBackgroundWithBlock({ (activities, error) -> Void in
                    if error == nil {
                        if activities.count == 1 {
                            activity = activities[0] as! AVObject
                            let activityView = RMActivityViewController(url: NSURL(string: activity.objectForKey("URL") as! String))
                            activityView.activity = activity
                            activityView.toolBar.likeButton.hidden = true
                            if let vc = self.window?.rootViewController as? RMSwipeBetweenViewControllers {
                                vc.pushViewController(activityView, animated: true)
                            }else{
                                let alert = UIAlertController(title: "Remix提示", message: "请重启Remix后再次打开此链接。", preferredStyle: .Alert)
                                let action = UIAlertAction(title: "好的", style: .Default, handler: nil)
                                alert.addAction(action)
                                self.window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
                            }
                            
                        }else{
                           
                            let alert = UIAlertController(title: "Remix提示", message: "_(´ཀ`」 ∠)_ 这里没有找到你想要的活动😢，看看Remix别的活动吧~", preferredStyle: .Alert)
                            let action = UIAlertAction(title: "好的", style: .Default, handler: nil)
                            alert.addAction(action)
                            self.window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
                        }
                        
                    }else{
                        let alert = UIAlertController(title: "Remix提示", message: "_(´ཀ`」 ∠)_ 这里没有找到你想要的活动😢，看看Remix别的活动吧~", preferredStyle: .Alert)
                        let action = UIAlertAction(title: "好的", style: .Default, handler: nil)
                        alert.addAction(action)
                        self.window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
                    }
                    
                })

            }else{
                
                let alert = UIAlertController(title: "Remix提示", message: "这个活动这么精彩，赶紧登录Remix来报名吧~", preferredStyle: .Alert)
                let action = UIAlertAction(title: "好的", style: .Default, handler: nil)
                alert.addAction(action)
                self.window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
            }

        }
        
    
        return true
    }
}

