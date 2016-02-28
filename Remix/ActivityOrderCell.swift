//
//  ActivityOrderCell.swift
//  Remix
//
//  Created by fong tinyik on 2/28/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit

class ActivityOrderCell: UITableViewCell {

    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var themeImg: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var priceTag: UILabel!
    @IBOutlet weak var orgLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var contactButton: UIButton!
    @IBOutlet weak var orderNoLabel: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        contactButton.layer.borderColor = UIColor(white: 0.8, alpha: 1).CGColor
        contactButton.layer.borderWidth = 1
        deleteButton.layer.borderColor = UIColor(white: 0.8, alpha: 1).CGColor
        deleteButton.layer.borderWidth = 1

        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
