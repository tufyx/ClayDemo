//
//  LogItem.swift
//  ClayDemo
//
//  Created by Tufyx on 02/06/2015.
//  Copyright (c) 2015 tufyx. All rights reserved.
//

import Foundation

// the LogItem model
class LogItem: NSCoder {
    // the door accessed for this log item
    var door: Door!
    
    // the user who accessed the door
    var user: User!
    
    // the result of the attempted access
    var result: Bool!
    
    // the date on which this access occurred
    var date: NSDate!
    
    // a computed property for retrieving the NSData representation of this object
    var encodedRepresentation: NSData {
        return NSKeyedArchiver.archivedDataWithRootObject(self)
    }
    
    override init() {
        super.init()
    }
    
    
    // initializes the object from a coder
    // used to easily convert from a NSData representation directly into a LogItem object
    required init(coder aDecoder: NSCoder) {
        self.door = aDecoder.decodeObjectForKey("door") as! Door
        self.user = aDecoder.decodeObjectForKey("user") as! User
        self.result = aDecoder.decodeObjectForKey("result") as! Bool
        self.date = aDecoder.decodeObjectForKey("date") as! NSDate
        super.init()
    }
    
    // convenience initializer which creates a log item for a given door, user, result and date
    convenience init(door: Door, user: User, result: Bool, date: NSDate) {
        self.init()
        self.door = door
        self.user = user
        self.result = result
        self.date = date
    }

    // required by NSKeyedArchiver.archivedDataWithRootObject via encodedRepresentation to encode the object to NSData
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(door, forKey: "door")
        coder.encodeObject(user, forKey: "user")
        coder.encodeObject(result, forKey: "result")
        coder.encodeObject(date, forKey: "date")
    }
    
    // saves the log item in the standardUserDefaults
    func save() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        // if the kClayHistory property has been written, retrieve it
        if var clayHistoryItems: [NSData] = userDefaults.objectForKey(Utils.kClayHistory) as? [NSData] {
            // add the encoded representation of the current object to the existing list
            clayHistoryItems.append(self.encodedRepresentation)
            // write the object back to the kClayUsers key
            userDefaults.setObject(clayHistoryItems, forKey: Utils.kClayHistory)
        } else {
            // write a list containing this element to the kClayUsers key
            userDefaults.setObject([self.encodedRepresentation], forKey: Utils.kClayHistory)
        }
    }
    
    // decides whether this log item belongs to the specified user or not
    func belongsToUser(user: User) -> Bool {
        return self.user.id == user.id
    }
    
    
    // decides whether this log item belongs to the specified door or not
    func belongsToDoor(door: Door) -> Bool {
        return self.door.id == door.id
    }
}
