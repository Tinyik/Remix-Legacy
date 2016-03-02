//
//  OrgCell.swift
//  Remix
//
//  Created by fong tinyik on 2/5/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit

class OrgCell: UICollectionViewCell {

    @IBOutlet weak var logoImageView: UIImageView!
    
    @IBOutlet weak var orgNameLabel: UILabel!
    
    @IBOutlet weak var containerView: UIView!
    
    override func awakeFromNib() {

        logoImageView.contentMode = .ScaleAspectFill
        logoImageView.clipsToBounds = true
        containerView.backgroundColor = .clearColor()
        let path = UIBezierPath(rect: containerView.bounds).CGPath
        containerView.layer.shadowPath = path
        containerView.layer.shouldRasterize = true
        containerView.layer.rasterizationScale = UIScreen.mainScreen().scale
        containerView.layer.shadowColor = UIColor.blackColor().CGColor
        containerView.layer.shadowOffset = CGSizeMake(0, 0)
        containerView.layer.shadowOpacity = 0.1

    }
}
