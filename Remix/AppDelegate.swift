//
//  AppDelegate.swift
//  Remix
//
//  Created by fong tinyik on 2/5/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit

@UIApplicationMain


class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
       // hack_uiimageview_bf()
        self.window?.tintColor = .whiteColor()
        let image = UIImage(named: "back")
       
        Bmob.registerWithAppKey("08329e2e3a8d3cdde96bf91d7459e8ab")
      //  BmobPaySDK.registerWithAppKey("08329e2e3a8d3cdde96bf91d7459e8ab")
        MobClick.startWithAppkey("56ba8fa2e0f55a1071000931", reportPolicy: BATCH, channelId: nil)
        
        if BmobUser.getCurrentUser() == nil {
            
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
        
        let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let vc1 = storyBoard.instantiateViewControllerWithIdentifier("MainVC")
        let vc2 = storyBoard.instantiateViewControllerWithIdentifier("CategoryVC")
        let vc3 = storyBoard.instantiateViewControllerWithIdentifier("OrgsVC")
        let pageController = RMPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
        naviController = RKSwipeBetweenViewControllers(rootViewController: pageController)
        naviController.viewControllerArray.addObjectsFromArray([vc1, vc2, vc3])
        naviController.buttonText = ["活动", "分类", "组织"]
        self.window?.rootViewController = naviController
        }
        
        self.window?.makeKeyAndVisible()
        
        return true
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let currentInstallation = BmobInstallation.currentInstallation()
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
            print("skldjlk")
            AlipaySDK.defaultService().processOrderWithPaymentResult(url, standbyCallback: { (resultDic) -> Void in
              
            })
            
        }
        
        return true
    }
}

