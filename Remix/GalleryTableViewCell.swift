//
//  GalleryTableViewCell.swift
//  Remix
//
//  Created by fong tinyik on 2/7/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit
import MWPhotoBrowser

class GalleryTableViewCell: UITableViewCell, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource, MWPhotoBrowserDelegate {

    var photoURLs: [NSURL] = []
    var photos = [MWPhoto]()
    
    weak var parentViewController: GalleryViewController!
    
    @IBOutlet weak var galleryView: UICollectionView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var orgLogo: UIImageView!
    @IBOutlet weak var desLabel: UILabel!
    
    @IBOutlet weak var orgLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        galleryView.delegate = self
        galleryView.dataSource = self
        galleryView.scrollEnabled = false
        orgLogo.contentMode = .ScaleAspectFill
        orgLogo.clipsToBounds = true
        orgLogo.layer.cornerRadius = orgLabel.frame.height/2
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        if photoURLs.count == 9 {
        return CGSizeMake((collectionView.frame.size.width-3*2)/3, (collectionView.frame.size.width-3*2)/3)
        }
        
        if photoURLs.count == 4 {
            return CGSizeMake((collectionView.frame.size.width-3)/2, (collectionView.frame.size.width-3)/2)
        }
        
        if photoURLs.count == 1 {
            return CGSizeMake(collectionView.frame.size.width, collectionView.frame.size.width)
        }
        
        return CGSizeMake((collectionView.frame.size.width-3)/2, collectionView.frame.size.width/2)
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 3
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return photoURLs.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = galleryView.dequeueReusableCellWithReuseIdentifier("galleryCVCReuseIdentifier", forIndexPath: indexPath) as! GalleryCell
        cell.photoView.sd_setImageWithURL(photoURLs[indexPath.row], placeholderImage: UIImage(named: "SDPlaceholder"))
         
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        for photoURL in photoURLs {
            photos.append(MWPhoto(URL: photoURL)!)
        }
        let browser = MWPhotoBrowser(delegate: self)
        browser.setCurrentPhotoIndex(UInt(indexPath.row))
        self.parentViewController.navigationController?.pushViewController(browser, animated: true)
    }
    
    func numberOfPhotosInPhotoBrowser(photoBrowser: MWPhotoBrowser!) -> UInt {
        return UInt(photoURLs.count)
    }
    
    func photoBrowser(photoBrowser: MWPhotoBrowser!, photoAtIndex index: UInt) -> MWPhotoProtocol! {
        if Int(index) < photoURLs.count {
            return photos[Int(index)]
        }
        
        return nil
    }


}
