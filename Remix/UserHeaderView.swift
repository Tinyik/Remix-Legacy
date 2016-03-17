//
//  UserHeaderView.swift
//  Remix
//
//  Created by fong tinyik on 3/8/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit
import SDWebImage

class UserHeaderView: UIView {
    @IBOutlet weak var blurredAvatarView: UIImageView!
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    var user: AVUser!
    override func awakeFromNib() {
        print("AWAKE")
        blurredAvatarView.contentMode = .ScaleAspectFill
        blurredAvatarView.clipsToBounds = true
        avatarView.image = UIImage(named: "DefaultAvatar")
        avatarView.layer.cornerRadius = avatarView.frame.size.width/2
        avatarView.clipsToBounds = true
        avatarView.contentMode = .ScaleAspectFill
        blurredAvatarView.image = UIImage(named: "DefaultAvatar")
        userNameLabel.text = ""
    }
    
    func fetchUserInfo() {
        userNameLabel.text = user.username
        if let avatar = user.objectForKey("Avatar") as? AVFile {
            let avatarURL = NSURL(string:avatar.url)
            let manager = SDWebImageManager()
            manager.downloadImageWithURL(avatarURL, options: SDWebImageOptions.RetryFailed, progress: nil) { (avatar, error, cacheType, finished, url) -> Void in
                self.avatarView.image = avatar
                self.blurredAvatarView.image = avatar

            }
        }

    }
    
    

}
