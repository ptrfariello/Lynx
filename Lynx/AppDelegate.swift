//
//  AppDelegate.swift
//  Lynx
//
//  Created by Pietro on 04/05/22.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let (markers, _) = getMarkersRoutes(points: sharedData.shared.points)
        createLocations(markers: markers)
        sharedData.shared.updateLocationPhotos(all: true)
        sharedData.shared.updateLocationNames()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    

    
    
    func applicationWillResignActive(_ application: UIApplication) {
      
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        Storage.store(sharedData.shared.locations, to: .caches, as: Constants.shared.locations_filename)
        print("Locations Saved")
    }
    
    
}
