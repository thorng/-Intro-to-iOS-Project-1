//
//  AppDelegate.swift
//  MovieViewer
//
//  Created by Timothy Horng on 1/18/16.
//  Copyright © 2016 Timothy Horng. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        // Programmatically make
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let nowPlayingNavigationController = storyboard.instantiateViewControllerWithIdentifier("MoviesNavigationController") as! UINavigationController
        let nowPlayingViewController = nowPlayingNavigationController.topViewController as! MoviesViewController
        nowPlayingViewController.endpoint = "now_playing" // set endpoint variable
        nowPlayingNavigationController.tabBarItem.title = "Now Playing" // add title, image
        nowPlayingNavigationController.tabBarItem.image = UIImage(named: "Movie-50")
        nowPlayingNavigationController.tabBarItem.image = imageWithImage(nowPlayingNavigationController.tabBarItem.image!, scaledToSize: CGSizeMake(30, 30)) // scale image down
        
        let topRatedNavigationController = storyboard.instantiateViewControllerWithIdentifier("MoviesNavigationController") as! UINavigationController
        let topRatedViewController = topRatedNavigationController.topViewController as! MoviesViewController
        topRatedViewController.endpoint = "top_rated"
        topRatedNavigationController.tabBarItem.title = "Top Rated"
        topRatedNavigationController.tabBarItem.image = UIImage(named: "Popcorn Maker-50")
        topRatedNavigationController.tabBarItem.image = imageWithImage(topRatedNavigationController.tabBarItem.image!, scaledToSize: CGSizeMake(30, 30)) // scale image down

        // instantiate tab bar controller
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [nowPlayingNavigationController, topRatedNavigationController]
        
        // initial view controller
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        
        let colorView = UIView()
        colorView.backgroundColor = UIColor(hue: 0.3, saturation: 1, brightness: 0.57, alpha: 1.0) /* #1d9100 */
        
        // use UITableViewCell.appearance() to configure
        // the default appearance of all UITableViewCells in your app
        UITableViewCell.appearance().selectedBackgroundView = colorView
        
        return true
    }
    
    // to scale tab bar images
    func imageWithImage(image: UIImage, scaledToSize: CGSize) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(scaledToSize, false, 0.0)
        let newRect = CGRectMake(0, 0, scaledToSize.width, scaledToSize.height)
        image.drawInRect(newRect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        return newImage
        
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

