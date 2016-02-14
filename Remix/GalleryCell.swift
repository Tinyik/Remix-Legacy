//
//  GalleryCell.swift
//  Remix
//
//  Created by fong tinyik on 2/7/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit

class GalleryCell: UICollectionViewCell {
    
    @IBOutlet weak var photoView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        photoView.needsBetterFace = true
        photoView.contentMode = .ScaleAspectFill
        photoView.clipsToBounds = true
        
        
    }
}
