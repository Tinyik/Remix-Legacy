//
//  WithdrawInputViewController.swift
//  Remix
//
//  Created by fong tinyik on 3/9/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit

class WithdrawInputViewController: UIViewController {

    @IBOutlet weak var inputField: UITextField!
    var activityObjectId: String!
    var amount: Double!
    var hasRequestedWithdrawal: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "输入提现账户"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "提交", style: .Plain, target: self, action: "submitWithdralRequest")
        // Do any additional setup after loading the view.
    }
    
    func submitWithdralRequest() {
        if hasRequestedWithdrawal == false {
            let alert = UIAlertController(title: "Remix提示", message: "你是否确认提款至支付宝账户: " + inputField.text! + "?", preferredStyle: .Alert)
            let action = UIAlertAction(title: "好的", style: .Default, handler: { (action) -> Void in
                let newRequest = AVObject(className: "WithdrawalRequest")
                newRequest.setObject(false, forKey: "isResponded")
                newRequest.setObject(self.inputField.text, forKey: "TargetAccount")
                newRequest.setObject(self.amount, forKey: "Amount")
                newRequest.setObject(AVObject(withoutDataWithObjectId: CURRENT_USER.objectId), forKey: "Submitter")
                newRequest.setObject(self.activityObjectId, forKey: "ActivityObjectId")
                newRequest.setObject(CURRENT_USER.mobilePhoneNumber, forKey: "Contact")
                newRequest.saveInBackgroundWithBlock { (isSuccessful, error) -> Void in
                    if error == nil {
                    
                        let query = AVQuery(className: "Activity")
                        query.getObjectInBackgroundWithId(self.activityObjectId, block: { (activity, error) -> Void in
                            if error == nil {
                           
                                activity.setObject(true, forKey: "hasRequestedWithdrawal")
                                activity.saveInBackgroundWithBlock({ (isSuccessful, error) -> Void in
                                    if error == nil {
                                   
                                        let alert = UIAlertController(title: "Remix提示", message: "提现申请已提交。我们将尽快受理你的申请。", preferredStyle: .Alert)
                                        let action = UIAlertAction(title: "好的", style: .Default, handler: { (action) -> Void in
                                            self.navigationController?.popViewControllerAnimated(true)
                                        })
                                        alert.addAction(action)
                                        self.presentViewController(alert, animated: true, completion: nil)
                                    }
                                })
                                
                            }
                        })
                    }
                }
                
            })
            let cancel = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
            alert.addAction(cancel)
            alert.addAction(action)
            self.presentViewController(alert, animated: true, completion: nil)

        }else{
            let alert = UIAlertController(title: "Remix提示", message: "你是否确认更改提款账户为: " + inputField.text! + "?", preferredStyle: .Alert)
            let action = UIAlertAction(title: "好的", style: .Default, handler: { (action) -> Void in
                let query = AVQuery(className: "WithdrawalRequest")
                query.whereKey("ActivityObjectId", equalTo: self.activityObjectId)
                query.findObjectsInBackgroundWithBlock({ (requests, error) -> Void in
                    if error == nil {
                        if requests.count == 1 {
                            if (requests[0] as! AVObject).objectForKey("isResponded") as! Bool == false{
                                (requests[0] as! AVObject).setObject(self.inputField.text, forKey: "TargetAccount")
                                (requests[0] as! AVObject).saveInBackgroundWithBlock({ (isSuccessfor, error) -> Void in
                                    if error == nil {
                              
                                        let alert = UIAlertController(title: "Remix提示", message: "提现申请修改成功。我们将尽快受理你的申请。", preferredStyle: .Alert)
                                        let action = UIAlertAction(title: "好的", style: .Default, handler: { (action) -> Void in
                                            self.navigationController?.popViewControllerAnimated(true)
                                        })
                                        alert.addAction(action)
                                        self.presentViewController(alert, animated: true, completion: nil)
                                        
                                    }
                                })

                            }else{
                                let alert = UIAlertController(title: "Remix提示", message: "很抱歉。此提现申请已被受理，无法进行更改。请联系Remix客服寻求解决方案。", preferredStyle: .Alert)
                                let action = UIAlertAction(title: "好的", style: .Default, handler: nil)
                                alert.addAction(action)
                                self.presentViewController(alert, animated: true, completion: nil)
                            }
                        }
                    }
                })
            })
            let cancel = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
            alert.addAction(cancel)
            alert.addAction(action)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func backGroundTap(sender: UIControl) {
        inputField.resignFirstResponder()
        
    }
    
    @IBAction func contactRemixService() {
        UIApplication.sharedApplication().openURL(NSURL(string: "tel://18149770476")!)
    }
}
