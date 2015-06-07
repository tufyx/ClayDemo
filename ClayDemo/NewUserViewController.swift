//
//  NewUserViewController.swift
//  ClayDemo
//
//  Created by Tufyx on 01/06/2015.
//  Copyright (c) 2015 tufyx. All rights reserved.
//

import UIKit

class NewUserViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var accessList: UITableView!
    
    // the data source for the accessList table view
    var accessLevels: [AccessLevel] = Utils.accessLevelList()
    
    // the selected level of the User
    var selectedLevel: AccessLevel?
    
    // the delegate of this VC
    var delegate: UserProtocol?

    // if set, the VC is in edit mode, and this variable should populate the input fields accordingly, as well as the accessList table view
    var editedUser: User?
    
    // setup the VC
    // configure the bar buttons' listeners
    // configure the accessList table view
    // configure the UI according to the mode of the VC
    override func viewDidLoad() {
        self.configureBarButtons()
        self.configureAccessList()
        self.configureUI()
    }
    
    // configure the UI of the VC
    // prefill the input fields with appropriate values if that is the case
    // setup a tap gesture to detect taps on the view such
    func configureUI() {
        if (self.editedUser != nil) {
            self.usernameTextField.text = editedUser!.name
            self.emailTextField.text = editedUser!.email
        }
        // set a TapGestureRecognizer on this VC's view to hide the keyboard when tapping outside the input fields
        let gesture = UITapGestureRecognizer(target: self, action: "tapView")
        gesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(gesture)
    }
    
    func tapView() {
        self.usernameTextField.resignFirstResponder()
        self.emailTextField.resignFirstResponder()
    }
    
    func configureAccessList() {
        self.accessList.dataSource = self
        self.accessList.delegate = self
    }
    
    func configureBarButtons() {
        self.saveButton.target = self
        self.cancelButton.target = self
        self.saveButton.action = "saveUser"
        self.cancelButton.action = "dismissScene"
    }
    
    // checks if the given email is unique or not
    func isUniqueEmail(email: String) -> Bool {
        // get the list of emails
        let emailList = Utils.emailList()
        // if in edit mode
        if let editEmail = self.editedUser?.email {
            // if the given email is the same with the email of the edited user, then there's no point in checking for uniqueness
            return email == editEmail ? true : email.isUniqueInList(emailList)
        } else {
            // if in add mode, check for uniqueness
            return email.isUniqueInList(emailList)
        }
    }
    
    // checks if the given username is unique or not
    func isUniqueUsername(username: String) -> Bool {
        // get the list of username
        let userList = Utils.usernameList()
        // if in edit mode
        if let editUsername = self.editedUser?.name {
            // if the given username is the same with the username of the edited user, then there's no point in checking for uniqueness
            return username == editUsername ? true : username.isUniqueInList(userList)
        } else {
            // if in add mode, check for uniqueness
            return username.isUniqueInList(userList)
        }
    }
    
    // validates the add/edit form
    // username should not be empty
    // user email should not empty
    // user email should have correct format
    // user email should be unique
    // an access level should be selected
    func isFormValid(formData: [String:String]) -> Bool {
        let username = formData["username"]!
        let email = formData["email"]!
        var errorMessage = ""
        if username.isEmpty {
            errorMessage = "Fill in username"
        } else if username.isValidUsername {
            errorMessage = "Username should not contain any whitespaces"
        } else if !self.isUniqueUsername(username) {
            errorMessage = "Username should be unique"
        } else if email.isEmpty {
            errorMessage = "Fill in user email"
        } else if !email.isEmail {
            errorMessage = "Email is invalid"
        } else if !self.isUniqueEmail(email) {
            // if the email has been edited and is not unique
            errorMessage = "Email already exists"
        } else if self.selectedLevel == nil {
            errorMessage = "Select a clearance level"
        }
        
        // if any error occurs during validation, an AlertView is displayed to the user notifying him about the error
        if !errorMessage.isEmpty {
            self.showErrorAlert(errorMessage)
            return false
        }
        return true
    }
    
    // configures and displays an AlertVC with the specified message
    // message: String - the error message
    func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default,handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func saveUser() {
        let username = self.usernameTextField.text
        let email = self.emailTextField.text
        
        if !self.isFormValid(["username":username, "email": email]) {
            return
        }
        
        if (self.editedUser != nil) {
            self.editedUser!.name = username
            self.editedUser!.email = email
            self.editedUser!.accessLevel = self.selectedLevel!
            self.delegate?.userWasEdited(self.editedUser!)
        } else {
            let user = User(name: username, email: email, accessLevel: self.selectedLevel!)
            self.delegate?.userWasCreated(user)
        }
        self.dismissScene()
    }
    
    func dismissScene() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // UITableViewDataSource protocol implementation
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.accessLevels.count
    }
    
    // display a cell in the table
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // instantiate the cell
        let accessCell: AccessCell = tableView.dequeueReusableCellWithIdentifier("AccessCell", forIndexPath: indexPath) as! AccessCell
        // configure the cell
        accessCell.accessItem = self.accessLevels[indexPath.row]
        
        //if scene is in Edit mode
        if let level = self.editedUser?.accessLevel {
            // and the current cell is the user's access level, set the accessory type to Checkmark
            if level == self.accessLevels[indexPath.row] {
                accessCell.accessoryType = UITableViewCellAccessoryType.Checkmark
                self.selectedLevel = self.accessLevels[indexPath.row]
            } else {
                // otherwise set the accessory type to None
                accessCell.accessoryType = UITableViewCellAccessoryType.None
            }
        }
        return accessCell
    }
    
    // handle the selection of a specific cell
    // show the Checkmark indicator when selecting a row
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.uncheckAllCells()
        self.accessList.deselectRowAtIndexPath(indexPath, animated: false)
        let cell = self.accessList.cellForRowAtIndexPath(indexPath) as! AccessCell
        cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        self.selectedLevel = self.accessLevels[indexPath.row]
    }
    
    // resets the accessoryType of all cells to None
    func uncheckAllCells() {
        for index in 0...self.accessLevels.count {
            if let cell = self.accessList.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) as? AccessCell {
                cell.accessoryType = UITableViewCellAccessoryType.None
            }
        }
    }
}