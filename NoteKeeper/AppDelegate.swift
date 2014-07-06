//
//  AppDelegate.swift
//  NoteKeeper
//
//  Created by Pratik on 03-07-14.
//  Copyright (c) 2014 Appacitive Software. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: NSDictionary?) -> Bool {
        Appacitive.registerAPIKey("YOUR_APIKEY_GOES_HERE", useLiveEnvironment: false);
        APLogger.sharedLogger();
        APLogger.sharedLogger().enableVerboseMode(true);
        return true
    }
}

