//
//  DoorsViewController.swift
//  ClayDemo
//
//  Created by Tufyx on 01/06/2015.
//  Copyright (c) 2015 tufyx. All rights reserved.
//

import UIKit

class DoorsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DoorProtocol {

    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var doorList: UITableView!
    
    // the data source of the doorList table view
    var doors: Array<Door> = []
    
    override func viewDidLoad() {
        self.configureDoorList()
        self.configureListeners()
    }
    
    // configure the delegate and dataSource for the door list
    // retrieve the existing doors from standardUserDefaults
    func configureDoorList() {
        self.doorList.dataSource = self
        self.doorList.delegate = self
        self.doors = Utils.readDoors()
        self.doorList.reloadData()
    }
    
    // configure the listeners for the UI elements
    func configureListeners() {
        // if the user is an admin, configure the listener for the addButton
        if User.currentUser()?.role == UserRole.Admin {
            self.addButton.target = self
            self.addButton.action = "displayAddDoorScene"
        } else {
            // otherwise hide the addButton
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    func displayAddDoorScene() {
        self.presentViewController(createNewDoorScene(), animated: true, completion: nil)
    }
    
    // creates the NewDoorVC to be presented in either Add or Edit mode
    func createNewDoorScene() -> NewDoorViewController {
        let newDoorVC: NewDoorViewController = self.storyboard?.instantiateViewControllerWithIdentifier("NewDoorVC") as! NewDoorViewController
        newDoorVC.delegate = self
        return newDoorVC
    }
    
    // UITableViewDataSource protocol implementation
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.doors.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let doorCell = tableView.dequeueReusableCellWithIdentifier("DoorCell", forIndexPath: indexPath) as! DoorCell
        doorCell.door = self.doors[indexPath.row]
        return doorCell
    }
    
    // UITableViewDelegate protocol implementation
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // can only edit a door if the current user is an Admin
        return User.currentUser()?.role == UserRole.Admin
    }
    
    // define editing actions for a row
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        
        // the edit action and its attached closure function
        var editRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Edit", handler:{action, indexpath in
            let editedDoor = self.doors[indexPath.row]
            let editDoorVC = self.createNewDoorScene()
            editDoorVC.editedDoor = editedDoor
            self.presentViewController(editDoorVC, animated: true, completion: nil)
            tableView.setEditing(false, animated: true)
        });
        editRowAction.backgroundColor = UIColor(red: 242/255.0, green: 160/255.0, blue: 3/255.0, alpha: 1.0);
        
        // the delete action and its attached closure function
        var deleteRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete", handler:{action, indexpath in
            let door = self.doors[indexPath.row]
            door.delete()
            self.doors.removeAtIndex(indexPath.row)
            self.doorList.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Left)
        });
        
        return [deleteRowAction, editRowAction];
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        // do nothing; the method is needed for the edit/delete behavior to work correctly; apparently a bug
    }
    
    // handle the selection of the door; display the DoorVC screen where the user can request the opening of the door
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        let doorVC: DoorViewController = self.storyboard?.instantiateViewControllerWithIdentifier("DoorVC") as! DoorViewController
        doorVC.hidesBottomBarWhenPushed = true
        doorVC.door = self.doors[indexPath.row]
        self.navigationController?.pushViewController(doorVC, animated: true)
    }
    
    // DoorProtocol implementation
    
    // called after a door was created from the NewDoorVC scene
    func doorWasCreated(door: Door) {
        // save the door in the standardUserDefaults
        door.save()
        // append the door to the current list
        self.doors.append(door)
        // reload the doorList
        self.doorList.reloadData()
    }
    
    // called after a door was edited in the NewDoorVC scene
    func doorWasEdited(edited: Door) {
        // iterate through the current doors
        for door in self.doors {
            // when the edited door is found, update the properties
            if edited == door {
                door.doorName = edited.doorName
                door.doorDescription = edited.doorDescription
                door.accessLevel = edited.accessLevel
                // update the door in the standardUserDefaults
                edited.update()
                break
            }
        }
        // reload the doorList
        self.doorList.reloadData()
    }
}
