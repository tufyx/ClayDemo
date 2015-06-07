//
//  Door.swift
//  ClayDemo
//
//  Created by Tufyx on 01/06/2015.
//  Copyright (c) 2015 tufyx. All rights reserved.
//

import Foundation

// the Door model
class Door: NSCoder {
    
    // id of the door
    var id: Int
    
    // name of the doors
    var doorName: String
    
    // description of the door
    var doorDescription: String
    
    // the access level of the door
    var accessLevel: AccessLevel
    
    // a computed property for retrieving the NSData representation of this object
    var encodedRepresentation: NSData {
        return NSKeyedArchiver.archivedDataWithRootObject(self)
    }
    
    // simple initializer; sets the properties to empty values and the access level to a random value
    override init() {
        self.id = 0
        self.doorName = ""
        self.doorDescription = ""
        self.accessLevel = AccessLevel(rawValue: Int(arc4random() % 8))!
        super.init()
    }
    
    // initializes the object from a coder
    // used to easily convert from a NSData representation directly into a Door object
    required init(coder aDecoder: NSCoder) {
        self.id = aDecoder.decodeObjectForKey("id") as! Int
        self.doorName = aDecoder.decodeObjectForKey("doorName") as! String
        self.doorDescription = aDecoder.decodeObjectForKey("doorDescription") as! String
        self.accessLevel = AccessLevel(rawValue: aDecoder.decodeObjectForKey("accessLevel") as! Int)!
        super.init()
    }
    
    // convenience initializer which creates a door with a given name, description and access level
    convenience init(name: String, doorDescription: String, level: AccessLevel) {
        self.init()
        self.doorName = name
        self.doorDescription = doorDescription
        self.accessLevel = level
    }
    
    // required by NSKeyedArchiver.archivedDataWithRootObject via encodedRepresentation to encode the object to NSData
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(id, forKey: "id")
        coder.encodeObject(doorName, forKey: "doorName")
        coder.encodeObject(doorDescription, forKey: "doorDescription")
        coder.encodeObject(accessLevel.rawValue, forKey: "accessLevel")
    }
    
    // saves the door in the standardUserDefaults
    func save() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        // set the id of the current object
        self.id = Utils.nextIDForKey(Utils.kNextDoorID)
        // if the kClayDoors property has been written, retrieve it
        if var clayDoors: [NSData] = userDefaults.objectForKey(Utils.kClayDoors) as? [NSData] {
            // add the encoded representation of the current object to the existing list
            clayDoors.append(self.encodedRepresentation)
            // write the object back to the kClayDoors key
            userDefaults.setObject(clayDoors, forKey: Utils.kClayDoors)
        } else {
            // write a list containing this element to the kClayDoors key
            userDefaults.setObject([self.encodedRepresentation], forKey: Utils.kClayDoors)
        }
        userDefaults.synchronize()
    }
    
    // updates an existing door in the standardUserDefaults
    func update() {
        // retrieve the list of doors
        var doors = Utils.readDoors()
        var doorData: [NSData] = []
        for door in doors {
            // update the properties of the current door
            if self.id == door.id {
                door.doorName = self.doorName
                door.doorDescription = self.doorDescription
                door.accessLevel = self.accessLevel
            }
            doorData.append(door.encodedRepresentation)
        }
        // save the new array of doors in the kClayDoors key
        Utils.saveInUserDefaults(doorData, key: Utils.kClayDoors)
    }
    
    // deletes an existing door from standardUserDefaults
    func delete() {
        // retrieve the list of doors
        var doors = Utils.readDoors()
        var doorData: [NSData] = []
        for door in doors {
            // delete the current door from the list
            if self.id == door.id {
                doors.removeAtIndex(find(doors, door)!)
                // when the current door was found in the list, skip to the next element and don't add it again to the list
                continue
            }
            doorData.append(door.encodedRepresentation)
        }
        // save the new array of doors in the kClayDoors key
        Utils.saveInUserDefaults(doorData, key: Utils.kClayDoors)
    }
}
