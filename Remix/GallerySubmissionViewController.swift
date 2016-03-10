//
//  GallerySubmissionViewController.swift
//  Remix
//
//  Created by fong tinyik on 3/9/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit
import Eureka
import SDWebImage
import TTGSnackbar

class GallerySubmissionViewController: FormViewController {

    var cities: [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpParallaxHeaderView()
        SwitchRow.defaultCellSetup = { cell, row in cell.switchControl!.onTintColor = FlatRed() }
        TextFloatLabelRow.defaultCellSetup = { cell, row in cell.textField.textColor = FlatRed() }
        URLFloatLabelRow.defaultCellSetup = { cell, row in cell.textField.textColor = FlatRed() }
        TextAreaRow.defaultCellSetup = { cell, row in cell.textView.alpha = 0.7 }
        self.navigationController?.hidesNavigationBarHairline = true
        self.title = "提交活动报道"
        self.navigationController?.navigationBar.barTintColor = FlatBlueDark()
        self.navigationController?.navigationBar.tintColor = .whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "提交", style: .Plain, target: self, action: "submitActivity")
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "关闭", style: .Plain, target: self, action: "popCurrentVC")
            self.navigationController?.navigationBar.translucent = false
        
        form +++
        Section("提交成功后活动报道将在Remix\"往期活动\"栏目中显示。")
        +++
        Section("活动信息")
        
            <<< SwitchRow("isRemixActivity") {
                $0.title = "这个活动在Remix上开放报名过吗？"
                $0.value = false
            }
            <<< SwitchRow("FakeRow") {
                $0.title = "提交后通知活动参与者"
                $0.value = true
                $0.hidden = "$isRemixActivity == false"
            }
        
            <<< TextFloatLabelRow("ParentActivityObjectId") {
                $0.title = "活动唯一标识码"
                $0.hidden = "$isRemixActivity == false"
            }
        
            <<< TextFloatLabelRow("Org") {
                $0.title = "举办组织"
                $0.hidden = "$isRemixActivity == true"
            }
        
            <<< DateInlineRow("Date") {
                $0.title = "活动日期"
                $0.value = NSDate()
                $0.hidden = "$isRemixActivity == true"
            }
        +++
        Section("活动报道")
            <<< TextFloatLabelRow("Title") {
                $0.title = "标题"
                
            }
            
            <<< URLFloatLabelRow("URL") {
                $0.title = "报道推文链接或网址"
                
            }
            
            <<< TextAreaRow("Description") {
                $0.placeholder = "活动简介或报道副标题"
            }
            
        +++
        Section("活动照片。图片越多、越吸引人的活动获得的曝光率越高。")
            <<< ImageRow("Pic0"){
                $0.title = "活动照片1"
            }
            <<< SwitchRow("isIntendToAddPic") {
                $0.title = "我可以提交更多照片"
                $0.value = false
            }
            
        for var i = 1; i <= 8; ++i {
            self.form[3]  <<< ImageRow("Pic" + String(i)){
                $0.title = "活动图片" + String(i+1) + "       >>>"
                if i == 0 {
                    $0.title = "活动图片" + String(i+1) + " (必填)       >>>"
                }
                $0.hidden = "$isIntendToAddPic == false"
            }
        }


        fetchCloudData()
       
    }

    func popCurrentVC() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func setUpParallaxHeaderView() {
        let manager = SDWebImageManager()
        let query = BmobQuery(className: "UIRemoteConfig")
        query.getObjectInBackgroundWithId("Cd3f1112") { (remix, error) -> Void in
            if error == nil {
                let url = NSURL(string: (remix.objectForKey("GallerySubm_Image") as! BmobFile).url)
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
    
    func checkInformationIntegrity() -> Bool {
        let attr = form.values(includeHidden: false)
        if attr["isRemixActivity"]! as! Bool == true {
            if attr["ParentActivityObjectId"]! == nil || attr["Title"]! == nil || attr["URL"]! == nil || attr["Description"]! == nil || attr["Pic0"]! == nil {
                return false
            }
        }else{
            if attr["Org"]! == nil || attr["Date"]! == nil || attr["Title"]! == nil || attr["URL"]! == nil || attr["Description"]! == nil || attr["Pic0"]! == nil {
                return false
            }
        }
        
        return true
    }
    
    func submitActivity(){
        let attr = form.values(includeHidden: false)
        if checkInformationIntegrity() {
            var selectedCities: [String] = []
            let newGallery = BmobObject(className: "Gallery")
            newGallery.setObject(false, forKey: "isVisibleToUsers")
            for option in cities {
                if attr[option]! != nil{
                    selectedCities.append(option)
                }
            }
            selectedCities.insert("全国", atIndex: 0)
            newGallery.setObject(CURRENT_USER.objectId, forKey: "Submitter")
            newGallery.setObject(CURRENT_USER.mobilePhoneNumber, forKey: "SubmitterContact")
            newGallery.setObject(selectedCities, forKey: "Cities")
            newGallery.setObject(attr["isRemixActivity"]! as! Bool, forKey: "isRemixActivity")
            if attr["isRemixActivity"]! as! Bool == true{
                newGallery.setObject(attr["ParentActivityObjectId"]! as! String, forKey: "ParentActivityObjectId")
            }else{
                newGallery.setObject(attr["Org"]! as! String, forKey: "Org")
                if let date = attr["Date"]! as? NSDate {
                    let components = NSCalendar.currentCalendar().components([.Day, .Month, .Year], fromDate: date)
                    let monthNumber = components.month
                    let year = components.year
                    let day = components.day
                    let formatter = NSDateFormatter()
                    let monthName = formatter.monthSymbols[monthNumber-1]
                    let dateString = monthName + " " + String(day) + " " + String(year)
                    newGallery.setObject(dateString, forKey: "Date")
                }
                
            }
            newGallery.setObject(attr["Title"]! as! String, forKey: "Title")
            newGallery.setObject(attr["Description"]! as! String, forKey: "Description")
            newGallery.setObject(String(attr["URL"]! as! NSURL), forKey: "URL")
            if attr["UserRemarks"]! != nil {
                newGallery.setObject(attr["UserRemarks"]! as! String, forKey: "UserRemarks")
            }
            if attr["isIntendToAddPic"]! as! Bool == false{
                let imageData = UIImageJPEGRepresentation(attr["Pic0"]! as! UIImage, 0.5)
                let newImage = BmobFile(fileName: "Pic.jpg", withFileData: imageData!)
                newImage.saveInBackground { (isSuccessful, error) -> Void in
                    if isSuccessful {
                        newGallery.setObject(newImage, forKey: "Pic0")
                        newGallery.saveInBackgroundWithResultBlock({ (isSuccessful, error) -> Void in
                            if error == nil {
                                sharedOneSignalInstance.sendTag(attr["Title"] as! String, value: "GallerySubmitted")
                                let alert = UIAlertController(title: "Remix提示", message: "活动报道添加成功。谢谢你对Remix的支持_(:з」∠)_。审核通过后我们将给你发送推送消息。", preferredStyle: .Alert)
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
                        let snackBar = TTGSnackbar.init(message: "获取数据失败。请检查网络连接后重试。", duration: .Middle)
                        snackBar.backgroundColor = FlatWatermelonDark()
                        snackBar.show()
                    }
                }

            }else{
                for var i = 0; i <= 8; ++i {
                    if let image = attr["Pic" + String(i)]! as? UIImage {
                        let imageData = UIImageJPEGRepresentation(image, 0.5)
                        let imageFile = BmobFile(fileName: "Image.jpg", withFileData: imageData)
                        if imageFile.save() {
                            newGallery.setObject(imageFile, forKey: "Pic" + String(i))
                        }
                        
                    }
                }
                newGallery.saveInBackgroundWithResultBlock({ (isSuccessful, error) -> Void in
                    if error == nil {
                        sharedOneSignalInstance.sendTag(attr["Title"] as! String, value: "GallerySubmitted")
                        let alert = UIAlertController(title: "Remix提示", message: "活动报道添加成功。谢谢你对Remix的支持_(:з」∠)_。审核通过后我们将给你发送推送消息。", preferredStyle: .Alert)
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
            let snackBar = TTGSnackbar.init(message: "活动提交失败，请检查信息是否已填写完整。", duration: .Middle)
            snackBar.backgroundColor = FlatWatermelonDark()
            snackBar.alpha = 0.9
            snackBar.show()
        }

    }
    func fetchCloudData() {
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
                
            }
            self.form  +++
                Section("备注")
                <<< TextAreaRow("UserRemarks") {
                    $0.placeholder = "备注及其他希望告知Remix的注意事宜"
                }
        })
        
    }
    

    
   
}
