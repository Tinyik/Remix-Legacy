//
//  OrgIntroViewController.swift
//  Remix
//
//  Created by fong tinyik on 2/19/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit
import MWPhotoBrowser
import MessageUI

class OrgIntroViewController: UIViewController, UIGestureRecognizerDelegate, MWPhotoBrowserDelegate, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var firstTextView: UITextView!
    @IBOutlet weak var secondImageView: UIImageView!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var secondTextView: UITextView!
    
    var photos: [MWPhoto] = []
    var orgName = "Remix"
    var emailRecipient = ["fongtinyik@gmail.com"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        fetchGalleryURLs()
        let query = BmobQuery(className: "Organization")
        query.whereKey("Name", equalTo: orgName)
        query.findObjectsInBackgroundWithBlock { (organizations, error) -> Void in
            for organization in organizations {
                if let _recipient = organization.objectForKey("Emails") as? NSArray {
                self.emailRecipient = _recipient as! [String]
                }
                if let image1 = organization.objectForKey("IntroImage1") as? BmobFile {
                    let url = NSURL(string: image1.url)
                    self.mainImageView.sd_setImageWithURL(url)
                }
                if let image2 = organization.objectForKey("IntroImage2") as? BmobFile {
                    let url = NSURL(string: image2.url)
                    self.secondImageView.sd_setImageWithURL(url)
                }
                if let title1 = organization.objectForKey("IntroTitle1") as? String {
                    self.firstLabel.text = title1
                }
                if let title2 = organization.objectForKey("IntroTitle2") as? String {
                   self.secondLabel.text = title2
                    
                }
                if let para1 = organization.objectForKey("IntroParagraph1") as? String {
                    let paragraphStyle = NSMutableParagraphStyle()
                    paragraphStyle.lineSpacing = 7
                    let attribute = [NSParagraphStyleAttributeName: paragraphStyle]
                    self.firstTextView.attributedText = NSAttributedString(string: para1, attributes: attribute)
                     self.firstTextView.font = UIFont.systemFontOfSize(15)
                    self.firstTextView.selectable = false
                    self.firstTextView.editable = false
                    
                    
                }else{
                    self.scrollView.scrollEnabled = false
                }
                if let para2 = organization.objectForKey("IntroParagraph2") as? String {
                    let paragraphStyle = NSMutableParagraphStyle()
                    paragraphStyle.lineSpacing = 7
                    let attribute = [NSParagraphStyleAttributeName: paragraphStyle]
                    self.secondTextView.attributedText = NSAttributedString(string: para2, attributes: attribute)
                    self.secondTextView.font = UIFont.systemFontOfSize(15)
                    self.secondTextView.selectable = false
                    self.secondTextView.editable = false
                   
                }
            }
        }
    }
    
    func fetchGalleryURLs() {
        let query = BmobQuery(className: "OrgGallery")
        query.whereKey("OrgName", equalTo: orgName)
        query.findObjectsInBackgroundWithBlock { (galleryObjects, error) -> Void in
            if error == nil {
                for galleryObject in galleryObjects{
                    for var i = 0; i <= 30; ++i {
                        if let pic = galleryObject.objectForKey("Pic" + String(i)) as? BmobFile{
                            let url = NSURL(string: pic.url)
                            self.photos.append(MWPhoto(URL: url))
                            
                        }
                    }
                }
                
               
            }
        
        }

    }

    func setUpView() {
        let backButton = UIButton(frame: CGRectMake(0,0,30,30))
        backButton.setImage(UIImage(named: "back"), forState: .Normal)
        backButton.addTarget(self, action: "popCurrentVC", forControlEvents: .TouchUpInside)
        let backItem = UIBarButtonItem(customView: backButton)
        self.navigationItem.leftBarButtonItem = backItem
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.navigationBar.translucent = false

        scrollView.contentSize = CGSizeMake(375, 1400)
        scrollView.userInteractionEnabled = true
        mainImageView.contentMode = .ScaleAspectFill
        mainImageView.clipsToBounds = true
        secondImageView.contentMode = .ScaleAspectFill
        secondImageView.clipsToBounds = true
    }

    @IBAction func showOrgGallery() {
        let browser = MWPhotoBrowser(delegate: self)
        browser.startOnGrid = true
        self.navigationController?.pushViewController(browser, animated: true)
    }
    
    @IBAction func contactUs() {
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        composer.setToRecipients(emailRecipient)
        self.presentViewController(composer, animated: true, completion: nil)
    }
    
    func popCurrentVC() {
        self.navigationController?.popViewControllerAnimated(true)
    }

    
    func numberOfPhotosInPhotoBrowser(photoBrowser: MWPhotoBrowser!) -> UInt {
        return UInt(photos.count)
    }
    
    func photoBrowser(photoBrowser: MWPhotoBrowser!, photoAtIndex index: UInt) -> MWPhotoProtocol! {
        if Int(index) < photos.count {
            return photos[Int(index)]
        }
        
        return nil
    }
    
    func photoBrowser(photoBrowser: MWPhotoBrowser!, thumbPhotoAtIndex index: UInt) -> MWPhotoProtocol! {
        return photos[Int(index)]
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
