//
//  AppDelegate.swift
//  Pulse
//
//  Created by Bianca Curutan on 11/4/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import UIKit
import Parse

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
        Parse.initialize(with:
			ParseClientConfiguration(block: { (configuration:ParseMutableClientConfiguration) -> Void in
				configuration.applicationId = "pulseAleBiancaIta"
				configuration.clientKey = nil  // set to nil assuming you have not set clientKey
				configuration.server = "https://pu1se.herokuapp.com/parse"
			})
		)
        
        // For testing only - take out after implementing Logout
        //PFUser.logOut()
        
        // Check if there's a current user, take them straight to dashboard
        let currentUser = PFUser.current()
        debugPrint("in app delegate, current user is \(currentUser)")

        // THIS IS THE REAL ONE
        if currentUser != nil {
            let storyboard = UIStoryboard.init(name: "Dashboard", bundle: nil)
            let dashboardNavVC = storyboard.instantiateViewController(withIdentifier: StoryboardID.dashboardNavVC)
            self.window?.rootViewController = dashboardNavVC
            debugPrint("current user inside the appDelegate \(currentUser)")
        }

//        // For testing Todo only
//        if currentUser != nil {
//            let storyboard = UIStoryboard.init(name: "Todo", bundle: nil)
//            let todoVC = storyboard.instantiateViewController(withIdentifier: StoryboardID.todoVC)
//            self.window?.rootViewController = todoVC
//        } // else - Login view is already set up as initial vc so we don't have to do anything
//        
        // Enable automatic user
        //PFUser.enableAutomaticUser()
        //let defaultACL = PFACL()
        //PFACL.setDefault(defaultACL, withAccessForCurrentUser: true)
        
        // Print out what's currently in current user
        if let currentUser = PFUser.current() {
            debugPrint("after enableAutomaticUser, currentUser is \(currentUser)")
        }
                
//        let loginSignUpVC = LoginSignUpViewController(nibName: "LoginSignUpViewController", bundle: nil)
//        self.window?.rootViewController = loginSignUpVC
        
        // Customize UI
        UIApplication.shared.statusBarStyle = .lightContent
        let navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.tintColor = UIColor.pulseTintColor()
        navigationBarAppearance.barTintColor = UIColor.pulseBarTintColor()
        navigationBarAppearance.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.pulseTintColor()]

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

