//
//  SettingsHeaderView.swift
//  Remix
//
//  Created by fong tinyik on 3/10/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit

class SettingsHeaderView: UIView {

    @IBOutlet weak var blurredAvatarView: UIImageView!
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var settingsButton: UIButton!
    
    override func awakeFromNib() {
        blurredAvatarView.contentMode = .ScaleAspectFill
        blurredAvatarView.clipsToBounds = true
        avatarView.userInteractionEnabled = true
        avatarView.image = UIImage(named: "DefaultAvatar")
        avatarView.layer.cornerRadius = avatarView.frame.size.width/2
        avatarView.clipsToBounds = true
        blurredAvatarView.image = UIImage(named: "DefaultAvatar")
    }
}
