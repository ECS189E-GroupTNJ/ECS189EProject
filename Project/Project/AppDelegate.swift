//
//  AppDelegate.swift
//  Project
//
//  Created by user147183 on 11/21/18.
//  Copyright © 2018 groupTNJ. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: SPTSessionManagerDelegate, SPTAppRemoteDelegate {

    let SpotifyClientID = "ourSpotifyClientID"
    let SpotifyRedirectURL = URL(string: ":ourRedirectURL")!
    //setupConfig
    lazy var configuration: SPTConfiguration = {
    let configuration = SPTConfiguration(clientID: SpotifyClientID, redirectURL: SpotifyRedirectURL)
    configuration.playURI = ""
    configuration.tokenSwapURL = URL(string: "https://yourapp.herokuapp.com/api/token")
    configuration.tokenRefreshURL = URL(string: "https://yourapp.herokuapp.com/api/refresh_token")
    
    return configuration
    }()
    //set up sessionManager
    lazy var sessionManager: SPTSessionManager = {
    let sessionManager = SPTSessionManager(configuration: configuration, delegate: self)
    return sessionManager
    }()
    //set up appRemote
    lazy var appRemote:SPTAppRemote = {
    let appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
    appRemote.delegate = self
    return appRemote
    }()
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    //////////////////////
    //////////////////////
    ////DELEGATE STUBS////
    //////////////////////
    //////////////////////
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
    print("connected successfully")
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
    print("failed to connect")
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
    print("ran into erro: disconnected")
    }
    
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
    print("player state changed")
    }
    
    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
    appRemote.connectionParameters.accessToken = session.accessToken
    appRemote.connect()
    }
    
    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
    print("session failed to initiate")
    }
    
    private func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    self.sessionManager.application(app, open: url, options: options)
    return true
    }
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        if self.appRemote.isConnected {
            self.appRemote.disconnect()
        }
        
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    //when app becomes active again connect to app remote
    func applicationDidBecomeActive(_ application: UIApplication) {
        if let _ = self.appRemote.connectionParameters.accessToken {
            self.appRemote.connect()
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Project")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }


}

