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

    @IBOutlet weak var codeView: UIImageView!
    
    var activityObjectId: String!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "关闭", style: .Plain, target: self, action: "popCurrentVC")
        self.navigationItem.leftBarButtonItem?.tintColor = .blackColor()
        codeView.image = QRCodeGenerator().createImage(sharedOneSignalInstance.app_id + activityObjectId, size: CGSizeMake(325, 325))
    }
    
    func popCurrentVC() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    

}
