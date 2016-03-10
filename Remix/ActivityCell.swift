//
//  ActivityCell.swift
//  Remix
//
//  Created by fong tinyik on 3/8/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit


class ActivityCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var themeImg: UIImageView!
    @IBOutlet weak var statusIndicator: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceTag: UILabel!
    @IBOutlet weak var orgLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var orderNoLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    
    var objectId: String!
    var parentViewController: ManagementViewController!
    var activityStatus: String! {
        didSet {
            if activityStatus == "Visible" {
                actionButton.setTitle("下架活动", forState: .Normal)
                actionButton.addTarget(self, action: "expireActivity", forControlEvents: .TouchUpInside)
            }
            if activityStatus == "Invisible" {
                actionButton.setTitle("提交活动后期报道", forState: .Normal)
                actionButton.addTarget(self, action: "showGallerySubmission", forControlEvents: .TouchUpInside)
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        actionButton.layer.borderColor = UIColor(white: 0.8, alpha: 1).CGColor
        actionButton.layer.borderWidth = 1
        themeImg.contentMode = .ScaleAspectFill
        themeImg.clipsToBounds = true
        
        
    }

    func expireActivity() {
        let alert = UIAlertController(title: "Remix提示", message: "确定要下架这个活动吗？下架后他人将无法报名参加这个活动。这个活动将仍显示在\"我发起的活动\"历史纪录中。", preferredStyle: .Alert)
        let action = UIAlertAction(title: "确定", style: .Destructive) { (action) -> Void in
            let query = BmobQuery(className: "Activity")
            query.getObjectInBackgroundWithId(self.objectId, block: { (activity, error) -> Void in
                if error == nil {
                    activity.setObject(false, forKey: "isVisibleToUsers")
                    activity.setObject(false, forKey: "isRegistrationOpen")
                    activity.updateInBackgroundWithResultBlock({ (isSuccessful, error) -> Void in
                        if error == nil {
                            self.parentViewController.refresh()
                            let alert = UIAlertController(title: "Remix提示", message: "活动已下架。现在你可以申请提取活动报名费到账户。", preferredStyle: .Alert)
                            let action = UIAlertAction(title: "好的", style: .Default, handler: nil)
                            alert.addAction(action)
                            self.parentViewController.presentViewController(alert, animated: true, completion: nil)
                        }
                    })
                }
            })
        }
        let cancel = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
        alert.addAction(action)
        alert.addAction(cancel)
        self.parentViewController.presentViewController(alert, animated: true, completion: nil)
    }

    func showGallerySubmission() {
        let gallerySubm = GallerySubmissionViewController()
        let navi = UINavigationController(rootViewController: gallerySubm)
        self.parentViewController.presentViewController(navi, animated: true, completion: nil)
    }

}
