//
//  NotifInputViewController.swift
//  Remix
//
//  Created by fong tinyik on 3/8/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit

class NotifInputViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var notifInputView: UITextView!
    @IBOutlet weak var urlInputView: UITextView!
    var objectId: String!
    override func viewDidLoad() {
        super.viewDidLoad()
        notifInputView.placeholder = "请输入要群发的消息"
        urlInputView.placeholder = "用户点击推送消息时进入的网址。(可选)"
        // Do any additional setup after loading the view.
    }

    
    @IBAction func submitNotifRequest(sender: AnyObject) {
        let newRequest = AVObject(className: "NotificationRequest")
        newRequest.setObject(objectId, forKey: "ActivityObjectId")
        newRequest.setObject(AVObject(withoutDataWithObjectId: CURRENT_USER.objectId), forKey: "Submitter")
        newRequest.setObject(notifInputView.text, forKey: "Message")
        if urlInputView.text != nil {
            newRequest.setObject(urlInputView.text, forKey: "TargetURL")
        }
        newRequest.saveInBackgroundWithBlock { (isSuccessful, error) -> Void in
            if error == nil {
                let alert = UIAlertController(title: "申请已提交", message: "我们将在30分钟内为你送出该条推送消息。", preferredStyle: .Alert)
                 let action = UIAlertAction(title: "好的", style: .Default, handler: { (action) -> Void in
                    self.navigationController?.popViewControllerAnimated(true)
                 })
                
                alert.addAction(action)
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }

}
