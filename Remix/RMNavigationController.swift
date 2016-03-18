//
//  RMNavigationController.swift
//  Remix
//
//  Created by fong tinyik on 3/19/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit

class RMNavigationController: UINavigationController {

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        LCUserFeedbackAgent.sharedInstance().countUnreadFeedbackThreadsWithBlock { (number, error) -> Void in
            if error == nil {
                if number != 0 {
                    let agent = LCUserFeedbackAgent()
                    agent.showConversations(self, title: nil, contact: nil)
                }
            }
        }
        
        self.becomeFirstResponder()
    }
    override func viewDidDisappear(animated: Bool) {
        self.resignFirstResponder()
        super.viewDidDisappear(animated)
    }
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        print("zaza")
        if motion == UIEventSubtype.MotionShake {
            let agent = LCUserFeedbackAgent()
            agent.showConversations(self, title: nil, contact: nil)
        }
    }

}
