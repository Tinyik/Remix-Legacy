//
//  InfoCell.swift
//  Remix
//
//  Created by fong tinyik on 2/26/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit

class InfoCell: UITableViewCell {

     @IBOutlet weak var titleLabel: UILabel!
     @IBOutlet weak var detailLabel: UILabel!
    var editingPropertyKey: String!
    var placeHolder: String!
    var explanationText: String!
    var currentValue = ""

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
