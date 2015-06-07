//
//  LogItemCell.swift
//  ClayDemo
//
//  Created by Tufyx on 02/06/2015.
//  Copyright (c) 2015 tufyx. All rights reserved.
//

import UIKit

// The class for the LogItemCell view
class LogItemCell: UITableViewCell {
    // the label displaying the name of the accessed door
    @IBOutlet weak var doorLabel: UILabel!
    
    // the label displaying the name of the user accessing the door
    @IBOutlet weak var userLabel: UILabel!
    
    // the date on which the event was registered
    @IBOutlet weak var dateLabel: UILabel!
    
    // the image placeholder showing the indicator of the event's status
    @IBOutlet weak var statusImage: UIImageView!
    
    // the logItem which is displayed by this cell
    var logItem: LogItem? {
        didSet {
            self.doorLabel.text = "Door: \(logItem!.door.doorName)"
            self.userLabel.text = "User: \(logItem!.user.email)"
            self.dateLabel.text = "Date: \(logItem!.date.description)"
            self.statusImage.image = UIImage(named: logItem!.result == false ? "lock" : "o_lock")
        }
    }
}
