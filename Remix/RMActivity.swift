//
//  RMActivity.swift
//  Remix
//
//  Created by fong tinyik on 2/5/16.
//  Copyright © 2016 fong tinyik. All rights reserved.
//

import UIKit

class RMActivity: NSObject {
    var _title: String!
    var _description: String!
    var _URL:NSURL!
    var _org: String!
    var _coverImg: UIImage!
    var _date: String!
    var _labels:[String]!
    
    
    init(title: String,
        description: String,
        URL:NSURL,
        org: String,
        coverImg: UIImage,
        date: String,
        labels:[String]) {
            _title = title
            _description = description
            _URL = URL
            _org = org
            _coverImg = coverImg
            _date = date
            _labels = labels
    }
    
    
    
}
