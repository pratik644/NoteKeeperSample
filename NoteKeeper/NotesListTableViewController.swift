//
//  NotesListTableViewController.swift
//  NoteKeeper
//
//  Created by Pratik on 03-07-14.
//  Copyright (c) 2014 Appacitive Software. All rights reserved.
//

import UIKit

class NotesListTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    strong var notes:NSMutableArray = NSMutableArray();
    strong var selectedNoteObject:APObject = APObject();
    var progressHUD = MBProgressHUD();
    @IBOutlet var tableView:UITableView;
    
    @IBAction func newNoteButtonTapped(sender:AnyObject) {
        self.selectedNoteObject = APObject();
        self.performSegueWithIdentifier("showNote", sender: self);
    }
    
    @IBAction func logoutButtonTapped(sender:AnyObject) {
        APUser.logOutCurrentUser();
        self.dismissModalViewControllerAnimated(true)
    }
    
    override func viewDidAppear(animated: Bool)  {
        self.progressHUD.labelText = "Please Wait";
        self.view.addSubview(progressHUD);
        self.progressHUD.show(true);
        notes = NSMutableArray();
        APConnections.fetchObjectsConnectedToObjectOfType("user", withObjectId: (APUser.currentUser().objectId), withRelationType: "owns", fetchConnections: false, successHandler:{ (objects: Array!) -> Void in
            for object:AnyObject in objects {
                self.notes.addObject((object as APGraphNode).object);
            }
            self.tableView.reloadData();
            self.progressHUD.removeFromSuperview();
            });
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        self.progressHUD = MBProgressHUD(view:self.view);
    }
    
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1
    }

    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return self.notes.count;
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath?) -> UITableViewCell? {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("cell") as? UITableViewCell
        
        if !cell {
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "cell")
        }
        (cell as UITableViewCell).textLabel.text = ((notes[(indexPath as NSIndexPath).row] as APObject).getPropertyWithKey("title") as String);
        return (cell as UITableViewCell);
    }
    
    func tableView(tableView: UITableView?, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath?) {
        if editingStyle == .Delete {
            (self.notes.objectAtIndex((indexPath as NSIndexPath).row) as APObject).deleteObjectWithConnectingConnectionsSuccessHandler({ () -> Void in
                    self.notes.removeObjectAtIndex((indexPath as NSIndexPath).row);
                    self.tableView.reloadData();
                },failureHandler: { (error:APError!) -> Void in
                    NSLog("error:%@",error.description);
                });
        } else if editingStyle == .Insert {
            
        }    
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        self.selectedNoteObject = (notes.objectAtIndex((indexPath as NSIndexPath).row) as APObject);
        self.performSegueWithIdentifier("showNote", sender: self);
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        (((segue as UIStoryboardSegue).destinationViewController) as NoteViewController).noteObject = self.selectedNoteObject;
    }
}
