//
//  ProfileViewController.swift
//  ClayDemo
//
//  Created by Tufyx on 06/06/2015.
//  Copyright (c) 2015 tufyx. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    // the label displaying the current user's username
    @IBOutlet weak var usernameLabel: UILabel!
    // the label displaying the current user's email
    @IBOutlet weak var emailLabel: UILabel!
    // the label displaying the current user's access level
    @IBOutlet weak var accessLevelLabel: UILabel!
    // the logout button
    @IBOutlet weak var logoutButtons: UIButton!
    // the user for which this scene displays the details
    var user: User?
    
    override func viewDidLoad() {
        // set the user to the currently logged in user
        self.user = User.currentUser()
        self.setupUI()
        self.configureListeners()
    }
    
    // setup the UI of this scene
    func setupUI() {
        self.imageView.layer.cornerRadius = self.imageView.frame.height / 2
        self.imageView.clipsToBounds = true
        self.imageView.layer.borderColor = UIColor(red: 0.227, green: 0.619, blue: 0.137, alpha: 1.0).CGColor
        self.imageView.layer.borderWidth = 1.0
        self.usernameLabel.text = "Name: \(self.user!.name)"
        self.emailLabel.text = "Email: \(self.user!.email)"
        self.accessLevelLabel.text = "Level: \(user!.accessLevel.rawValue)"
    }
    
    // configure the logout button listener
    func configureListeners() {
        self.logoutButtons.addTarget(self, action: "logoutUser", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func logoutUser() {
        self.user!.logout()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
