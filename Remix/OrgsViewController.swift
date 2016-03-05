//
//  OrgsViewController.swift
//  Remix
//
//  Created by fong tinyik on 2/5/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit
import MessageUI

protocol OrganizationViewDelegate {
    func filterQueryWithOrganizationName(name: String)
    
}

class OrgsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource, MFMailComposeViewControllerDelegate, RMSwipeBetweenViewControllersDelegate {
    
    @IBOutlet weak var orgsCollectionView: UICollectionView!
    
    var organizationName = ""
    var delegate: OrganizationViewDelegate!
    var filteredParallaxImageURL: NSURL!
    
    var logoURLs: [NSURL] = []
    var names: [String] = []
    let refreshCtrl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        orgsCollectionView.delegate = self
        orgsCollectionView.dataSource = self
        orgsCollectionView.emptyDataSetDelegate = self
        orgsCollectionView.emptyDataSetSource = self
        orgsCollectionView.contentInset.top = 40
        orgsCollectionView.alwaysBounceVertical = true
        refreshCtrl.addTarget(self, action: "refresh", forControlEvents: .ValueChanged)
        orgsCollectionView.addSubview(refreshCtrl)
        fetchCloudData()

    }
    
    
    
    func fetchCloudData() {
        logoURLs = []
        names = []
        
        let query = BmobQuery(className: "Organization")
        query.whereKey("isVisibleToUsers", equalTo: true)
        query.whereKey("Cities", containedIn: [REMIX_CITY_NAME])
        query.findObjectsInBackgroundWithBlock { (organizations, error) -> Void in
            if self.refreshCtrl.refreshing {
               self.refreshCtrl.endRefreshing()
            }
            for org in organizations {
                let name = org.objectForKey("Name") as! String
                let logoFile = org.objectForKey("Logo") as! BmobFile
                let logoURL = NSURL(string: logoFile.url)!
                self.names.append(name)
                self.logoURLs.append(logoURL)
            }
            if self.orgsCollectionView != nil {
            self.orgsCollectionView.reloadData()
            }
        }
    }
    
    func refresh() {
        refreshCtrl.beginRefreshing()
        fetchCloudData()
    }
    
    func refreshViewContentForCityChange() {
        refresh()
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
 
    
  
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return CGSizeMake(collectionView.frame.size.width/3, 130)
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    

    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return names.count
    }
    
    
     func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = orgsCollectionView.dequeueReusableCellWithReuseIdentifier("reuseIdentifier", forIndexPath: indexPath) as! OrgCell
        cell.logoImageView.sd_setImageWithURL(logoURLs[indexPath.row], placeholderImage: UIImage(named: "SDPlaceholder"))
        cell.orgNameLabel.text = names[indexPath.row]
        
        
        return cell
        
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        orgsCollectionView.deselectItemAtIndexPath(indexPath, animated: false)
        if launchedTimes! == 1 && shouldAskToEnableNotif {
            askToEnableNotifications()
            shouldAskToEnableNotif = false
        }
        self.organizationName = names[indexPath.row]
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        self.performSegueWithIdentifier("showOrgHomepage", sender: nil)
        
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
      
        if segue.identifier == "showOrgHomepage" {
            if let fVC = segue.destinationViewController as? OrgFilteredViewController {
                
                self.delegate = fVC
                self.delegate.filterQueryWithOrganizationName(organizationName)
    
                
            }
        }
    }
    
    //DZNEmptyDataSet
    
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        
        let attrDic = [NSFontAttributeName: UIFont.systemFontOfSize(19)]
        return NSAttributedString(string: "(:3[____] 这座城市似乎非常地冷清...\n", attributes: attrDic)
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let attrDic = [NSFontAttributeName: UIFont.systemFontOfSize(15)]
        return NSAttributedString(string: "马上入驻Remix，成为这个城市里的第一个组织吧！", attributes: attrDic)
    }
    
    func buttonTitleForEmptyDataSet(scrollView: UIScrollView!, forState state: UIControlState) -> NSAttributedString! {
        let attrDic = [NSFontAttributeName: UIFont.systemFontOfSize(17), NSForegroundColorAttributeName: FlatRed()]
        return NSAttributedString(string: "入驻Remix", attributes: attrDic)
    }
    
    func backgroundColorForEmptyDataSet(scrollView: UIScrollView!) -> UIColor! {
        return UIColor(red: 0.97255, green: 0.97255, blue: 0.97255, alpha: 1)
    }
    
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "NoData")
    }
    
    func emptyDataSetShouldAllowScroll(scrollView: UIScrollView!) -> Bool {
        return false
    }
    
    func emptyDataSet(scrollView: UIScrollView!, didTapButton button: UIButton!) {
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
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func askToEnableNotifications() {
        print("asking..")
        let userDefault = NSUserDefaults.standardUserDefaults()
        sharedOneSignalInstance.IdsAvailable { (userId, pushToken) -> Void in
            if pushToken != nil {
                userDefault.setBool(true, forKey: "isRegisteredForNotif")
                print(pushToken)
            }else{
                userDefault.setBool(false, forKey: "isRegisteredForNotif")
                print("nil token")
            }
            
        }
        if let key = userDefault.objectForKey("isRegisteredForNotif") as? Bool {
            print("KEYNOTNIL")
            print(key)
            if key == false {
                let alert = UIAlertController(title: "推送设置", message: "Remix需要你允许推送消息才能及时传递当前城市学生圈的最新消息。想要现在允许推送消息吗？(●'◡'●)ﾉ♥", preferredStyle: .Alert)
                let buttonOK = UIAlertAction(title: "好的", style: .Default) { (action) -> Void in
                    self.promptToEnableNotifications()
                }
                let buttonCancel = UIAlertAction(title: "不了谢谢", style: .Default, handler: nil)
                alert.addAction(buttonCancel)
                alert.addAction(buttonOK)
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }else{
            let alert = UIAlertController(title: "推送设置", message: "Remix需要你允许推送消息才能及时传递当前城市学生圈的最新消息。想要现在允许推送消息吗？(●'◡'●)ﾉ♥", preferredStyle: .Alert)
            let buttonOK = UIAlertAction(title: "好的", style: .Default) { (action) -> Void in
                self.promptToEnableNotifications()
            }
            let buttonCancel = UIAlertAction(title: "不了谢谢", style: .Default, handler: nil)
            alert.addAction(buttonCancel)
            alert.addAction(buttonOK)
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
        
        
    }
    
    func promptToEnableNotifications() {
        
        if hasPromptedToEnableNotif == false {
            sharedOneSignalInstance.registerForPushNotifications()
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setObject(true, forKey: "hasPromptedToEnableNotif")
            hasPromptedToEnableNotif = true
            
        }else{
            
            let instruction = UIAlertController(title: "如何开启消息通知", message: "请进入 设置->通知->Remix->允许通知 来开启Remix推送消息。", preferredStyle: .Alert)
            let ok = UIAlertAction(title: "好的", style: .Default, handler: nil)
            instruction.addAction(ok)
            self.presentViewController(instruction, animated: true, completion: nil)
            
        }
    }


  
}
