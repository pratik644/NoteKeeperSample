//
//  NoteViewController.swift
//  NoteKeeper
//
//  Created by Pratik on 03-07-14.
//  Copyright (c) 2014 Appacitive Software. All rights reserved.
//

import UIKit

class NoteViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    
    @IBOutlet strong var noteTitleField:UITextField = UITextField();
    @IBOutlet strong var noteTextView:UITextView = UITextView();
    
    strong var noteObject = APObject(typeName: "note");
    var isNew:Bool = true;
    var progressHUD = MBProgressHUD();
    
    override func viewDidLoad(){
        super.viewDidLoad();
        if(noteObject.getPropertyWithKey("title") != nil) {
            self.noteTitleField.text = (noteObject.getPropertyWithKey("title") as NSString);
            isNew = false;
        }
        if(noteObject.getPropertyWithKey("content") != nil) {
        self.noteTextView.text = (noteObject.getPropertyWithKey("content") as NSString);
            isNew = false;
        }
    }
    
    @IBAction func savebuttonTapped() {
        self.progressHUD.labelText = "Please Wait";
        self.view.addSubview(progressHUD);
        self.progressHUD.show(true);
        noteObject.type = "note";
        if(isNew == false) {
            noteObject.updatePropertyWithKey("title", value: self.noteTitleField.text);
            noteObject.updatePropertyWithKey("content", value: self.noteTextView.text);
            noteObject.updateObject();
            self.progressHUD.removeFromSuperview();
            self.cancelbuttonTapped();
        } else {
            noteObject.addPropertyWithKey("title", value: self.noteTitleField.text);
            noteObject.addPropertyWithKey("content", value: self.noteTextView.text);
            noteObject.saveObjectWithSuccessHandler({(result:NSDictionary!) -> Void in
                var connection = APConnection(relationType: "owns");
                connection.createConnectionWithObjectA((APUser.currentUser() as APUser), objectB:(self.noteObject as APObject), labelA:"user", labelB:"note",
                    successHandler: { () -> Void in
                        self.progressHUD.removeFromSuperview();
                        self.cancelbuttonTapped();
                    }, failureHandler: { (error: APError!) -> Void in
                        NSLog("%@",error.description);
                        self.progressHUD.removeFromSuperview();
                        self.cancelbuttonTapped();
                    });
                }, failureHandler: {(error:APError!) -> Void in
                    NSLog("%@",error.description);
                    self.progressHUD.removeFromSuperview();
                    self.cancelbuttonTapped();
                });
        }
    }
    
    @IBAction func cancelbuttonTapped() {
        self.dismissModalViewControllerAnimated(true);
    }
    
    func textViewDidBeginEditing(textView: UITextView!) {
        if(self.noteTextView.text == "Note goes here...") {
            self.noteTextView.text = "";
        }
    }
}
