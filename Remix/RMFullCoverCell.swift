//
//  RMFullCoverCell.swift
//  Remix
//
//  Created by fong tinyik on 2/7/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit

class RMFullCoverCell: MGSwipeTableCell {
   
    
    @IBOutlet weak var payButton: UIButton!
    
    @IBOutlet weak var priceTag: UILabel!
    
    
    @IBOutlet weak var fullImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var likesNumberLabel: UILabel!
    @IBOutlet weak var likeStatusIndicatorView: UIImageView!
    @IBOutlet weak var orgLogo: UIImageView!
    
    
    @IBOutlet weak var orgLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    var parentViewController: RMTableViewController!
    var likeButtonTitle = ""
    var likeImage = UIImage(named: "Like")
    var objectId = ""
    var isLiked: Bool = false {
        didSet {
            if isLiked == true {
                likeButtonTitle = "💔"
                likeStatusIndicatorView.image = UIImage(named: "Like")
            }else{
                likeButtonTitle = "❤️"
                likeStatusIndicatorView.image = UIImage(named: "Unlike")
            }
        }
    }

    
    override func awakeFromNib() {
        fullImageView.contentMode = .ScaleAspectFill
        fullImageView.clipsToBounds = true
        
        // Using IB instead
//        var maskView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
//        maskView.backgroundColor = .blackColor()
//        maskView.alpha = 0.5
//        fullImageView.addSubview(maskView)
        
        orgLogo.layer.masksToBounds = true
        orgLogo.layer.cornerRadius = orgLogo.frame.size.height/2
    }
    
    @IBAction func payForActivity(sender: UIButton) {
        parentViewController.registerForActivity(self)
    }

}
