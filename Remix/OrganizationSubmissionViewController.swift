//
//  OrganizationSubmissionViewController.swift
//  Remix
//
//  Created by fong tinyik on 3/11/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit
import Eureka
import SDWebImage
import TTGSnackbar

class OrganizationSubmissionViewController: FormViewController {

    var cities: [String] = []
    let orgNatures = ["公益性学生组织", "公益性社会组织", "社会企业", "学生公司"]
    var isModal = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpParallaxHeaderView()
        SwitchRow.defaultCellSetup = { cell, row in cell.switchControl!.onTintColor = FlatRed() }
        TextFloatLabelRow.defaultCellSetup = { cell, row in cell.textField.textColor = FlatRed() }
        URLFloatLabelRow.defaultCellSetup = { cell, row in cell.textField.textColor = FlatRed() }
        TextAreaRow.defaultCellSetup = { cell, row in cell.textView.alpha = 0.7 }
        self.navigationController?.hidesNavigationBarHairline = true
        self.title = "入驻Remix"
        if isModal == true {
            let statusBarView = UIView(frame: CGRectMake(0,0,DEVICE_SCREEN_WIDTH,20))
            statusBarView.backgroundColor = FlatBlueDark()
            self.navigationController?.view.addSubview(statusBarView)
        }
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "提交", style: .Plain, target: self, action: "submitOrganization:")
        if isModal == true {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "关闭", style: .Plain, target: self, action: "popCurrentVC")
            self.navigationController?.navigationBar.translucent = false
            
        }

        self.form
        +++
        Section("组织基本信息")
            <<< TextFloatLabelRow("Name") {
                $0.title = "组织名称"
            }
            <<< TextFloatLabelRow("WechatId") {
                $0.title = "微信号 (如果有)"
            }
            <<< TextFloatLabelRow("BriefIntro") {
                $0.title = "一句话简介"
            }

        
        form +++ SelectableSection<ImageCheckRow<String>, String>() { section in
            section.header = HeaderFooterView(title: "组织性质(单选)")
        }
        
        for option in orgNatures {
            form.last! <<< ImageCheckRow<String>(option){ lrow in
                lrow.title = option
                lrow.selectableValue = option
                lrow.tag = option
                lrow.value = nil
            }
        }
        form +++
        Section("组织公开介绍")
            <<< TextFloatLabelRow("IntroTitle1") {
                $0.title = "主标题一"
            }
            <<< TextAreaRow("IntroParagraph1") {
                $0.placeholder = "段落一"
            }
            <<< ImageRow("IntroImage1") {
                $0.title = "段落图一     >>>"
            }
            <<< TextFloatLabelRow("IntroTitle2") {
                $0.title = "主标题二"
            }

            <<< TextAreaRow("IntroParagraph2") {
                $0.placeholder = "段落二"
            }
            <<< ImageRow("IntroImage2") {
                $0.title = "段落图二     >>>"
            }
        +++
        Section("素材")
            <<< ImageRow("Logo") {
                $0.title = "正方形组织Logo图     >>>"
            }
            <<< ImageRow("HomePageCoverImage") {
                $0.title = "组织首页封面图     >>>"
            }
       
        fetchCloudData()

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
                self.form
                +++
                    Section("联络人信息")
                    
                    <<< NameRow("ContactName") {
                        $0.title = "姓名"
                        $0.placeholder = "姓名"
                        
                    }
                    <<< PhoneRow("Contact") {
                        $0.title = "手机号"
                        $0.placeholder = "手机号"
                        
                    }
                    <<< EmailRow("Emails") {
                        $0.title = "邮箱"
                        $0.placeholder = "邮箱"
                    }
                    <<< TextRow("ContactWechat") {
                        $0.title = "微信"
                        $0.placeholder = "微信"
                }

            }
        })
        
    }
    
    func checkInformationIntegrity() -> Bool {
        let attr = form.values(includeHidden: false)
        for (key, value) in attr {
            if cities.contains(key) == false {
                if orgNatures.contains(key) == false {
                    if key != "WechatId" {
                        if attr[key]! == nil {
                            return false
                        }
                    }
                }
            }
        }
        return true
    }
    
    func submitOrganization(sender: UIBarButtonItem) {
        let attr = form.values(includeHidden: false)
        if checkInformationIntegrity() {
            var selectedCities: [String] = []
            let newOrg = AVObject(className: "Organization")
            for (key, value) in attr {
                if let pic = value as? UIImage {
                    let imageData = UIImageJPEGRepresentation(pic, 0.5)
                    let newImage = AVFile(name: "CoverImg.jpg", data: imageData!)
                    if newImage.save() {
                        newOrg.setObject(newImage, forKey: key)
                    }
                }
                
                if cities.contains(key) == false {
                    if orgNatures.contains(key) == false{
                        if let str = value as? String {
                            if key == "Emails" {
                                newOrg.setObject([str], forKey: "Emails")
                            }else if key == "Name"{
                                newOrg.setObject("用户提交" + str, forKey: key)
                            }else{
                                newOrg.setObject(str, forKey: key)
                            }
                        }

                    }else{
                        if attr[key]! != nil {
                            newOrg.setObject(key as! String, forKey: "Nature")
                        }
                    }
                
                }else{
                    if attr[key]! != nil{
                        selectedCities.append(key)
                    }
                }
            }
                 selectedCities.insert("全国", atIndex: 0)
                 newOrg.setObject(selectedCities, forKey: "Cities")
                 newOrg.setObject(0, forKey: "PageView")
                 newOrg.setObject(false, forKey: "isVisibleToUsers")
                 sender.enabled = false
                 newOrg.saveInBackgroundWithBlock({ (isSuccessful, error) -> Void in
                    sender.enabled = true
                    if error == nil {
                        sharedOneSignalInstance.sendTag(attr["Name"] as! String, value: "OrgSubmitted")
                        let c = CURRENT_USER.objectForKey("Credit") as! Int
                        CURRENT_USER.setObject(c+100, forKey: "Credit")
                        CURRENT_USER.saveInBackground()
                        AVOSCloud.requestSmsCodeWithPhoneNumber(CURRENT_USER.mobilePhoneNumber, templateName: "OrganizationSubm_Success", variables: nil, callback: nil)
                        let alert = UIAlertController(title: "Remix提示", message: "组织信息提交成功。谢谢你对Remix的支持_(:з」∠)_。审核通过后我们将给你发送推送消息。", preferredStyle: .Alert)
                        let action = UIAlertAction(title: "好的", style: .Default, handler: { (action) -> Void in
                            self.popCurrentVC()
                        })
                        alert.addAction(action)
                        let notif = UIView.loadFromNibNamed("NotifView") as! NotifView
                        notif.parentvc = self
                        notif.promptUserCreditUpdate("100", withContext: "提交组织信息", andAlert: alert)


                    }
                 })
        }else{
            let snackBar = TTGSnackbar.init(message: "组织信息提交失败，请检查信息是否已填写完整。", duration: .Middle)
            snackBar.backgroundColor = FlatWatermelonDark()
            snackBar.alpha = 0.9
            snackBar.show()
        }

    }
    func setUpParallaxHeaderView() {
        let manager = SDWebImageManager()
        let query = AVQuery(className: "UIRemoteConfig")
        query.getObjectInBackgroundWithId("56ea40b6f3609a00544ed773") { (remix, error) -> Void in
            if error == nil {
                let url = NSURL(string: (remix.objectForKey("OrganizationSubm_Image") as! AVFile).url)
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
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if let headerView = self.tableView?.tableHeaderView as? ParallaxHeaderView {
            headerView.layoutHeaderViewForScrollViewOffset(scrollView.contentOffset)
            
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        if let headerView = tableView!.tableHeaderView as? ParallaxHeaderView {
            headerView.refreshBlurViewForNewImage()
        }
        
        super.viewDidAppear(animated)
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


   
}
