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
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "提交", style: .Plain, target: self, action: "submitOrganization")
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
            <<< TextFloatLabelRow("Intro") {
                $0.title = "一句话简介"
            }
        +++
        Section("组织公开介绍")
            <<< TextFloatLabelRow("Title1") {
                $0.title = "主标题一"
            }
            <<< TextAreaRow("Paragraph1") {
                $0.placeholder = "段落一"
            }
            <<< ImageRow("Image1") {
                $0.title = "段落图一     >>>"
            }
            <<< TextFloatLabelRow("Title2") {
                $0.title = "主标题二"
            }

            <<< TextAreaRow("Paragraph2") {
                $0.placeholder = "段落二"
            }
            <<< ImageRow("Image2") {
                $0.title = "段落图二     >>>"
            }
        +++
        Section("素材")
            <<< ImageRow("Logo") {
                $0.title = "正方形组织Logo图     >>>"
            }
            <<< ImageRow("CoverImg") {
                $0.title = "组织首页封面图     >>>"
            }
       
        fetchCloudData()

    }
    
    func fetchCloudData() {
        let query = BmobQuery(className: "SupportedCities")
        query.whereKey("isVisibleToUsers", equalTo: true)
        query.findObjectsInBackgroundWithBlock({ (cities, error) -> Void in
            if error == nil {
                for city in cities {
                    self.cities.append(city.objectForKey("CityName") as! String)
                }
                self.form +++ SelectableSection<ImageCheckRow<String>, String>("所在城市", selectionType: .MultipleSelection)
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
                    <<< PhoneRow("PhoneNumber") {
                        $0.title = "手机号"
                        $0.placeholder = "手机号"
                        
                    }
                    <<< EmailRow("Email") {
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
                if attr[key]! == nil {
                    return false
                }
            }
        }
        return true
    }
    
    func setUpParallaxHeaderView() {
        let manager = SDWebImageManager()
        let query = BmobQuery(className: "UIRemoteConfig")
        query.getObjectInBackgroundWithId("Cd3f1112") { (remix, error) -> Void in
            if error == nil {
                let url = NSURL(string: (remix.objectForKey("OrganizationSubm_Image") as! BmobFile).url)
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
