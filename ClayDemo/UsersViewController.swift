//
//  UsersViewController.swift
//  ClayDemo
//
//  Created by Tufyx on 01/06/2015.
//  Copyright (c) 2015 tufyx. All rights reserved.
//

import UIKit

class UsersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UserProtocol {

    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var userList: UITableView!
    
    // the data source of the userList table view
    var users: Array<User> = []
    
    override func viewDidLoad() {
        self.configureUserList()
        self.configureListeners()
    }
    
    // configure the delegate and dataSource for the user list
    // retrieve the existing users from standardUserDefaults
    func configureUserList() {
        self.userList.dataSource = self
        self.userList.delegate = self
        self.users = Utils.readUsers()
        self.userList.reloadData()
    }
    
    // configure the listeners for the UI elements
    func configureListeners() {
        self.addButton.target = self
        self.addButton.action = "displayAddUserScene"
    }
    
    func displayAddUserScene() {
        self.presentViewController(createNewUserScene(), animated: true, completion: nil)
    }
    
    // creates the NewUserVC to be presented in either Add or Edit mode
    func createNewUserScene() -> NewUserViewController {
        let newUserVC: NewUserViewController = self.storyboard?.instantiateViewControllerWithIdentifier("NewUserVC") as! NewUserViewController
        newUserVC.delegate = self
        return newUserVC
    }
    
    // UITableViewDataSource protocol implementation
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let userCell = tableView.dequeueReusableCellWithIdentifier("UserCell", forIndexPath: indexPath) as! UserCell
        
        userCell.user = self.users[indexPath.row]
        return userCell
    }
    
    // UITableViewDelegate protocol implementation
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        let user = self.users[indexPath.row]
        if let current = User.currentUser() {
            if current.id == user.id {
                return false
            }
        }
        return true
    }
    
    // define editing actions for a row
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        
        // the edit action and its attached closure function
        var editRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Edit", handler:{action, indexpath in
            let editedUser = self.users[indexPath.row]
            let editUserVC = self.createNewUserScene()
            editUserVC.editedUser = editedUser
            self.presentViewController(editUserVC, animated: true, completion: nil)
            tableView.setEditing(false, animated: true)
        });
        editRowAction.backgroundColor = UIColor(red: 242/255.0, green: 160/255.0, blue: 3/255.0, alpha: 1.0);
        
        // the delete action and its attached closure function
        var deleteRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete", handler:{action, indexpath in
            let user = self.users[indexPath.row]
            user.delete()
            self.users.removeAtIndex(indexPath.row)
            self.userList.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Left)
        });
        
        return [deleteRowAction, editRowAction];
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        // do nothing; the method is needed for the edit/delete behavior to work correctly; apparently a bug
    }
    

    // handle the selection of the user; display the LogsVC in the user mode - shows all logs entries produced by that specific user
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        let logsVC: LogViewController = self.storyboard?.instantiateViewControllerWithIdentifier("LogsVC") as! LogViewController
        logsVC.forUser = self.users[indexPath.row]
        logsVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(logsVC, animated: true)
    }
    
    // UserProtocol implementation
    
    // called after a user was created from the NewUserVC scene
    func userWasCreated(user: User) {
        // save the user in the standardUserDefaults
        user.save()
        // append the user to the current list
        self.users.append(user)
        // reload the userList
        self.userList.reloadData()
    }
    
    // called after a user was edited in the NewUserVC scene
    func userWasEdited(edited: User) {
        for user in self.users {
            // when the edited user is found, update the properties
            if edited == user {
                user.name = edited.name
                user.email = edited.email
                user.accessLevel = edited.accessLevel
                // update the user in the standardUserDefaults
                edited.update()
                break
            }
        }
        // reload the userList
        self.userList.reloadData()
    }    
}
