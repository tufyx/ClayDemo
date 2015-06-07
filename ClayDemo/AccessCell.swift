//
//  AccessCell.swift
//  ClayDemo
//
//  Created by Tufyx on 02/06/2015.
//  Copyright (c) 2015 tufyx. All rights reserved.
//

import UIKit

// The class for the AccessCell view
class AccessCell: UITableViewCell {
    // the label displaying the access level name
    @IBOutlet weak var cellLabel: UILabel!
    
    // the accessLevel object which this cell displays
    var accessItem: AccessLevel? {
        // property observer for this property
        // when its value changes, the UI updates accordingly
        didSet {
            self.cellLabel.text = "Level \(accessItem!.rawValue)"
        }
    }
}
