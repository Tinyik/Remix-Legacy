//
//  RMTableViewCell.swift
//  Remix
//
//  Created by fong tinyik on 2/5/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit


class RMTableViewCell: MGSwipeTableCell {

    @IBOutlet weak var themeImg: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var priceTag: UILabel!
    @IBOutlet weak var likesNumberLabel: UILabel!
    @IBOutlet weak var likeStatusIndicatorView: UIImageView!
    @IBOutlet weak var orgLogo: UIImageView!
    @IBOutlet weak var desLabel: UILabel!
    
    @IBOutlet weak var payButton: UIButton!
    
    @IBOutlet weak var orgLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var parentViewController: UIViewController!
    var likeImage = UIImage(named: "Like")
    var objectId = ""
    var likeButtonTitle = ""
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

        themeImg.contentMode = UIViewContentMode.ScaleAspectFill
        themeImg.clipsToBounds = true
        orgLogo.layer.masksToBounds = true
        orgLogo.layer.cornerRadius = orgLogo.frame.size.height/2
           }
    

    
 
    
}
