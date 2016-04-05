//
//  OrgTableViewCell.swift
//  Remix
//
//  Created by fong tinyik on 4/3/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit

class OrgTableViewCell: UITableViewCell {

    @IBOutlet weak var logoView: UIImageView!

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var orgNameLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        logoView.layer.cornerRadius = logoView.frame.height/2
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
