//
//  UserRole.swift
//  ClayDemo
//
//  Created by Tufyx on 04/06/2015.
//  Copyright (c) 2015 tufyx. All rights reserved.
//

import Foundation

// an enumeration defining the available roles
enum UserRole: String {
    // Admin role has access to the admin user interface (tabs Doors/Users/History/Profile)
    // can add/edit/delete users and doors
    case Admin = "admin"
    // Guest role has access to the guest user interface (tabs Doors/History/Profile)
    // cannot add/edit/delete users and doors
    case Guest = "guest"
}
