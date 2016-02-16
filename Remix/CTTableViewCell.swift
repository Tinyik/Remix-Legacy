//
//  CTTableViewCell.swift
//  Remix
//
//  Created by fong tinyik on 2/5/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit

class CTTableViewCell: UITableViewCell {

    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var imageMask: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Using IB instead
//        let layerView = UIView(frame: CGRectMake(0, 0, coverImageView.frame.size.width, coverImageView.frame.size.height))
//        layerView.backgroundColor = .blackColor()
//        layerView.alpha = 0.3
//        coverImageView.addSubview(layerView)
        
        coverImageView.clipsToBounds = true
        coverImageView.contentMode = .ScaleAspectFill
        coverImageView.layer.cornerRadius = 8
        imageMask.layer.cornerRadius = 8
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
