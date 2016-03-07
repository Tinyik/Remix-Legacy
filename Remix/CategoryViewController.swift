//
//  CategoryViewController.swift
//  Remix
//
//  Created by fong tinyik on 2/5/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit
import TTGSnackbar
protocol ActivityFilterDelegate {
    func filterQueryWithCategoryOrLabelName(name: String)
    func setParallaxHeaderImage(headerImageURL: NSURL)
}

class CategoryViewController: UITableViewController {
    
    var categoryName = ""
    var delegate: ActivityFilterDelegate!
    var filteredParallaxImageURL: NSURL!
    

    var coverImageURLs: [NSURL] = []
    var coverTitles: [String] = []
    var cloudCoverTitles: [String] = []

    @IBOutlet weak var showGallery: UIImageView!
    @IBOutlet weak var showLiked: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViews()
        fetchCloudData()
        tableView.separatorStyle = .None
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.contentInset.top = 90
        showGallery.userInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: "showGalleryAction")
        showGallery.addGestureRecognizer(tap)
        showGallery.clipsToBounds = true
        showGallery.contentMode = .ScaleAspectFill
        showGallery.layer.cornerRadius = 8

    }

    func setUpViews() {
        self.navigationItem.hidesBackButton = true
        showGallery.userInteractionEnabled = true
        let tapShowGallery = UITapGestureRecognizer(target: self, action: "showGalleryAction")
        showGallery.addGestureRecognizer(tapShowGallery)
        showGallery.clipsToBounds = true
        showGallery.contentMode = .ScaleAspectFill
        showGallery.layer.cornerRadius = 8
        showLiked.userInteractionEnabled = true
        let tapShowLiked = UITapGestureRecognizer(target: self, action: "showLikedAction")
        showLiked.addGestureRecognizer(tapShowLiked)
        showLiked.clipsToBounds = true
        showLiked.contentMode = .ScaleAspectFill
        showLiked.layer.cornerRadius = 8
        let likedMaskView = UIView(frame: CGRectMake(0,0,500,500))
        likedMaskView.backgroundColor = .blackColor()
        likedMaskView.alpha = 0.3
        let galleryMaskView = UIView(frame: CGRectMake(0,0,500,500))
        galleryMaskView.backgroundColor = .blackColor()
        galleryMaskView.alpha = 0.3
        showLiked.addSubview(likedMaskView)
        showGallery.addSubview(galleryMaskView)
        
    }
    
    
    func fetchCloudData() {
        let query = BmobQuery(className: "Category")
        query.whereKey("isVisibleToUsers", equalTo: true)
        query.findObjectsInBackgroundWithBlock { (categories, error) -> Void in
            if error == nil {
                for category in categories {
                    let databaseName = category.objectForKey("Name") as! String
                    self.cloudCoverTitles.append(databaseName)
                    let url = NSURL(string: (category.objectForKey("CoverImage") as! BmobFile).url)
                    self.coverImageURLs.append(url!)
                    let displayName = category.objectForKey("DisplayName") as! String
                    self.coverTitles.append(displayName)
                }
                self.tableView.reloadData()
            }
            
        }
    }
    
    
    func showGalleryAction() {
        self.performSegueWithIdentifier("showGallery", sender: nil)
        print("Success")
    }
    
    func showLikedAction() {
         self.performSegueWithIdentifier("showLiked", sender: nil)
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! CTTableViewCell
        cell.coverImageView.sd_setImageWithURL(coverImageURLs[indexPath.row], placeholderImage: UIImage(named: "SDPlaceholder"))
        cell.titleLabel.text = coverTitles[indexPath.row]
        
        return cell

    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coverImageURLs.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if launchedTimes! == 1 && shouldAskToEnableNotif {
            askToEnableNotifications()
            shouldAskToEnableNotif = false
        }

        let query = BmobQuery(className: "Category")
        query.whereKey("isVisibleToUsers", equalTo: true)
        query.whereKey("Name", equalTo: cloudCoverTitles[indexPath.row])
        query.findObjectsInBackgroundWithBlock { (categories, error) -> Void in
            if error == nil {
                for category in categories {
                    category.incrementKey("PageView", byAmount: 1)
                    category.updateInBackground()
                }
            }else{
                let snackBar = TTGSnackbar.init(message: "获取数据失败。请检查网络连接后重试。", duration: .Middle)
                snackBar.backgroundColor = FlatWatermelonDark()
                snackBar.show()
            }
        }
        self.categoryName = cloudCoverTitles[indexPath.row]
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        filteredParallaxImageURL = coverImageURLs[indexPath.row]
        self.performSegueWithIdentifier("showFilteredView", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("pre")
        if segue.identifier == "showFilteredView" {
            if let fVC = segue.destinationViewController as? CTFilteredViewController {
               
                self.delegate = fVC
                self.delegate.filterQueryWithCategoryOrLabelName(categoryName)
                self.delegate.setParallaxHeaderImage(filteredParallaxImageURL)

            }
        }
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
