//
//  RemixPassView.swift
//  Remix
//
//  Created by fong tinyik on 3/12/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit

class RemixPassView: UIView {

    @IBOutlet weak var backgroundView: UIImageView!
    @IBOutlet weak var holderLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var creditLabel: UILabel!
    @IBOutlet weak var passNumberLabel: UILabel!
    var user: BmobUser!
//    let alphebat = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"]
    func fetchUserInfo() {
        backgroundView.contentMode = .ScaleAspectFill
        holderLabel.textColor = UIColor(red: 1, green: 225/255, blue: 72/255, alpha: 1)
        if let avatar = user.objectForKey("Avatar") as? BmobFile {
            let url = NSURL(string: avatar.url)
            backgroundView.sd_setImageWithURL(url)
        }else{
            backgroundView.image = UIImage(named: "DefaultAvatar")
        }
        if user.objectForKey("LegalName") == nil {
            holderLabel.text = user.username
        }else{
            holderLabel.text = user.objectForKey("LegalName") as? String
        }
        let attributedString = NSMutableAttributedString(string: user.objectId)
        attributedString.addAttribute(NSKernAttributeName, value: 10, range: NSMakeRange(0, user.objectId.characters.count))
        passNumberLabel.attributedText = attributedString
        creditLabel.text = String(user.objectForKey("Credit") as! Int)
        balanceLabel.text = "￥" + String(user.objectForKey("Balance") as! Int)
    }
}
