//
//  LogViewController.swift
//  ClayDemo
//
//  Created by Tufyx on 04/06/2015.
//  Copyright (c) 2015 tufyx. All rights reserved.
//

import UIKit

class LogViewController: UITableViewController {
    
    // the mode in which the LogVC operates
    // .User - displays log items belonging the forUser object
    // .Door - displays log items belonging to the forDoor object
    private var logMode: LogMode?
    
    // the data source of the log list
    var entries: [LogItem] = []
    var forDoor: Door? {
        didSet {
            self.logMode = LogMode.Door
        }
    }
    var forUser: User? {
        didSet {
            self.logMode = LogMode.User
        }
    }
    
    // setup the scene title according to the mode of the VC
    override func viewDidLoad() {
        var title = "History Log"
        if self.forDoor != nil {
            title = "Door Log"
        } else if self.forUser != nil {
            title = "User Log"
        }
        self.navigationItem.title = title
        self.tableView.allowsSelection = false
    }
    
    // fetch the log entries to be displayed in this scene
    override func viewWillAppear(animated: Bool) {
        self.entries = Utils.readLogsFor(self.logMode, filterUser: self.forUser, filterDoor: self.forDoor)
        self.tableView.reloadData()
    }
    
    // UITableViewDataSource protocol implementation
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.entries.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let logItemCell: LogItemCell = tableView.dequeueReusableCellWithIdentifier("LogItemCell", forIndexPath: indexPath) as! LogItemCell
        logItemCell.logItem = self.entries[indexPath.row]
        return logItemCell
    }
}