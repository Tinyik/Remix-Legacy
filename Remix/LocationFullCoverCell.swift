//
//  LocationFullCoverCell.swift
//  Remix
//
//  Created by fong tinyik on 2/13/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit

class LocationFullCoverCell: UITableViewCell {
    

    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var orgLabel: UILabel!
    
    @IBOutlet weak var coverImgView: UIImageView!
    
    @IBOutlet weak var desLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        coverImgView.contentMode = .ScaleAspectFill
        coverImgView.clipsToBounds = true
        
        // Moved to IB
//        let maskView = UIView(frame: coverImgView.frame)
//        maskView.backgroundColor = .blackColor()
//        maskView.alpha = 0.3
//        coverImgView.addSubview(maskView)
    }

 

}
