//
//  AppDelegate.swift
//  Evdel
//
//  Created by Sash Zats on 6/20/15.
//  Copyright © 2015 Sash Zats. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        NSApp.activateIgnoringOtherApps(true)
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        return true
    }
}

