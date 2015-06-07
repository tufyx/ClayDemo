//
//  LoginViewController.swift
//  ClayDemo
//
//  Created by Tufyx on 01/06/2015.
//  Copyright (c) 2015 tufyx. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    // the textfield in which the username is introduced
    @IBOutlet weak var usernameTextField: UITextField!
    // the textfield in which the password is introduced
    @IBOutlet weak var passwordTextField: UITextField!
    // the login button
    @IBOutlet weak var loginButton: UIButton!
    // an activity indicator to give the user some visual feedback that a login request is performed
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        self.configureUI()
    }
    
    override func viewDidAppear(animated: Bool) {
        // if the kClayUsername key is written, attempt to automatically login
        if let user = User.currentUser() {
            self.attemptLogin(["username": user.name, "password": user.password])
        }
    }
    
    // sets up the UI
    func configureUI() {
        self.usernameTextField.placeholder = "Username ..."
        self.passwordTextField.placeholder = "Password ..."
        self.passwordTextField.secureTextEntry = true
        // set a TapGestureRecognizer on this VC's view to hide the keyboard when tapping outside the input fields
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tapView"))
        // set the listener for the login button
        self.loginButton.addTarget(self, action: "loginUser", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func tapView() {
        self.usernameTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
    }
    
    func loginUser() {
        let username = usernameTextField.text
        let password = passwordTextField.text
        self.fakeServerRequestWithData(["username": username, "password": password])
    }
    
    // simulates a long task by means of a timer
    // when the timer is completed the actual login function is performed
    func fakeServerRequestWithData(data: [String: String]) {
        self.loginButton.setTitle("", forState: UIControlState.Normal)
        self.activityIndicator.startAnimating()
        NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: "timerCompleted:", userInfo: data, repeats: false)
    }
    
    func timerCompleted(timer: NSTimer) {
        self.attemptLogin(timer.userInfo! as! [String: String])
    }
    
    // verifies the given login data in the data dictionary against the list of existing users
    func attemptLogin(data: [String: String]) {
        let username = data["username"] as String!
        let password = data["password"] as String!
        let users = Utils.readUsers()
        
        for user in users {
            if user.name == username && user.password == password {
                // if the credentials are correct save the user details in the kClayUsername key
                user.remember()
                // show the app's main UI for the user's role
                self.showMainUI(user.role)
                // stop iterating through the users once the right user was found
                return
            }
        }
        // if no user matches the entered credentials give some visual feedback that the login process failed
        self.shakeOnError(usernameTextField)
        self.shakeOnError(passwordTextField)
        // stop animating the activity indicator
        self.activityIndicator.stopAnimating()
        // reset the title of the login button
        self.loginButton.setTitle("Login", forState: UIControlState.Normal)
    }
    
    func showMainUI(userRole: UserRole) {
        let homeVC: UITabBarController = self.storyboard?.instantiateViewControllerWithIdentifier("HomeVC") as! UITabBarController
        if userRole == UserRole.Guest {
            var vcs = homeVC.viewControllers!
            vcs.removeAtIndex(1)
            homeVC.setViewControllers(vcs, animated: false)
        }
        self.presentViewController(homeVC, animated: true) { () -> Void in
            // completion handler after the homeVC is presented
            // resets the login UI and stops the animation of the activity indicator
            self.usernameTextField.text = ""
            self.passwordTextField.text = ""
            self.activityIndicator.stopAnimating()
            self.loginButton.setTitle("Login", forState: UIControlState.Normal)
        }
    }
    
    // defines a shake animation for the textField passed in as a parameter
    func shakeOnError(textField: UITextField) {
        // configure the animation
        let shakeAnimation = CAKeyframeAnimation( keyPath:"transform" )
        shakeAnimation.values = [
            NSValue( CATransform3D:CATransform3DMakeTranslation(-5, 0, 0 ) ),
            NSValue( CATransform3D:CATransform3DMakeTranslation( 5, 0, 0 ) )
        ]
        shakeAnimation.autoreverses = true
        shakeAnimation.repeatCount = 3
        shakeAnimation.duration = 5/100
        
        // add the animation on the target object
        textField.layer.addAnimation(shakeAnimation, forKey:nil )
    }

}
