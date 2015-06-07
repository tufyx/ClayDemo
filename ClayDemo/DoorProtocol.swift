//
//  UserProtocol.swift
//  ClayDemo
//
//  Created by Tufyx on 02/06/2015.
//  Copyright (c) 2015 tufyx. All rights reserved.
//

import Foundation

// A protocol for loosely coupling between the DoorsVC and NewDoorVC
// Defines two callback methods to be called after the door has been created/edited in the NewDoorVC in order to update the UI in the DoorsVC
protocol DoorProtocol {
    func doorWasCreated(door: Door)
    func doorWasEdited(door: Door)
}
