//
//  NotifView.swift
//  Remix
//
//  Created by fong tinyik on 3/16/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit

class NotifView: UIView {

    @IBOutlet weak var label: UILabel!
    var parentvc: UIViewController!
   
    func promptUserCreditUpdate(number: String, withContext context: String, andAlert alert: UIAlertController) {
        label.text = context + "  +" + number
        self.alpha = 0
        UIApplication.sharedApplication().keyWindow?.addSubview(self)
        self.layer.cornerRadius = 5
        self.frame.origin = CGPointMake((DEVICE_SCREEN_WIDTH - self.frame.size.width)/2, (DEVICE_SCREEN_HEIGHT - self.frame.size.height)/2)
        UIView.animateWithDuration(1, animations: { () -> Void in
                self.alpha = 1
            }, completion: nil)
        UIView.animateWithDuration(1, delay: 1.5, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            self.alpha = 0
            }) { (completed) -> Void in
                if completed {
                    self.removeFromSuperview()
                    self.parentvc.presentViewController(alert, animated: true, completion: nil)
                }
        }
    }

}
