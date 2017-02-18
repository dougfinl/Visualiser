//
//  AppDelegate.swift
//  Visualiser
//
//  Created by Douglas Finlay on 29/12/2016.
//  Copyright © 2016 Douglas Finlay. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }
    
    func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
        return true
    }

}
