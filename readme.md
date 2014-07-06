Developing an iOS Notes app using the Appacitive-iOS-SDK and Swift programming language
----

With the preview iOS 8, Apple unveiled a new programming language called __Swift__ for developing iOS apps. The Appacitive iOS SDK has been written using the Objective-C language. To maintain a backward compatibility for libraries written in Objective-C, Apple has provided a way to use the existing Objective-C code in an app written with the Swift language.

To use our existing Objective-C SDK in you swift app, you just need to do one extra thing. Let me explain it to you step-by-step.

1. Create a new single view app Xcode project, select the language as Swift.
2. Import the Appacitive-iOS-SDK in to the project.
3. Add a new Objective-C __.m__ file to the project, Xcode will display a prompt asking to create a bridged header file, approve the request.
4. Now you will see two new files in your _Project Navigator_, A __.m__ file and a __.h__ file (typically the .h file would be named something like this - __```<ProjectName>-Bridging-Header.h```__). Delete the __.m__ file since we would not be requiring it.
5. Open the newly created Bridging Header __.h__ file. Here you can add import statements for all the Objective-C  code you would need in your project. Add the following line to import the Appacitive-iOS-SDK into the project - __`#import <Appacitive/AppacitiveSDK.h>`__.

You are all set to use the existing Appacitive-iOS-SDK in your Swift app.

Now lets take a look at a very basic note taking sample app created using Appacitive-iOS-SDK and Swift.

Download the complete sample project from [here]().

The model of the app is as follows. We have a __note__ type with two properties _title_ and _content_. We have a relation called __owns__ between _user_ type and _note_ type.

####1. REGISTERING THE APP WITH APPACITIVE
Open the __AppDelegate.swift__ file and in the `application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: NSDictionary?) -> Bool` function, go to the line that says `Appacitive.registerAPIKey("YOUR_APIKEY_GOES_HERE", useLiveEnvironment: false);` and replace the YOUR_APIKEY_GOES_HERE with you note app's API Key.

This will register this app for making calls to Appacitive to send and recieve the data to and from your Appacitive model.

The below two lines will enable logging of network request for the sake of debugging and troubleshooting.

```swift
APLogger.sharedLogger();
APLogger.sharedLogger().enableVerboseMode(true);
```

####2. IMPLEMENTING LOGIN
Now open the __LoginViewController.swift__ file. In the `@IBAction func buttonTapped(sender: AnyObject)` method you will we either login or sig up the user to our app based on the button he presses. 

If he presses the login button, we make the following call to Appacitive to login the user.

```swift
APUser.authenticateUserWithUsername(emailField.text, password: passwordField.text, sessionExpiresAfter: nil, limitAPICallsTo: nil, successHandler: { (user: APUser!) -> Void in
    self.performSegueWithIdentifier("showList", sender: nil);
    self.progressHUD.removeFromSuperview();
}, failureHandler: { (error: APError!) -> Void in
    var alert = UIAlertController(title: "Login", message: "Failed", preferredStyle: UIAlertControllerStyle.Alert);
    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil));
    self.progressHUD.removeFromSuperview();
    self.presentViewController(alert, animated: true, completion: nil);
});
```

If the user presses the ign-up button, we make the following call to Appacitive to create a new user with the details he provides.

```swift
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
```

####3. IMPLEMENTING THE NOTES TABLE VIEW

Open the __NotesListTableViewController.swift__ file. In the `viewDidAppear(animated: Bool)` function, we fetch all the existing notes of the currently logged in user using the following code:

```swift
APConnections.fetchObjectsConnectedToObjectOfType("user", withObjectId: (APUser.currentUser().objectId), withRelationType: "owns", fetchConnections: false, successHandler:{ (objects: Array!) -> Void in
for object:AnyObject in objects {
    self.notes.addObject((object as APGraphNode).object);
            }
self.tableView.reloadData();
self.progressHUD.removeFromSuperview();
});
```

In the `tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath?) -> UITableViewCell?` function, the following line wii set the _title_ of the note as the _titleLabel_ of the `UITableViewCell`.

```swift
(cell as UITableViewCell).textLabel.text = ((notes[(indexPath as NSIndexPath).row] as APObject).getPropertyWithKey("title") as String);
```

In the `tableView(tableView: UITableView?, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath?)` function, we delete the note from Appacitive when a user deletes the note from the `UITableView`.

```swift
(self.notes.objectAtIndex((indexPath as NSIndexPath).row) as APObject).deleteObjectWithConnectingConnectionsSuccessHandler({ () -> Void in                    	self.notes.removeObjectAtIndex((indexPath as 	NSIndexPath).row);
	self.tableView.reloadData();
},failureHandler: { (error:APError!) -> Void in
    NSLog("error:%@",error.description);
});
```

####4. IMPLEMENTING THE NOTE EDITOR/DISPLAY VIEW.

Open the `NoteViewController.swift` file. In the `@IBAction func savebuttonTapped()` function, we save/update the note using the following code.

```swift
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
```

This demonstrates how you can use the existing Appacitive-iOS-SDK written in Objective-C in your swift app.

<img alt="screenshot" src="http://devcenter.appacitive.com/ios/samples/notekeeper/sss1.png" style="width:25%; padding: 1%; float:left;">

<img alt="screenshot" src="http://devcenter.appacitive.com/ios/samples/notekeeper/sss2.png" style="width:25%; padding: 1%; float:left;">

<img alt="screenshot" src="http://devcenter.appacitive.com/ios/samples/notekeeper/sss3.png" style="width:25%; padding: 1%; float:left">

<img alt="screenshot" src="http://devcenter.appacitive.com/ios/samples/notekeeper/sss4.png" style="width:25%; padding: 1%;">