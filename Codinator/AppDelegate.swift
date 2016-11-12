//
//  AppDelegate.swift
//  Codinator
//
//  Created by Vladimir Danila on 03/07/2016.
//  Copyright © 2016 Vladimir Danila. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics


@UIApplicationMain
class AppDelegate: UIResponder , UIApplicationDelegate, FileManagerDelegate {

    var window: UIWindow?
    let fileManager = FileManager.default

    class var storageURL: URL {
        get {

            func createResources(at homeURL: URL) {
                let playgroundsURL =  homeURL.appendingPathComponent("Playgrounds")
                let projectsURL = homeURL.appendingPathComponent("Projects")

                print("Project: \(try? projectsURL.checkResourceIsReachable()),Playground: \(try? playgroundsURL.checkResourceIsReachable())")

                let needsResources = try? projectsURL.checkResourceIsReachable() || playgroundsURL.checkResourceIsReachable()
                if needsResources != nil && needsResources! {
                    let fileManager = FileManager.default
                    try? fileManager.createDirectory(at: playgroundsURL, withIntermediateDirectories: true, attributes: nil)
                    try? fileManager.createDirectory(at: projectsURL, withIntermediateDirectories: true, attributes: nil)
                }
            }

            let rootDirectory = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents")

            if rootDirectory != nil && UserDefaults.standard.bool(forKey: "CnCloud") == true {
                createResources(at: rootDirectory!)
                return rootDirectory!
            }



            let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
            let homeURL = URL(fileURLWithPath: documentDirectory!, isDirectory: true)
            createResources(at: homeURL)


            return homeURL
        }
    }


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {

        Fabric.with([Crashlytics.self])

        // TODO: - Evaluate if this process is really required

        // Create FileSystem
        let path = (NSHomeDirectory() as NSString).appendingPathComponent("Documents")
        let url = URL(fileURLWithPath: path, isDirectory: true)

        let queue = DispatchQueue.global(qos: .background)
        queue.async {
            do {
                let playgroundsURL = url.appendingPathComponent("Playgrounds")
                let projectsURL = url.appendingPathComponent("Projects")


                try self.fileManager.createDirectory(at: playgroundsURL, withIntermediateDirectories: true, attributes: nil)
                try self.fileManager.createDirectory(at: projectsURL, withIntermediateDirectories: true, attributes: nil)

                guard let rootDirectory = self.fileManager.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents") else {
                    return
                }


                try self.fileManager.setUbiquitous(true, itemAt: playgroundsURL, destinationURL: rootDirectory.appendingPathComponent("Playgrounds"))
                try self.fileManager.setUbiquitous(true, itemAt: projectsURL, destinationURL: rootDirectory.appendingPathComponent("Projects"))

            } catch {}
        }


        return true


    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return self.moveImported(filename: url.lastPathComponent, at: url)
    }


    // MARK: - Hand off

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {

        let navController = self.window?.rootViewController as! UINavigationController
        let welcomeViewController = navController.viewControllers.first as! WelcomeViewController

        welcomeViewController.restoreUserActivityState(userActivity)

        return true
    }


    // MARK: - File imports

    func moveImported(filename: String, at url: URL) -> Bool {

        // Get storage path
        let storagePath = AppDelegate.storageURL.path

        // Check if dir exists
        if fileManager.fileExists(atPath: storagePath) {

            // Move file to location
            do {
                try fileManager.moveItem(at: url, to: URL(fileURLWithPath: storagePath, isDirectory: true).appendingPathComponent(filename))

                let navController = self.window?.rootViewController as! UINavigationController
                let welcomeViewController = navController.viewControllers.first as! WelcomeViewController

                welcomeViewController.reloadData()

            } catch {
                print("error: \(error)")
            }


        }

        return false
    }

    
}
