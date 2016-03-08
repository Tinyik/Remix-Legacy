//
//  ActivityHeader.swift
//  Remix
//
//  Created by fong tinyik on 3/8/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit
import SDWebImage

class ActivityHeaderView: UIView {
    @IBOutlet weak var blurredCoverView: UIImageView!
    @IBOutlet weak var ordersNumberLabel: UILabel!
    @IBOutlet weak var revenueLabel: UILabel!
    @IBOutlet weak var cashButton: UIButton!
    
    var activity: BmobObject!
    var coverImgURL: NSURL!
    
    
    
    
    override func awakeFromNib() {
        print("AWAKE")
        blurredCoverView.contentMode = .ScaleAspectFill
        blurredCoverView.clipsToBounds = true
        blurredCoverView.image = UIImage(named: "DefaultAvatar")
    }
    
    func fetchActivityInfo() {
        blurredCoverView.sd_setImageWithURL(coverImgURL, placeholderImage: UIImage(named: "SDPlaceholder"))
    }

}
