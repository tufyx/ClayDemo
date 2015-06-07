//
//  UserCell.swift
//  ClayDemo
//
//  Created by Tufyx on 01/06/2015.
//  Copyright (c) 2015 tufyx. All rights reserved.
//

import UIKit

// The class for the UserCell view
class UserCell: UITableViewCell {
    
    // the label displaying the user name
    @IBOutlet weak var usernameLabel: UILabel!
    
    // the label displaying the user's access level
    @IBOutlet weak var accessLevelLabel: UILabel!
    
    // the user object which this cell displays
    var user: User? {
        // property observer for this property
        // when its value changes, the UI updates accordingly
        didSet {
            self.usernameLabel.text = user!.name
            self.accessLevelLabel.text = "Clearance Level: \(user!.accessLevel.rawValue)"
        }
    }
}
