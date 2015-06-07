//
//  DoorCell.swift
//  ClayDemo
//
//  Created by Tufyx on 01/06/2015.
//  Copyright (c) 2015 tufyx. All rights reserved.
//

import UIKit

// The class for the DoorCell view
class DoorCell: UITableViewCell {
    
    // the label displaying the door name
    @IBOutlet weak var doorNameLabel: UILabel!
    
    // the label displaying the door description
    @IBOutlet weak var doorDescriptionLabel: UILabel!
    
    // the door object which this cell displays
    var door: Door? {
        // property observer for this property
        // when its value changes, the UI updates accordingly
        didSet {
            self.doorNameLabel.text = door!.doorName
            self.doorDescriptionLabel.text = door!.doorDescription
        }
    }
}
