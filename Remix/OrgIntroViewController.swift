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
import TTGSnackbar

class OrgIntroViewController: UIViewController, MWPhotoBrowserDelegate, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var firstTextView: UITextView!
    @IBOutlet weak var secondImageView: UIImageView!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var secondTextView: UITextView!
    @IBOutlet weak var mailButton: UIButton!
    @IBOutlet weak var scrollContentHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollContentView: UIView!
    
    
    var photos: [MWPhoto] = []
    var orgName = "Remix"
    var emailRecipient = ["fongtinyik@gmail.com"]
    var phoneNumber: String = "18149770476"
    var contactName: String = "房天益"
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        fetchGalleryURLs()
        let query = AVQuery(className: "Organization")
        query.whereKey("Name", equalTo: orgName)
        query.findObjectsInBackgroundWithBlock { (organizations, error) -> Void in
           
            if error == nil {
                for organization in organizations {
                    if let _recipient = organization.objectForKey("Emails") as? NSArray {
                        self.emailRecipient = _recipient as! [String]
                    }
                    if let _contact = organization.objectForKey("Contact") as? String {
                        self.phoneNumber = _contact
                    }
                    if let _contactName = organization.objectForKey("ContactName") as? String {
                        self.contactName = _contactName
                    }
                    if let image1 = organization.objectForKey("IntroImage1") as? AVFile {
                        let url = NSURL(string: image1.url)
                        self.mainImageView.sd_setImageWithURL(url, placeholderImage: UIImage(named: "SDPlaceholder"))
                    }
                    if let image2 = organization.objectForKey("IntroImage2") as? AVFile {
                        let url = NSURL(string: image2.url)
                        self.secondImageView.sd_setImageWithURL(url, placeholderImage: UIImage(named: "SDPlaceholder"))
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
                    
                    
                    // Calculate scroll content height
                    var contentRect = CGRectZero
                    for view in self.scrollContentView.subviews {
                        view.layoutIfNeeded()
                        contentRect = CGRectUnion(contentRect, view.frame)
                    }
                    
                    let bottomMargin: CGFloat = 30
                    self.scrollContentHeight.constant = contentRect.size.height + bottomMargin
                }
            }else{
                let snackBar = TTGSnackbar.init(message: "获取数据失败。请检查网络连接后重试。", duration: .Middle)
                snackBar.backgroundColor = FlatWatermelonDark()
                snackBar.show()
            }

        }
    }
    
        
    func fetchGalleryURLs() {
        let query = AVQuery(className: "OrgGallery")
        query.whereKey("OrgName", equalTo: orgName)
        query.findObjectsInBackgroundWithBlock { (galleryObjects, error) -> Void in
            if error == nil {
                for galleryObject in galleryObjects{
                    for var i = 0; i <= 30; ++i {
                        if let pic = galleryObject.objectForKey("Pic" + String(i)) as? AVFile{
                            let url = NSURL(string: pic.url)
                            self.photos.append(MWPhoto(URL: url))
                            
                        }
                    }
                }
                
               
            }else{
                let snackBar = TTGSnackbar.init(message: "获取数据失败。请检查网络连接后重试。", duration: .Middle)
                snackBar.backgroundColor = FlatWatermelonDark()
                snackBar.show()
            }

        
        }

    }

    func setUpView() {
       self.navigationController?.navigationBar.tintColor = .whiteColor()
        self.scrollView.contentInset.top = -65
        self.title = "简介"
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
        if MFMailComposeViewController.canSendMail() {
            let composer = MFMailComposeViewController()
            composer.mailComposeDelegate = self
            composer.setToRecipients(emailRecipient)
            self.presentViewController(composer, animated: true, completion: nil)
        }else{
            let snackBar = TTGSnackbar.init(message: "请先在 \"系统设置-邮件、通讯录、日历\" 中添加邮箱。", duration: .Middle)
            snackBar.backgroundColor = FlatWatermelonDark()
            snackBar.show()
        }
    }
    
    @IBAction func dialPhone() {
        let alert = UIAlertController(title: "Remix拨号确认", message: "确认拨打 " + contactName + "  " + phoneNumber + " ?", preferredStyle: .ActionSheet)
        let action = UIAlertAction(title: "确认", style: .Default) { (action) -> Void in
            UIApplication.sharedApplication().openURL(NSURL(string: "tel://" + self.phoneNumber)!)
        }
        let cancel = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
        alert.addAction(action)
        alert.addAction(cancel)
        self.presentViewController(alert, animated: true, completion: nil)
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
