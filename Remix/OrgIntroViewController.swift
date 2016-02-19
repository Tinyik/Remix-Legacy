//
//  OrgIntroViewController.swift
//  Remix
//
//  Created by fong tinyik on 2/19/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit

class OrgIntroViewController: UIViewController {

    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var firstTextView: UITextView!
    @IBOutlet weak var secondImageView: UIImageView!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var secondTextView: UITextView!
    
    var orgName = "Remix"

    override func viewDidLoad() {
        super.viewDidLoad()
        mainImageView.contentMode = .ScaleAspectFill
        mainImageView.clipsToBounds = true
        secondImageView.contentMode = .ScaleAspectFill
        secondImageView.clipsToBounds = true
        let query = BmobQuery(className: "Organization")
        query.whereKey("Name", equalTo: orgName)
        query.findObjectsInBackgroundWithBlock { (organizations, error) -> Void in
            for organization in organizations {
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
                if let title1 = organization.objectForKey("IntroTitle2") as? String {
                    self.secondLabel.text = title1
                }
                if let para1 = organization.objectForKey("IntroParagraph1") as? String {
                    self.firstTextView.text = para1
                }
                if let para2 = organization.objectForKey("IntroParagraph2") as? String {
                    self.secondLabel.text = para2
                }
            }
        }
    }


}
