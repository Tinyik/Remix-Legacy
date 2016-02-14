//
//  TrendingLabelCell.swift
//  Remix
//
//  Created by fong tinyik on 2/13/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit

class TrendingLabelCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    override func awakeFromNib() {
        let maskView = UIView(frame: imageView.bounds)
        maskView.backgroundColor = .blackColor()
        maskView.alpha = 0.4
        imageView.addSubview(maskView)
        imageView.contentMode = .ScaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        
    }
}
