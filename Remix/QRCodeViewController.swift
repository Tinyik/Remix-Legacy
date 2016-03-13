//
//  QRCodeViewController.swift
//  Remix
//
//  Created by fong tinyik on 3/11/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit
import QRCoder

class QRCodeViewController: UIViewController {

    @IBOutlet weak var backgroundView: UIImageView!
    @IBOutlet weak var codeView: UIImageView!
    
    var activityObjectId: String!
    var backgroundURL: NSURL!
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundView.sd_setImageWithURL(backgroundURL)
        self.title = "请参与者扫描二维码来进行签到"
        codeView.layer.shadowColor = UIColor.blackColor().CGColor
        codeView.layer.shadowOpacity = 0.3
        codeView.layer.shadowOffset = CGSizeMake(0, 0)
        codeView.layer.shadowRadius = 3
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "关闭", style: .Plain, target: self, action: "popCurrentVC")
        self.navigationItem.leftBarButtonItem?.tintColor = .blackColor()
        codeView.image = QRCodeGenerator().createImage(sharedOneSignalInstance.app_id + activityObjectId, size: CGSizeMake(325, 325))
        
    }
    
    func popCurrentVC() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    

}
