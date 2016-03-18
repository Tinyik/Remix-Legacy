//
//  LocationSubmissionViewController.swift
//  Remix
//
//  Created by fong tinyik on 3/7/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit
import Eureka
import TTGSnackbar
import SDWebImage

class LocationSubmissionViewController: FormViewController {
    
    var cities: [String] = []
     var isModal = true
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpParallaxHeaderView()
        SwitchRow.defaultCellSetup = { cell, row in cell.switchControl!.onTintColor = FlatRed() }
        TextFloatLabelRow.defaultCellSetup = { cell, row in cell.textField.textColor = FlatRed() }
        URLFloatLabelRow.defaultCellSetup = { cell, row in cell.textField.textColor = FlatRed() }
        TextAreaRow.defaultCellSetup = { cell, row in cell.textView.alpha = 0.7 }
        self.navigationController?.hidesNavigationBarHairline = true
        self.title = "提交地点至Remix"
        if isModal == true {
            let statusBarView = UIView(frame: CGRectMake(0,0,DEVICE_SCREEN_WIDTH,20))
            statusBarView.backgroundColor = FlatBlueDark()
            self.navigationController?.view.addSubview(statusBarView)
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "关闭", style: .Plain, target: self, action: "popCurrentVC")
            self.navigationController?.navigationBar.translucent = false
            
        }
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "提交", style: .Plain, target: self, action: "submitLocation:")
        
        form +++
        Section("身份")
            <<< SwitchRow("isCoordinator") {
            $0.title = "我是管理人员/店主"
            $0.value = false
            }
            
        +++
        Section("添加图片")
            <<< SwitchRow("isIntendToAddPic") {
                $0.title = "我有这里的照片"
                $0.value = false
        }
        for var i = 0; i <= 8; ++i {
            self.form[1]  <<< ImageRow("Pic" + String(i)){
                $0.title = "地点图片" + String(i+1) + "       >>>"
                if i == 0 {
                    $0.title = "地点图片" + String(i+1) + " (必填)       >>>"
                }
                $0.hidden = "$isIntendToAddPic == false"
            }
        }
        
     self.form   +++
        Section("地点信息")
            <<< TextFloatLabelRow("Title") {
                $0.title = "一句话点评"
            }
            <<< TextFloatLabelRow("Org") {
                $0.title = "机构/店家名称"
            }
            <<< TextFloatLabelRow("Location") {
                $0.title = "地址或大致位置"
            }
            <<< DecimalRow("Price"){
                $0.useFormatterDuringInput = true
                $0.title = "人均消费"
                $0.value = 0
                let formatter = CurrencyFormatter()
                formatter.locale = .currentLocale()
                formatter.numberStyle = .CurrencyStyle
                $0.formatter = formatter
            }
            <<< URLFloatLabelRow("URL") {
                $0.title = "地点推文链接或介绍网址链接"
                
            }
            <<< TextAreaRow("Description") {
                $0.placeholder = "地点简介。这里环境如何？有什么好吃的/好玩的/好看的?"
            }
       
            fetchCloudData()
        
 
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if isModal == true {
            self.navigationController?.hidesBarsOnSwipe = true
        }
        self.navigationController?.navigationBar.tintColor = .whiteColor()
        self.navigationController?.navigationBar.barTintColor = FlatBlueDark()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if isModal == false {
            self.navigationController?.navigationBar.tintColor = .blackColor()
            self.navigationController?.navigationBar.barTintColor = .whiteColor()
        }else{
            self.navigationController?.hidesBarsOnSwipe = false
        }
        
    }
    
    func popCurrentVC() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    func checkInformationIntegrity() -> Bool {
        let attr = form.values(includeHidden: false)
        if attr["isCoordinator"]! as! Bool == true{
            if attr["Title"]! == nil || attr["Org"]! == nil || attr["URL"]! == nil || attr["Description"]! == nil || attr["Location"]! == nil || attr["Contact"]! == nil || attr["ContactName"]! == nil{
                
                return false
                
            }
            
            if attr["isIntendToAddPic"]! as! Bool == true {
                if attr["Pic0"]! as? UIImage == nil {
                    return false
                }
            }
            
                       
        }else{
            if attr["Org"]! == nil || attr["Title"]! == nil || attr["Description"]! == nil || attr["Location"]! == nil {
                return false
            }
            if attr["isIntendToAddPic"]! as! Bool == true {
                if attr["Pic0"]! as? UIImage == nil {
                    return false
                }
            }

        }
        
        return true
    }
    func submitLocation(sender: UIBarButtonItem) {
        let attr = self.form.values()
        if checkInformationIntegrity() {
            sender.enabled = false
            let newActivity = AVObject(className: "Location")
            if attr["isCoordinator"]! as! Bool == true {
               
                var selectedCities: [String] = []
                newActivity.setObject(false, forKey: "isVisibleToUsers")
                for option in cities {
                    if attr[option]! != nil{
                        selectedCities.append(option)
                    }
                }
                selectedCities.insert("全国", atIndex: 0)
                newActivity.setObject(AVUser(withoutDataWithObjectId: AVUser.currentUser().objectId), forKey: "Submitter")
                newActivity.setObject("店主提交: " + (attr["Title"]! as! String), forKey: "Title")
                newActivity.setObject(attr["Org"] as! String, forKey: "Org")
                newActivity.setObject(String(attr["URL"]! as! NSURL), forKey: "URL")
                newActivity.setObject(attr["Price"]! as! Double, forKey: "Price")
                newActivity.setObject(attr["Description"]! as! String, forKey: "Description")
                newActivity.setObject(attr["Contact"] as! String, forKey: "Contact")
                newActivity.setObject(attr["Location"] as! String, forKey: "Location")
                newActivity.setObject(selectedCities, forKey: "Cities")
                newActivity.setObject(attr["ContactName"]as! String, forKey: "ContactName")
                newActivity.setObject(0, forKey: "PageView")
                newActivity.setObject(attr["isIntendToJoin"]! as! Bool, forKey: "isIntendToJoin")
                newActivity.setObject(attr["isOfferDiscount"]! as! Bool, forKey: "isOfferDiscount")
                if attr["UserRemarks"]! != nil {
                    newActivity.setObject(attr["UserRemarks"]! as! String, forKey: "UserRemarks")
                }
            
                if attr["WechatId"]! != nil {
                    newActivity.setObject(attr["WechatId"]! as! String, forKey: "WechatId")
                }
                if attr["Partners"]! != nil {
                    newActivity.setObject(attr["Partners"]! as! String, forKey: "Partners")
                }
               
            }else{
                var selectedCities: [String] = []
                let newActivity = AVObject(className: "Location")
                newActivity.setObject(false, forKey: "isVisibleToUsers")
                for option in cities {
                    if attr[option]! != nil{
                        selectedCities.append(option)
                    }
                }
                selectedCities.insert("全国", atIndex: 0)
                newActivity.setObject(AVUser(withoutDataWithObjectId: AVUser.currentUser().objectId), forKey: "Submitter")
                newActivity.setObject("用户提交: " + (attr["Title"]! as! String), forKey: "Title")
                newActivity.setObject(attr["Org"] as! String, forKey: "Org")
                newActivity.setObject(String(attr["URL"]! as! NSURL), forKey: "URL")
                newActivity.setObject(attr["Price"]! as! Double, forKey: "Price")
                newActivity.setObject(attr["Description"]! as! String, forKey: "Description")
                newActivity.setObject(attr["Location"] as! String, forKey: "Location")
                newActivity.setObject(selectedCities, forKey: "Cities")
                newActivity.setObject(0, forKey: "PageView")
                if attr["UserRemarks"]! != nil {
                    newActivity.setObject(attr["UserRemarks"]! as! String, forKey: "UserRemarks")
                }
            }
            if attr["isIntendToAddPic"]! as! Bool == true {
                for var i = 0; i <= 8; ++i {
                    if let image = attr["Pic" + String(i)]! as? UIImage {
                        let imageData = UIImageJPEGRepresentation(image, 0.5)
                        let imageFile = AVFile(name: "Image.jpg", data: imageData)
                        if imageFile.save() {
                            newActivity.setObject(imageFile, forKey: "Pic" + String(i))
                        }
                        
                    }
                }
                newActivity.saveInBackgroundWithBlock({ (isSuccessful, error) -> Void in
                    sender.enabled = true
                    if error == nil {
                        sharedOneSignalInstance.sendTag(attr["Title"] as! String, value: "LocationSubmitted")
                        let c = CURRENT_USER.objectForKey("Credit") as! Int
                        CURRENT_USER.setObject(c+50, forKey: "Credit")
                        CURRENT_USER.saveInBackground()
                        let notif = UIView.loadFromNibNamed("NotifView") as! NotifView
                        notif.promptUserCreditUpdate("50", inContext: "添加地点")

                        let alert = UIAlertController(title: "Remix提示", message: "地点添加成功。谢谢你对Remix的支持_(:з」∠)_。审核通过后我们将给你发送推送消息。", preferredStyle: .Alert)
                        let action = UIAlertAction(title: "好的", style: .Default, handler: { (action) -> Void in
                            self.popCurrentVC()
                        })
                        alert.addAction(action)
                        self.presentViewController(alert, animated: true, completion: nil)
                        
                    }else{
                        let snackBar = TTGSnackbar.init(message: "获取数据失败。请检查网络连接后重试。", duration: .Middle)
                        snackBar.backgroundColor = FlatWatermelonDark()
                        snackBar.show()
                    }
                })
            }else{
                newActivity.saveInBackgroundWithBlock({ (isSuccessful, error) -> Void in
                    sender.enabled = true
                    if error == nil {
                        sharedOneSignalInstance.sendTag(attr["Title"] as! String, value: "LocationSubmitted")
                        let c = CURRENT_USER.objectForKey("Credit") as! Int
                        CURRENT_USER.setObject(c+50, forKey: "Credit")
                        CURRENT_USER.saveInBackground()
                        let notif = UIView.loadFromNibNamed("NotifView") as! NotifView
                        notif.promptUserCreditUpdate("50", inContext: "添加地点")

                        let alert = UIAlertController(title: "Remix提示", message: "地点添加成功。谢谢你对Remix的支持_(:з」∠)_。审核通过后我们将给你发送推送消息。", preferredStyle: .Alert)
                        let action = UIAlertAction(title: "好的", style: .Default, handler: { (action) -> Void in
                            self.popCurrentVC()
                        })
                        alert.addAction(action)
                        self.presentViewController(alert, animated: true, completion: nil)
                    }else{
                        let snackBar = TTGSnackbar.init(message: "获取数据失败。请检查网络连接后重试。", duration: .Middle)
                        snackBar.backgroundColor = FlatWatermelonDark()
                        snackBar.show()
                    }
                })
            }

        }else{
            let snackBar = TTGSnackbar.init(message: "地点信息提交失败，请检查信息是否已填写完整。", duration: .Middle)
            snackBar.backgroundColor = FlatWatermelonDark()
            snackBar.alpha = 0.9
            snackBar.show()
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if let headerView = self.tableView?.tableHeaderView as? ParallaxHeaderView {
            headerView.layoutHeaderViewForScrollViewOffset(scrollView.contentOffset)
            
        }
        
    }
    
    func setUpParallaxHeaderView() {
        let manager = SDWebImageManager()
        let query = AVQuery(className: "UIRemoteConfig")
        query.getObjectInBackgroundWithId("56ea40b6f3609a00544ed773") { (remix, error) -> Void in
            if error == nil {
                let url = NSURL(string: (remix.objectForKey("LocationSubm_Image") as! AVFile).url)
                manager.downloadImageWithURL(url, options: .RetryFailed, progress: nil) { (image, error, type, bool, url) -> Void in
                    let headerView = ParallaxHeaderView.parallaxHeaderViewWithImage(image, forSize: CGSizeMake(UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.width/2)) as! ParallaxHeaderView
                    self.tableView!.tableHeaderView = headerView
                }
            }else{
                let snackBar = TTGSnackbar.init(message: "获取数据失败。请检查网络连接后重试。", duration: .Middle)
                snackBar.backgroundColor = FlatWatermelonDark()
                snackBar.show()
            }
            
        }
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        if let headerView = tableView!.tableHeaderView as? ParallaxHeaderView {
            headerView.refreshBlurViewForNewImage()
        }
        
        super.viewDidAppear(animated)
    }
    
    func fetchCloudData() {
        let query = AVQuery(className: "SupportedCities")
        query.whereKey("isVisibleToUsers", equalTo: true)
        query.findObjectsInBackgroundWithBlock({ (cities, error) -> Void in
            if error == nil {
                for city in cities {
                    self.cities.append(city.objectForKey("CityName") as! String)
                }
                self.form +++ SelectableSection<ImageCheckRow<String>, String>("所在城市(可多选)", selectionType: .MultipleSelection)
                for option in self.cities {
                    self.form.last! <<< ImageCheckRow<String>(option){ lrow in
                        lrow.title = "   " + option
                        lrow.tag = option
                        lrow.selectableValue = option
                        lrow.value = nil
                        }
                }
                
                self.form +++ Section("负责人联系方式", { (section) -> () in
                    section.hidden = "$isCoordinator == false"
                })
                    <<< NameRow("ContactName") {
                        $0.title = "姓名"
                        $0.placeholder = "姓名"
                        
                    }
                    <<< PhoneRow("Contact") {
                        $0.title = "手机号"
                        $0.placeholder = "手机号"
                        
                    }
                    <<< TwitterRow("WechatId") {
                        $0.title = "微信公众号（如果有）"
                        $0.placeholder = "公众号ID"
                }
                
                self.form +++
                    Section("附加信息", { (section) -> () in
                        section.hidden = "$isCoordinator == false"
                    })
                    <<< SwitchRow("isIntendToJoin") {
                        $0.title = "我希望以组织形式入驻Remix"
                        $0.value = false
                    }
                    <<< SwitchRow("isOfferDiscount") {
                        $0.title = "我愿意为Remix用户提供折扣"
                        $0.value = false
                    }
                    <<< TextAreaRow("Partners") {
                        $0.placeholder = "与这里有过合作关系的组织和个人"
                }
                
                self.form +++ Section("备注")
                    <<< TextAreaRow("UserRemarks") {
                        $0.placeholder = "备注及其他希望告知Remix的注意事宜"
                }


            }
        })
        
    }
    

}
