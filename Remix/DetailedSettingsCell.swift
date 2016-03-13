//
//  SettingsWithDetailsCell.swift
//  Remix
//
//  Created by fong tinyik on 2/10/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit

class DetailedSettingsCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var icon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
