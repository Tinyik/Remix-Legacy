//
//  ActivitySubmissionViewController.swift
//  Remix
//
//  Created by fong tinyik on 3/6/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit
import Eureka
import TTGSnackbar
import SDWebImage

class ActivitySubmissionViewController: FormViewController {
    
    var cates: [BmobObject] = []
    var cities: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpParallaxHeaderView()
        SwitchRow.defaultCellSetup = { cell, row in cell.switchControl!.onTintColor = FlatRed() }
        TextFloatLabelRow.defaultCellSetup = { cell, row in cell.textField.textColor = FlatRed() }
        URLFloatLabelRow.defaultCellSetup = { cell, row in cell.textField.textColor = FlatRed() }
        TextAreaRow.defaultCellSetup = { cell, row in cell.textView.alpha = 0.7 }
        self.navigationController?.navigationBar.tintColor = .whiteColor()
        self.navigationController?.navigationBar.barTintColor = FlatBlueDark()
        self.navigationController?.navigationBar.translucent = false
        self.navigationController?.hidesNavigationBarHairline = true
        self.title = "提交活动至Remix"
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "提交", style: .Plain, target: self, action: "submitActivity")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "关闭", style: .Plain, target: self, action: "popCurrentVC")
        form +++
            
        
        Section("身份")
            <<< SwitchRow("isCoordinator") {
                $0.title = "我是活动主办方"
                $0.value = false
                }
            
        +++
        Section("活动信息")
            <<< TextFloatLabelRow("Title") {
                $0.title = "活动标题"
                $0.hidden = "$isCoordinator == false"
            }
            <<< TextFloatLabelRow("Org") {
                $0.title = "举办组织"
            }
            <<< URLFloatLabelRow("URL") {
                $0.title = "活动推文链接介绍网址"
            
            }

            
            <<< DecimalRow("Price"){
                $0.useFormatterDuringInput = true
                $0.title = "价格"
                $0.value = 0
                let formatter = CurrencyFormatter()
                formatter.locale = .currentLocale()
                formatter.numberStyle = .CurrencyStyle
                $0.formatter = formatter
                $0.hidden = "$isCoordinator == false"
            }
            
            <<< SwitchRow("isRecurring") {
                $0.title = "是周期性的活动吗？"
                $0.value = false
                }.onChange { [weak self] in
                    if $0.value == true {
                        self?.form.rowByTag("DateRow")?.updateCell()
                        self?.form.rowByTag("Frequency")?.updateCell()
                    }
                    else {
                        self?.form.rowByTag("DateRow")?.updateCell()
                        self?.form.rowByTag("Frequency")?.updateCell()
                    }
            }
            
            <<< DateInlineRow("Date") {
                $0.title = "活动日期"
                $0.value = NSDate()
                $0.hidden = "$isRecurring == true"
            }
            <<< TextFloatLabelRow("Frequency") {
                $0.title = "活动频率, 如: 每周六， 每月五号"
                $0.hidden = "$isRecurring == false"
            }

        
            <<< ImageRow("CoverImg"){
                $0.title = "封面图片"
                $0.hidden = "$isCoordinator == false"
            }
            <<< TextAreaRow("Description") {
                $0.placeholder = "活动简介"
            }
            <<< TextFloatLabelRow("ItemName") {
                $0.title = "商品名。如: 舞会入场券"
                $0.hidden = "$isCoordinator == false"
        }

        
        fetchCloudData()


        
        
    }
    
    
    func popCurrentVC() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func checkInformationIntegrity() -> Bool {
        let attr = form.values(includeHidden: false)
        if attr["isCoordinator"]! as! Bool == true{
            if attr["Title"]! == nil || attr["Org"]! == nil || attr["URL"]! == nil || attr["Description"]! == nil || attr["CoverImg"]! == nil || attr["ItemName"]! == nil {
            
            return false
            
            }
            
            if attr["isRecurring"]! as! Bool == true {
                if attr["Frequency"]! == nil {
                    return false
                }
            }
            
            if attr["requireRemarks"]! as! Bool == true{
                if attr["AdditionalPrompt"]! == nil {
                    return false
                }
            }
         
        }else{
            if attr["Org"]! == nil || attr["URL"]! == nil || attr["Contact"]! == nil || attr["ContactName"]! == nil {
                return false
            }
            if attr["isRecurring"]! as! Bool == true {
                if attr["Frequency"]! == nil {
                    return false
                }
            }

            
        }
        
        return true
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


    
    func submitActivity() {

        if checkInformationIntegrity() {
            let attr = form.values(includeHidden: false)
            if attr["isCoordinator"]! as! Bool == true {
                print(attr)
                var selectedCates: [String] = []
                var selectedCities: [String] = []
                let newActivity = BmobObject(className: "Activity")
                newActivity.setObject(false, forKey: "isVisibleToUsers")
                for option in cates {
                    if attr[option.objectForKey("DisplayName") as! String]! != nil{
                        selectedCates.append(option.objectForKey("Name") as! String)
                    }
                }
                if attr["OtherCate"]! != nil {
                    selectedCates.append(attr["OtherCate"] as! String)
                }
                for option in cities {
                    if attr[option]! != nil{
                        selectedCities.append(option)
                    }
                }
                    newActivity.setObject(BmobUser.getCurrentUser().objectId, forKey: "Submitter")
                    newActivity.setObject(attr["ItemName"]! as! String, forKey: "ItemName")
                    newActivity.setObject("主办方提交:" + (attr["Title"]! as! String), forKey: "Title")
                    newActivity.setObject(attr["Org"] as! String, forKey: "Org")
                    newActivity.setObject(String(attr["URL"]! as! NSURL), forKey: "URL")
                    newActivity.setObject(attr["Price"]! as! Double, forKey: "Price")
                    newActivity.setObject(attr["Description"]! as! String, forKey: "Description")
                    newActivity.setObject(BmobUser.getCurrentUser().mobilePhoneNumber, forKey: "Contact")
                    newActivity.setObject(BmobUser.getCurrentUser().objectForKey("LegalName") as! String, forKey: "ContactName")
                    newActivity.setObject(0, forKey: "LikesNumber")
                    newActivity.setObject(0, forKey: "PageView")
                if attr["isRecurring"]! as! Bool == false {
                    if let date = attr["Date"]! as? NSDate {
                        let components = NSCalendar.currentCalendar().components([.Day, .Month, .Year], fromDate: date)
                        let monthNumber = components.month
                        let year = components.year
                        let day = components.day
                        let formatter = NSDateFormatter()
                        let monthName = formatter.monthSymbols[monthNumber-1]
                        let dateString = monthName + " " + String(day) + " " + String(year)
                        newActivity.setObject(dateString, forKey: "Date")
                        
                    }else{
                        let dateString = attr["Frequency"]! as! String
                        newActivity.setObject(dateString, forKey: "Date")
                    }
                }
                if attr["UserRemarks"]! != nil {
                    newActivity.setObject(attr["UserRemarks"]! as! String, forKey: "UserRemarks")
                }
                if attr["requireRemarks"]! as! Bool == true {
                    newActivity.setObject(true, forKey: "isRequireRemarks")
                    newActivity.setObject(attr["AdditionalPrompt"]! as! String, forKey: "AdditionalPrompt")
                }else{
                    newActivity.setObject(false, forKey: "isRequireRemarks")
                }
                selectedCities.insert("全国", atIndex: 0)
                newActivity.setObject(selectedCates, forKey: "Category")
                newActivity.setObject(selectedCities, forKey: "Cities")
                if attr["CoverImg"]! != nil {
                    let imageData = UIImageJPEGRepresentation(attr["CoverImg"]! as! UIImage, 0.5)
                    let newImage = BmobFile(fileName: "CoverImg.jpg", withFileData: imageData!)
                    newImage.saveInBackground { (isSuccessful, error) -> Void in
                        if isSuccessful {
                            newActivity.setObject(newImage, forKey: "CoverImg")
                            newActivity.saveInBackgroundWithResultBlock({ (isSuccessful, error) -> Void in
                                if error == nil {
                                    sharedOneSignalInstance.sendTag(attr["Title"] as! String, value: "ActivitySubmitted")
                                    let alert = UIAlertController(title: "Remix提示", message: "活动添加成功。谢谢你对Remix的支持_(:з」∠)_。审核通过后我们将给你发送推送消息。", preferredStyle: .Alert)
                                    let action = UIAlertAction(title: "好的", style: .Default, handler: { (action) -> Void in
                                        self.popCurrentVC()
                                    })
                                    alert.addAction(action)
                                    self.presentViewController(alert, animated: true, completion: nil)

                                }
                            })
                        }
                    }
                }
                
                
            }else{

                var selectedCates: [String] = []
                var selectedCities: [String] = []
                let newActivity = BmobObject(className: "Activity")
                newActivity.setObject(false, forKey: "isVisibleToUsers")
                for option in cates {
                    if attr[option.objectForKey("DisplayName") as! String]! != nil{
                        selectedCates.append(option.objectForKey("Name") as! String)
                    }
                }
                if attr["OtherCate"]! != nil {
                    selectedCates.append(attr["OtherCate"] as! String)
                }
                for option in cities {
                    if attr[option]! != nil{
                        selectedCities.append(option)
                    }
                }
                newActivity.setObject(BmobUser.getCurrentUser().objectId, forKey: "Submitter")
                newActivity.setObject("用户提交", forKey: "Title")
                selectedCities.insert("全国", atIndex: 0)
                newActivity.setObject(selectedCates, forKey: "Category")
                newActivity.setObject(selectedCities, forKey: "Cities")
                newActivity.setObject(attr["Org"] as! String, forKey: "Org")
                newActivity.setObject(String(attr["URL"]! as! NSURL), forKey: "URL")
                newActivity.setObject(0, forKey: "LikesNumber")
                newActivity.setObject(0, forKey: "PageView")
                newActivity.setObject(attr["Contact"]! as! String, forKey: "Contact")
                newActivity.setObject(attr["ContactName"]! as! String, forKey: "ContactName")
                if attr["isRecurring"]! as! Bool == false {
                    if let date = attr["Date"]! as? NSDate {
                        let components = NSCalendar.currentCalendar().components([.Day, .Month, .Year], fromDate: date)
                        let monthNumber = components.month
                        let year = components.year
                        let day = components.day
                        let formatter = NSDateFormatter()
                        let monthName = formatter.monthSymbols[monthNumber-1]
                        let dateString = monthName + " " + String(day) + " " + String(year)
                        newActivity.setObject(dateString, forKey: "Date")
                        
                    }else{
                        let dateString = attr["Frequency"]! as! String
                        newActivity.setObject(dateString, forKey: "Date")
                    }
                }
                if attr["Description"]! != nil {
                    newActivity.setObject(attr["Description"]! as! String, forKey: "Description")
                }
                if attr["UserRemarks"]! != nil {
                    newActivity.setObject(attr["UserRemarks"]! as! String, forKey: "UserRemarks")
                }
                
                newActivity.setObject(selectedCates, forKey: "Category")
                newActivity.setObject(selectedCities, forKey: "Cities")
                newActivity.saveInBackgroundWithResultBlock({ (isSuccessful, error) -> Void in
                    if error == nil {
                        sharedOneSignalInstance.sendTag(attr["Title"] as! String, value: "ActivitySubmitted")
                        let alert = UIAlertController(title: "Remix提示", message: "活动添加成功。谢谢你对Remix的支持_(:з」∠)_。审核通过后我们将给你发送推送消息。", preferredStyle: .Alert)
                        let action = UIAlertAction(title: "好的", style: .Default, handler: { (action) -> Void in
                            self.popCurrentVC()
                        })
                        alert.addAction(action)
                        self.presentViewController(alert, animated: true, completion: nil)
                        
                    }
                })
                
            }
        }else{
            let snackBar = TTGSnackbar.init(message: "活动提交失败，请检查信息是否已填写完整。", duration: .Middle)
            snackBar.backgroundColor = FlatWatermelonDark()
            snackBar.alpha = 0.9
            snackBar.show()
        }
    }



    func setUpParallaxHeaderView() {
            let manager = SDWebImageManager()
            let query = BmobQuery(className: "UIRemoteConfig")
            query.getObjectInBackgroundWithId("Cd3f1112") { (remix, error) -> Void in
                let url = NSURL(string: (remix.objectForKey("ActivitySubm_Image") as! BmobFile).url)
                manager.downloadImageWithURL(url, options: .RetryFailed, progress: nil) { (image, error, type, bool, url) -> Void in
                    let headerView = ParallaxHeaderView.parallaxHeaderViewWithImage(image, forSize: CGSizeMake(UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.width/2)) as! ParallaxHeaderView
                    self.tableView!.tableHeaderView = headerView
                }

            }
        
       
    }
    func fetchCloudData() {
        let query = BmobQuery(className: "Category")
        query.whereKey("isVisibleToUsers", equalTo: true)
        query.findObjectsInBackgroundWithBlock { (cates, error) -> Void in
            if error == nil {
                for cate in cates {
                    self.cates.append(cate as! BmobObject)
                }
                
                self.form +++ SelectableSection<ImageCheckRow<String>, String>("活动分类（可多选）", selectionType: .MultipleSelection)
                for option in self.cates {
                    self.form.last! <<< ImageCheckRow<String>(option.objectForKey("DisplayName") as! String){ lrow in
                        lrow.title = "   " + (option.objectForKey("DisplayName") as! String)
                        lrow.tag = option.objectForKey("DisplayName") as! String
                        lrow.selectableValue = option.objectForKey("Name") as! String
                        lrow.value = nil
                        }.cellSetup { cell, _ in
                            cell.trueImage = UIImage(named: "selectedRectangle")!
                            cell.falseImage = UIImage(named: "unselectedRectangle")!
                    }
                }
             self.form[2] <<< TextFloatLabelRow("OtherCate") {
                    $0.title = "其他类别"
                    
                }
            let query = BmobQuery(className: "SupportedCities")
                query.whereKey("isVisibleToUsers", equalTo: true)
                query.findObjectsInBackgroundWithBlock({ (cities, error) -> Void in
                    if error == nil {
                        for city in cities {
                            self.cities.append(city.objectForKey("CityName") as! String)
                        }
                        self.form +++ SelectableSection<ImageCheckRow<String>, String>("活动举行城市（可多选）", selectionType: .MultipleSelection)
                        for option in self.cities {
                            self.form.last! <<< ImageCheckRow<String>(option){ lrow in
                                lrow.title = "   " + option
                                lrow.tag = option
                                lrow.selectableValue = option
                                lrow.value = nil
                                }.cellSetup { cell, _ in
                                    cell.trueImage = UIImage(named: "selectedRectangle")!
                                    cell.falseImage = UIImage(named: "unselectedRectangle")!
                            }
                        }
                        
                        
                        self.form +++=
                            Section(header: "附加信息", footer: "报名表默认包含的信息包括参与者姓名, 学校或单位，联系电话，邮箱地址，微信（如果有）", { (section) -> () in
                                section.hidden = "$isCoordinator == false"
                            })
                            <<< SwitchRow("requireRemarks") {
                                $0.title = "报名表需要附加信息吗？"
                                $0.value = false
                                }.onChange { [weak self] in
                                    if $0.value == true {
                                        self?.form.rowByTag("AdditionalPrompt")?.updateCell()
                                        
                                    }
                                    else {
                                        self?.form.rowByTag("AdditionalPrompt")?.updateCell()
                                        
                                    }
                            }
                            <<< TextFloatLabelRow("AdditionalPrompt") {
                                $0.title = "附加报名问题。如: 你希望加入哪个组别？"
                                $0.hidden = "$requireRemarks == false"
                        }
                        
                        
                        self.form +++= Section("活动组织者联系方式", { (section) -> () in
                            section.hidden = "$isCoordinator == true"
                        })
                            <<< NameRow("ContactName") {
                                $0.title = "姓名"
                                $0.placeholder = "姓名"
                               
                            }
                            <<< PhoneRow("Contact") {
                                $0.title = "手机号"
                                $0.placeholder = "手机号"
                                
                        }
                        
                        
                        self.form +++= Section("备注")
                            <<< TextAreaRow("UserRemarks") {
                                $0.placeholder = "活动备注及其他希望告知Remix的注意事宜"
                        }


                        
                    }
                })
                
                           }
        }

    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
