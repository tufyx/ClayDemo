
//
//  RandomStringGenerator.swift
//  ClayDemo
//
//  Created by Tufyx on 01/06/2015.
//  Copyright (c) 2015 tufyx. All rights reserved.
//

import Foundation

// Extension for email validator, unique string in a set and valid username
// Source for email: http://stackoverflow.com/questions/25471114/how-to-validate-an-e-mail-address-in-swift

extension String {
    var isEmail: Bool {
        let regex = NSRegularExpression(pattern: "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,4}$", options: .CaseInsensitive, error: nil)
        return regex?.firstMatchInString(self, options: nil, range: NSMakeRange(0, count(self))) != nil
    }
    
    var isValidUsername: Bool {
        return !self.isEmpty && self.rangeOfString(" ") != nil
    }
    
    func isUniqueInList(list: [String]) -> Bool {
        return !contains(list, self)
    }
}

// Utility class defining some keys which will be written in the NSUserDefaults
// a shorthand function for writing data in the NSUserDefaults
// and convenience functions for reading specific data from NSUserDefaults

class Utils: NSObject {
    
    static let kClayUsers = "clay_users"
    static let kClayHistory = "clay_history"
    static let kClayDoors = "clay_doors"
    static let kClayUsername = "clay_username"
    static let kNextUserID = "next_user_id"
    static let kNextDoorID = "next_door_id"
    
    // writes the data object at the specified key in the standardUserDefaults
    class func saveInUserDefaults(data: AnyObject, key: String) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(data, forKey: key)
        userDefaults.synchronize()
    }
    
    // reads the exisiting doors from the standardUserDefaults and returns them in an array
    class func readDoors() -> [Door] {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        var parsedDoors: [Door] = []
        if let doors: [NSData] = userDefaults.valueForKey(Utils.kClayDoors) as? [NSData] {
            for door in doors {
                let parsedDoor: Door = NSKeyedUnarchiver.unarchiveObjectWithData(door) as! Door
                parsedDoors.append(parsedDoor)
            }
        }
        return parsedDoors
    }
    
    // reads the exisiting users from the standardUserDefaults and returns them in an array
    class func readUsers() -> [User] {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        var parsedUsers: [User] = []
        if let users: [NSData] = userDefaults.valueForKey(Utils.kClayUsers) as? [NSData] {
            for user in users {
                let parsedUser: User = NSKeyedUnarchiver.unarchiveObjectWithData(user) as! User
                parsedUsers.append(parsedUser)
            }
        }
        return parsedUsers
    }
    
    // reads the exisiting logs (or specific logs based on the params) from the standardUserDefaults and returns them in an array
    // logMode: LogMode? - if set retrieves either logs for a door or for a user; otherwise retrieves all the log items
    // filterUser: User? - if set, retrieves the log items for this user
    // filterDoor: Door? - if set, retreives the log items for this door
    class func readLogsFor(logMode: LogMode?, filterUser user: User?, filterDoor door: Door?) -> [LogItem] {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        var parsedLogItems: [LogItem] = []
        if let events: [NSData] = userDefaults.valueForKey(Utils.kClayHistory) as? [NSData] {
            for event in events {
                let logItem: LogItem = NSKeyedUnarchiver.unarchiveObjectWithData(event) as! LogItem
                if let mode = logMode {
                    switch mode {
                    case LogMode.User:
                        if logItem.belongsToUser(user!) {
                            parsedLogItems.append(logItem)
                        }
                        break
                    case LogMode.Door:
                        if logItem.belongsToDoor(door!) {
                            parsedLogItems.append(logItem)
                        }
                        break
                    }
                } else {
                    parsedLogItems.append(logItem)
                }
            }
        }
        return parsedLogItems
    }
    
    class func accessLevelList() -> [AccessLevel] {
        return [.Level_0, .Level_1, .Level_2, .Level_3, .Level_4, .Level_5, .Level_6, .Level_7]
    }
    
    // a utility function returning the list of the currently registered emails
    class func emailList() -> [String] {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        var emailList: [String] = []
        if let users: [NSData] = userDefaults.valueForKey(Utils.kClayUsers) as? [NSData] {
            for user in users {
                let parsedUser: User = NSKeyedUnarchiver.unarchiveObjectWithData(user) as! User
                emailList.append(parsedUser.email)
            }
        }
        return emailList
    }
    
    // a utility function returning the list of the currently registered usernames
    class func usernameList() -> [String] {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        var userList: [String] = []
        if let users: [NSData] = userDefaults.valueForKey(Utils.kClayUsers) as? [NSData] {
            for user in users {
                let parsedUser: User = NSKeyedUnarchiver.unarchiveObjectWithData(user) as! User
                userList.append(parsedUser.name)
            }
        }
        return userList
    }
    
    // get the next available id for the given key
    // always obtained by incremeting the current value by 1
    // if no value is written in the key, 1 is written and then returned
    class func nextIDForKey(key: String) -> Int {
        var returnedID = 1
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let id = userDefaults.valueForKey(key) as? Int {
            returnedID = id + 1
        }
        userDefaults.setValue(returnedID, forKey: key)
        userDefaults.synchronize()
        return returnedID
    }
}
