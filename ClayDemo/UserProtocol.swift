//
//  UserProtocol.swift
//  ClayDemo
//
//  Created by Tufyx on 02/06/2015.
//  Copyright (c) 2015 tufyx. All rights reserved.
//

import Foundation

// A protocol for loosely coupling between the UsersVC and NewUserVC
// Defines two callback methods to be called after the user has been created/edited in the NewUserVC in order to update the UI in the UsersVC
protocol UserProtocol {
    func userWasCreated(user: User)
    func userWasEdited(user: User)
}
