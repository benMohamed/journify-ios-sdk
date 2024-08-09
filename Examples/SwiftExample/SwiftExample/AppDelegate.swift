//
//  AppDelegate.swift
//  SwiftExample
//
//  Created by Mohammed on 2/7/23.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // Create a new window instance and make it the key window
        window = UIWindow(frame: UIScreen.main.bounds)
        
        // Set the initial view controller
        let initialViewController = WriteKeyVC() // Replace with your initial view controller
        
        // Embed in a navigation controller if needed
        let navigationController = UINavigationController(rootViewController: initialViewController)
        
        // Set the root view controller and make the window visible
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        return true
    }


}

