
//
//  User.swift
//  ClayDemo
//
//  Created by Tufyx on 01/06/2015.
//  Copyright (c) 2015 tufyx. All rights reserved.
//

import Foundation

// the Door model
class User: NSCoder {
    // the id of the user
    var id: Int
    
    // the name of the user
    var name: String
    
    // the email of the user
    var email: String
    
    // the password of the user
    var password: String
    
    // the role of the user; one of the values of the UserRole enum (Admin, Guest)
    var role: UserRole
    
    // the access level of the user
    var accessLevel: AccessLevel
    
    // a computed property for retrieving the NSData representation of this object
    var encodedRepresentation: NSData {
        return NSKeyedArchiver.archivedDataWithRootObject(self)
    }
    
    // simple initializer; sets the properties to empty values and the access level to a random value
    override init() {
        self.id = 0
        self.name = ""
        self.email = ""
        self.password = "testclay"
        self.role = UserRole.Guest
        self.accessLevel = AccessLevel(rawValue: Int(arc4random() % 8))!
    }
    
    // initializes the object from a coder
    // used to easily convert from a NSData representation directly into a User object
    required init(coder aDecoder: NSCoder) {
        self.id = aDecoder.decodeObjectForKey("id") as! Int
        self.name = aDecoder.decodeObjectForKey("name") as! String
        self.email = aDecoder.decodeObjectForKey("email") as! String
        self.password = aDecoder.decodeObjectForKey("password") as! String
        self.accessLevel = AccessLevel(rawValue: aDecoder.decodeObjectForKey("accessLevel") as! Int)!
        self.role = UserRole(rawValue: aDecoder.decodeObjectForKey("role") as! String)!
        super.init()
    }
    
    // convenience initializer which creates a user with a given name, email and access level
    convenience init(name: String, email: String, accessLevel: AccessLevel) {
        self.init()
        self.name = name
        self.email = email
        self.accessLevel = accessLevel
    }
    
    // required by NSKeyedArchiver.archivedDataWithRootObject via encodedRepresentation to encode the object to NSData
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(id, forKey: "id")
        coder.encodeObject(name, forKey: "name")
        coder.encodeObject(email, forKey: "email")
        coder.encodeObject(password, forKey: "password")
        coder.encodeObject(role.rawValue, forKey: "role")
        coder.encodeObject(accessLevel.rawValue, forKey: "accessLevel")
    }
    
    // saves the door in the standardUserDefaults
    func save() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        // set the id of the current object
        self.id = Utils.nextIDForKey(Utils.kNextUserID)
        // if the kClayUsers property has been written, retrieve it
        if var clayUsers: [NSData] = userDefaults.objectForKey(Utils.kClayUsers) as? [NSData] {
            // add the encoded representation of the current object to the existing list
            clayUsers.append(self.encodedRepresentation)
            // write the object back to the kClayUsers key
            userDefaults.setObject(clayUsers, forKey: Utils.kClayUsers)
        } else {
            // write a list containing this element to the kClayUsers key
            userDefaults.setObject([self.encodedRepresentation], forKey: Utils.kClayUsers)
        }
        userDefaults.synchronize()
    }
    
    // updates an existing door in the standardUserDefaults
    func update(){
        // retrieve the list of users
        var users = Utils.readUsers()
        var userData: [NSData] = []
        for user in users {
            // update the properties of the current user
            if self.id == user.id {
                user.name = self.name
                user.email = self.email
                user.accessLevel = self.accessLevel
            }
            userData.append(user.encodedRepresentation)
        }
        // save the new array of users in the kClayDoors key
        Utils.saveInUserDefaults(userData, key: Utils.kClayUsers)
    }
    
    // deletes an existing user from standardUserDefaults
    func delete() {
        // retrieve the list of users
        var users = Utils.readUsers()
        var userData: [NSData] = []
        for user in users {
            // delete the current user from the list
            if self.id == user.id {
                users.removeAtIndex(find(users, user)!)
                // when the current user was found in the list, skip to the next element and don't add it again to the list
                continue
            }
            userData.append(user.encodedRepresentation)
        }
        // save the new array of doors in the kClayDoors key
        Utils.saveInUserDefaults(userData, key: Utils.kClayUsers)
    }
    
    // saves this user in the kClayUsername key, to automatically log-him in next time the app is opened
    func remember() {
        Utils.saveInUserDefaults(self.encodedRepresentation, key: Utils.kClayUsername)
    }
    
    // logs out this user from the app
    // does so by removing the object set at the key kClayUsername
    func logout() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.removeObjectForKey(Utils.kClayUsername)
        userDefaults.synchronize()
    }
    
    // convenience function returning the currently logged in user
    // does so by reading the object stored at the kClayUsername key
    class func currentUser() -> User? {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let userData = userDefaults.objectForKey(Utils.kClayUsername) as? NSData {
            let user = NSKeyedUnarchiver.unarchiveObjectWithData(userData) as! User
            return user
        }
        return nil
    }
}
