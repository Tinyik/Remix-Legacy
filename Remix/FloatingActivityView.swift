//
//  FloatingActivityView.swift
//  Remix
//
//  Created by fong tinyik on 2/26/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit
import TTGSnackbar
extension UIView {
    class func loadFromNibNamed(nibNamed: String, bundle : NSBundle? = nil) -> UIView? {
        return UINib(
            nibName: nibNamed,
            bundle: bundle
            ).instantiateWithOwner(nil, options: nil)[0] as? UIView
    }
}

class FloatingActivityView: UIView, BmobPayDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceTag: UILabel!
    @IBOutlet weak var payButton: UIButton!
    
    var activity: AVObject!
    var registeredActivitiesIds: [String] = []
    var parentViewController: RMTableViewController!
    var ongoingTransactionId: String!
    var ongoingTransactionPrice: Double!
    var ongoingTransactionRemarks = "No comments."
    
    override func awakeFromNib() {
        imageView.contentMode = .ScaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 6
    }
    
    
    @IBAction func prepareForFloatingActivityRegistration() {
        
        if registeredActivitiesIds.contains(activity.objectId) {
            let alert = UIAlertController(title: "报名提示", message: "你已报名了这个活动，请进入我的订单查看。", preferredStyle: .Alert)
            let action = UIAlertAction(title: "立即查看", style: .Cancel, handler: { (action) -> Void in
                self.parentViewController.presentSettingsVC()
            })
            let cancel = UIAlertAction(title: "继续逛逛", style: .Default, handler: nil)
            alert.addAction(action)
            alert.addAction(cancel)
            self.parentViewController.presentViewController(alert, animated: true, completion: nil)
            
        }else{
            if let _isRegOpen = activity.objectForKey("isRegistrationOpen") as? Bool {
                if _isRegOpen == true {
                    if checkPersonalInfoIntegrity() {
                        
                        
                        if let _needInfo = activity.objectForKey("isRequireRemarks") as? Bool {
                            if _needInfo == true {
                                let prompt = activity.objectForKey("AdditionalPrompt") as? String
                                let alert = UIAlertController(title: "附加信息", message: "除了你的基本信息外，此活动需要以下附加的报名信息: \n" + prompt!, preferredStyle: .Alert)
                                let action = UIAlertAction(title: "继续报名", style: .Default, handler: { (action) -> Void in
                                    self.ongoingTransactionRemarks = alert.textFields![0].text!
                                    self.registerForActivity()
                                })
                                let cancel = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
                                alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
                                    textField.placeholder = "请输入附加报名信息"
                                    
                                })
                                alert.addAction(action)
                                alert.addAction(cancel)
                                self.parentViewController.presentViewController(alert, animated: true, completion: nil)
                                
                            }else{
                                registerForActivity()
                            }
                        }else{
                            registerForActivity()
                        }
                        
                        
                    }else{
                        let alert = UIAlertController(title: "完善信息", message: "请先进入账户设置完善个人信息后再继续报名参加活动。", preferredStyle: .Alert)
                        let action = UIAlertAction(title: "去设置", style: .Default, handler: { (action) -> Void in
                            self.parentViewController.presentSettingsVC()
                        })
                        let cancel = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
                        alert.addAction(action)
                        alert.addAction(cancel)
                        self.parentViewController.presentViewController(alert, animated: true, completion: nil)
                    }
                    
                }else{
                    let alert = UIAlertController(title: "提示", message: "这个活动太火爆啦！参与活动人数已满(Ｔ▽Ｔ)再看看别的活动吧~下次记得早早下手哦。", preferredStyle: .Alert)
                    let action = UIAlertAction(title: "好吧", style: .Default, handler: nil)
                    alert.addAction(action)
                    self.parentViewController.presentViewController(alert, animated: true, completion: nil)
                }
            }else{
                let alert = UIAlertController(title: "提示", message: "这个活动太火爆啦！参与活动人数已满(Ｔ▽Ｔ)再看看别的活动吧~下次记得早早下手哦。", preferredStyle: .Alert)
                let action = UIAlertAction(title: "好吧", style: .Default, handler: nil)
                alert.addAction(action)
                self.parentViewController.presentViewController(alert, animated: true, completion: nil)
            }
            
        }

    }
    
    func fetchOrdersInformation() {
        registeredActivitiesIds = []
        let query = AVQuery(className: "Orders")
        query.whereKey("CustomerObjectId", equalTo: AVUser(outDataWithObjectId: CURRENT_USER.objectId))
        query.findObjectsInBackgroundWithBlock { (orders, error) -> Void in
            if error == nil {
                for order in orders {
                    
                    if let o = order.objectForKey("ParentActivityObjectId") as? AVObject {
                        self.registeredActivitiesIds.append(o.objectId)
                    }
                }
            }else{
                let snackBar = TTGSnackbar.init(message: "获取数据失败。请检查网络连接后重试。", duration: .Middle)
                snackBar.backgroundColor = FlatWatermelonDark()
                snackBar.show()
            }
        }
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
    
    func registerForActivity() {
        
        
        
        let orgName = activity.objectForKey("Org") as? String
        
        if let price = activity.objectForKey("Price") as? Double {
            if price != 0 {
                ongoingTransactionId = activity.objectId
                ongoingTransactionPrice = price
                
                let alert = UIAlertController(title: "Remix报名确认", message: "确定要报名参加这个活动吗？(●'◡'●)ﾉ♥", preferredStyle: .Alert)
                let action = UIAlertAction(title: "确认", style: .Default, handler: { (action) -> Void in
                    let bPay = BmobPay()
                    bPay.delegate = self
                    bPay.price = NSNumber(double: price)
                    bPay.productName = orgName! + "活动报名费"
                    bPay.body = (self.activity.objectForKey("ItemName") as! String) + "用户姓名" + (CURRENT_USER.objectForKey("LegalName") as! String)
                    bPay.appScheme = "BmobPay"
                    bPay.payInBackgroundWithBlock({ (isSuccessful, error) -> Void in
                        if isSuccessful == false {
                            let alert = UIAlertController(title: "支付状态", message: "支付失败！请检查网络连接。", preferredStyle: .Alert)
                            let action = UIAlertAction(title: "好的", style: .Default, handler: nil)
                            alert.addAction(action)
                            self.parentViewController.presentViewController(alert, animated: true, completion: nil)
                        }
                    })
                })
                let cancel = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
                alert.addAction(action)
                alert.addAction(cancel)
                self.parentViewController.presentViewController(alert, animated: true, completion: nil)
                
                
            }else{
                ongoingTransactionId = activity.objectId
                ongoingTransactionPrice = 0
                let alert = UIAlertController(title: "Remix报名确认", message: "确定要报名参加这个活动吗？(●'◡'●)ﾉ♥", preferredStyle: .Alert)
                let action = UIAlertAction(title: "确认", style: .Default, handler: { (action) -> Void in
                    self.paySuccess()
                })
                let cancel = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
                alert.addAction(action)
                alert.addAction(cancel)
                self.parentViewController.presentViewController(alert, animated: true, completion: nil)
            }
            
            
        }else{
            ongoingTransactionId = activity.objectId
            ongoingTransactionPrice = 0
            let alert = UIAlertController(title: "Remix报名确认", message: "确定要报名参加这个活动吗？(●'◡'●)ﾉ♥", preferredStyle: .Alert)
            let action = UIAlertAction(title: "确认", style: .Default, handler: { (action) -> Void in
                self.paySuccess()
            })
            let cancel = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
            alert.addAction(action)
            alert.addAction(cancel)
            self.parentViewController.presentViewController(alert, animated: true, completion: nil)
        }
        
        
    }
    
    func paySuccess() {
        let newOrder = AVObject(className: "Orders")
        newOrder.setObject(AVObject(outDataWithClassName: "Activity", objectId: ongoingTransactionId), forKey: "ParentActivityObjectId")
        newOrder.setObject(ongoingTransactionPrice, forKey: "Amount")
        newOrder.setObject(false, forKey: "CheckIn")
        newOrder.setObject(AVUser(outDataWithObjectId: CURRENT_USER.objectId), forKey: "CustomerObjectId")
        newOrder.setObject(ongoingTransactionRemarks, forKey: "Remarks")
        newOrder.setObject(true, forKey: "isVisibleToUsers")
        newOrder.saveInBackgroundWithBlock { (isSuccessful, error) -> Void in
            if isSuccessful {
                sharedOneSignalInstance.sendTag(self.ongoingTransactionId, value: "PaySuccess")
                let c = CURRENT_USER.objectForKey("Credit") as! Int
                CURRENT_USER.setObject(c+(Int(self.activity.objectForKey("Duration") as! String)!)*2, forKey: "Credit")
                CURRENT_USER.saveInBackground()
                self.fetchOrdersInformation()
                let smsDict = ["Org": self.activity.objectForKey("Org") as! String, "Date": self.activity.objectForKey("Date") as! String, "Price": String(self.ongoingTransactionPrice), "Contact": self.activity.objectForKey("Contact") as! String]
                AVOSCloud.requestSmsCodeWithPhoneNumber(CURRENT_USER.mobilePhoneNumber, templateName: "Registration_Success", variables: smsDict, callback: nil)
                let alert = UIAlertController(title: "支付状态", message: "报名成功！Remix已经把你的基本信息发送给了活动主办方。请进入 \"我的订单\" 查看。", preferredStyle: .Alert)
                let cancel = UIAlertAction(title: "继续逛逛", style: .Default, handler: nil)
                let action = UIAlertAction(title: "立即查看", style: .Cancel) { (action) -> Void in
                    self.parentViewController.presentSettingsVC()
                }
                alert.addAction(action)
                alert.addAction(cancel)
                let notif = UIView.loadFromNibNamed("NotifView") as! NotifView
                notif.parentvc = self.parentViewController
                notif.promptUserCreditUpdate(String((Int(self.activity.objectForKey("Duration") as! String))!*2), withContext: "报名活动", andAlert: alert)
            }else {
                let alert = UIAlertController(title: "支付状态", message: "Something is wrong. 这是一个极小概率的错误。不过别担心，如果已经被扣款, 请联系Remix客服让我们为你解决。（181-4977-0476）", preferredStyle: .Alert)
                let cancel = UIAlertAction(title: "稍后在说", style: .Cancel, handler: nil)
                let action = UIAlertAction(title: "立即拨打", style: .Default) { (action) -> Void in
                    UIApplication.sharedApplication().openURL(NSURL(string: "tel://18149770476")!)
                }
                alert.addAction(action)
                alert.addAction(cancel)
                self.parentViewController.presentViewController(alert, animated: true, completion: nil)
            }
        }
        
    }
    
    func payFailWithErrorCode(errorCode: Int32) {
        
        let alert = UIAlertController(title: "支付状态", message: "支付失败。", preferredStyle: .Alert)
        let action = UIAlertAction(title: "好的", style: .Default, handler: nil)
        alert.addAction(action)
        self.parentViewController.presentViewController(alert, animated: true, completion: nil)
    }
    
    

    
}
