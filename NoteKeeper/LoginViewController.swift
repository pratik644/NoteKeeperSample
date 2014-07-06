//
//  ViewController.swift
//  NoteKeeper
//
//  Created by Pratik on 03-07-14.
//  Copyright (c) 2014 Appacitive Software. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, MBProgressHUDDelegate {
    
    @IBOutlet var emailField: UITextField;
    @IBOutlet var passwordField: UITextField;
    var progressHUD:MBProgressHUD = MBProgressHUD();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.progressHUD = MBProgressHUD(view: self.view);
        self.progressHUD.delegate = self;
    }
    
    @IBAction func buttonTapped(sender: AnyObject) {
        self.progressHUD.labelText = "Please Wait";
        self.view.addSubview(progressHUD);
        self.progressHUD.show(true);
        if((sender as UIButton).titleLabel.text == "Login") {
            APUser.authenticateUserWithUsername(emailField.text, password: passwordField.text, sessionExpiresAfter: nil, limitAPICallsTo: nil, successHandler: { (user: APUser!) -> Void in
                    self.performSegueWithIdentifier("showList", sender: nil);
                    self.progressHUD.removeFromSuperview();
                }, failureHandler: { (error: APError!) -> Void in
                    var alert = UIAlertController(title: "Login", message: "Failed", preferredStyle: UIAlertControllerStyle.Alert);
                    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil));
                    self.progressHUD.removeFromSuperview();
                    self.presentViewController(alert, animated: true, completion: nil);
                }
            );
        } else {
            var newUser = APUser();
            newUser.firstName = emailField.text;
            newUser.email = emailField.text;
            newUser.username = emailField.text;
            newUser.password = passwordField.text
            newUser.saveObjectWithSuccessHandler( { (result:NSDictionary!) -> Void in
                self.progressHUD.removeFromSuperview();
                self.performSegueWithIdentifier("showList", sender: nil);
            }, failureHandler: { (error:APError!) -> Void in
                var alert = UIAlertController(title: "Sign Up", message: "Failed", preferredStyle: UIAlertControllerStyle.Alert);
                alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil));
                self.progressHUD.removeFromSuperview();
                self.presentViewController(alert, animated: true, completion: nil);
            });
        }
    }

}

