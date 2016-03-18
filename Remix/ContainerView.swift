//
//  ContainerView.swift
//  Remix
//
//  Created by fong tinyik on 3/18/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit

class ContainerView: UIView {
 
    override func awakeFromNib() {
        self.layer.cornerRadius = 4
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor(white: 0.9, alpha: 0.4).CGColor
        let tap = UITapGestureRecognizer(target: self, action: "handleTap")
        self.addGestureRecognizer(tap)
    }
    
    func handleTap() {
        for view in self.subviews {
            if let button = view as? UIButton {
                button.sendActionsForControlEvents(.TouchUpInside)
            }
        }
    }
}
