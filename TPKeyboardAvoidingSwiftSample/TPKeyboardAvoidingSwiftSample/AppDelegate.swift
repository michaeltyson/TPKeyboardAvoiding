//
//  AppDelegate.swift
//  TPKeyboardAvoidingSwiftSample
//
//  Created by Manuele Mion on 25/02/15.
//  Copyright (c) 2015 TPKeyboardAvoiding. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var tabBarController: UITabBarController?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        self.window?.rootViewController = self.tabBarController;
        self.window?.makeKeyAndVisible();
        
        return true
    }

}

