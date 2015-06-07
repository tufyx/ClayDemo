//
//  DoorViewController.swift
//  ClayDemo
//
//  Created by Tufyx on 02/06/2015.
//  Copyright (c) 2015 tufyx. All rights reserved.
//

import UIKit

class DoorViewController: UIViewController {
    
    // the button for opening the door
    @IBOutlet weak var openDoorButton: UIButton!
    // the label displaying the door name
    @IBOutlet weak var doorNameLabel: UILabel!
    // the label displaying the door description
    @IBOutlet weak var doorDescriptionLabel: UILabel!
    // the progress bar loader
    @IBOutlet weak var clayLoader: ClayLoader!
    
    // the user performing the access request
    var user: User?
    // the door for which the access is requested
    var door: Door?
    // a flag indicating if the request is in progress or not
    var inProgress: Bool = false
    
    // setup the VC
    override func viewDidLoad() {
        self.user = User.currentUser()
        self.setupListeners()
        self.configureUI()
    }
    
    // before the view appears add an UIImageView with a lock, to indicate to the user that the door is currently closed
    override func viewWillAppear(animated: Bool) {
        view.addSubview(self.createImageSubView("lock", imageSize: 50.0))
    }
    
    // setup listeners in the scene
    func setupListeners() {
        // register for notifications with name ANIMATION_ENDED (dispatched by the ClayLoader view
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "animationDidEnd:", name: ClayLoader.ANIMATION_ENDED, object: nil)
        // setup the touch listener for the openDoorButton
        self.openDoorButton.addTarget(self, action: "requestDoorOpen", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    // configure the UI of this VC; set the scene's title, populate it with the door details and setup a right BarButtonItem to display door history
    func configureUI() {
        self.title = "Access"
        self.doorNameLabel.text = door!.doorName
        self.doorDescriptionLabel.text = door!.doorDescription
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "history"), style: UIBarButtonItemStyle.Plain, target: self, action: "showDoorHistory")
    }
    
    // creates a square view of given size imageSize, to display the image identified by imageName
    // imageName: String - the name of the image to be displayed
    // imageSize: String - the size of the newly created view
    func createImageSubView(imageName: String, imageSize: CGFloat) -> UIImageView {
        let imgX = (self.view.frame.width - imageSize) * 0.5
        let imgY = (self.view.frame.height - imageSize) * 0.5
        var imgView = UIImageView(frame: CGRectMake(imgX, imgY, imageSize, imageSize))
        imgView.image = UIImage(named: imageName)
        imgView.tag = 100
        return imgView
    }
    
    // handles the notification ANIMATION_ENDED received from the ClayLoader view
    func animationDidEnd(notification: NSNotification) {
        var result = false
        // if the user's access level is at least the door's access level, then grant access
        if self.user?.accessLevel.rawValue >= self.door!.accessLevel.rawValue {
            result = true
            // remove the image of the locked lock
            self.removeViewsWithTag(100)
            // change the label of the button to reflect the result of the request
            self.openDoorButton.setTitle("ACCESS GRANTED", forState: UIControlState.Normal)
            // add an UIImageView with an open lock to indicate to the user that the door is now open
            self.view.addSubview(self.createImageSubView("o_lock", imageSize: 50.0))
        } else {
            // change the label of the button to reflect the result of the request
            self.openDoorButton.setTitle("ACCESS DENIED", forState: UIControlState.Normal)
            // change the background of the button for a better UI indication of the result
            self.openDoorButton.backgroundColor = UIColor.redColor()
        }
        
        saveResult(result)
        
        self.openDoorButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        // setup a timer of 2 seconds to dismiss the scene once the access has been granted or denied
        NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: "timerCompleted", userInfo: nil, repeats: false)
    }
    
    // closure function of the timer
    func timerCompleted() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // search views with a specific tag and remove them from the super view
    // tag: Int - the tag to be searched
    func removeViewsWithTag(tag: Int) {
        for v in self.view.subviews {
            if v.tag == tag {
                v.removeFromSuperview()
            }
        }
    }
    
    // requests the opening of the door
    func requestDoorOpen() {
        // disable the openDoorButton
        self.openDoorButton.userInteractionEnabled = false
        // define how many times the loader should spin; this is just to simulate a long running task, such as an http request
        self.clayLoader.animationRepeatCount = Float(2.0) + Float(arc4random() % 3)
        self.view.addSubview(clayLoader)
        // trigger the animation
        self.clayLoader.animate()
    }
    
    // save the result of request in the log history
    func saveResult(result: Bool) {
        LogItem(door: self.door!, user: self.user!, result: result, date: NSDate()).save()
        
    }
    
    // displays the LogVC in the Door mode, showing all the entries for the specified door
    func showDoorHistory() {
        let logsVC: LogViewController = self.storyboard?.instantiateViewControllerWithIdentifier("LogsVC") as! LogViewController
        logsVC.forDoor = self.door
        logsVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(logsVC, animated: true)

    }
}
