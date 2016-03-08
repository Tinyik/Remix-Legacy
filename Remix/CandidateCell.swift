//
//  CandidateCell.swift
//  Remix
//
//  Created by fong tinyik on 3/8/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit

class CandidateCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var detailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarView.layer.cornerRadius = avatarView.frame.height/2
        avatarView.clipsToBounds = true
        avatarView.contentMode = .ScaleAspectFill
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
