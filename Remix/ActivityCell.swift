//
//  ActivityCell.swift
//  Remix
//
//  Created by fong tinyik on 3/8/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit

class ActivityCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var themeImg: UIImageView!
    @IBOutlet weak var statusIndicator: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceTag: UILabel!
    @IBOutlet weak var orgLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var orderNoLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
