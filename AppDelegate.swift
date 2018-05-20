//
//  AppDelegate.swift
//  VirtualTourist
//
//  Created by Max Boguslavskiy on 02/05/2018.
//  Copyright © 2018 Max Boguslavskiy. All rights reserved.
//

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var locationManager: CLLocationManager?
    let dataController = DataController(modelName: "VirtualTourist")

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions:
        [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        dataController.load()

        let navigationController = window?.rootViewController as! UINavigationController
        let travelLocationsViewController = navigationController.topViewController as! TravelLocationsMapViewController
        travelLocationsViewController.dataController = dataController

        locationManager = CLLocationManager()
        locationManager?.requestWhenInUseAuthorization()

        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        saveViewContext()
    }

    func saveViewContext() {
        try? dataController.viewContext.save()
    }

}
