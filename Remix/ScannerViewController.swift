//
//  ScannerViewController.swift
//  Remix
//
//  Created by fong tinyik on 3/12/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit
import QRCoder

class ScannerViewController: QRCodeScannerViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "扫描主办方活动二维码签到"
        self.navigationItem.leftBarButtonItem?.tintColor = .blackColor()
        self.navigationController?.navigationBar.tintColor = .blackColor()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "关闭", style: .Plain, target: self, action: "popCurrentVC")
        
    }
    
    override func didFailWithError(error: NSError) {
        
    }
    
    func popCurrentVC() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func processQRCodeContent(qrCodeContent: String) -> Bool {
        let query = AVQuery(className: "Orders")
        query.whereKey("CustomerObjectId", equalTo: CURRENT_USER.objectId)
        query.whereKey("ParentActivityObjectId", equalTo: qrCodeContent.stringByReplacingOccurrencesOfString(sharedOneSignalInstance.app_id, withString: ""))
        query.findObjectsInBackgroundWithBlock { (orders, error) -> Void in
            if error == nil {
                if orders.count == 1 {
                    for order in orders {
                        if order.objectForKey("CheckIn") as! Bool == false {
                            (order as! AVObject).setObject(true, forKey: "CheckIn")
                            (order as! AVObject).saveInBackgroundWithBlock({ (isSuccessful, error) -> Void in
                                if error == nil {
                                    // Add Credits.
                                    let alert = UIAlertController(title: "签到提示", message: "活动签到成功(｀･ω･´)相应积分和奖励已更新至你的账户。", preferredStyle: .Alert)
                                    let action = UIAlertAction(title: "好的", style: .Default, handler: { (action) -> Void in
                                        self.dismissViewControllerAnimated(true, completion: nil)
                                    })
                                    alert.addAction(action)
                                    self.presentViewController(alert, animated: true, completion: nil)
                                }
                            })

                        }else{
                            let alert = UIAlertController(title: "签到提示", message: "这个活动你已经签到过啦(｀･ω･´)", preferredStyle: .Alert)
                            let action = UIAlertAction(title: "好的", style: .Default, handler: { (action) -> Void in
                                self.dismissViewControllerAnimated(true, completion: nil)
                            })
                            alert.addAction(action)
                            self.presentViewController(alert, animated: true, completion: nil)

                        }
                    }

                }else{
                    let alert = UIAlertController(title: "Remix提示", message: "你似乎未报名参加该活动...（￣工￣lll）要现在立即报名参加吗？", preferredStyle: .Alert)
                    let cancel = UIAlertAction(title: "不了", style: .Cancel, handler: nil)
                    let action = UIAlertAction(title: "好的", style: .Default, handler: { (action) -> Void in
                        self.dismissViewControllerAnimated(true, completion: nil)
                        UIApplication.sharedApplication().openURL(NSURL(string: "remix://" + qrCodeContent.stringByReplacingOccurrencesOfString(sharedOneSignalInstance.app_id, withString: ""))!)
                    })
                    alert.addAction(cancel)
                    alert.addAction(action)
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                
            }
        }
        return true
    }

}
