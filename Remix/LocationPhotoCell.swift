//
//  LocationPhotoCell.swift
//  Remix
//
//  Created by fong tinyik on 2/13/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit

class LocationPhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var photoView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        photoView.needsBetterFace = true
        photoView.contentMode = .ScaleAspectFill
        photoView.clipsToBounds = true
        
        
    }
    
}
