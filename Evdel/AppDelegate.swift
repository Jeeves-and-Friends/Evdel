//
//  AppDelegate.swift
//  Evdel
//
//  Created by Sash Zats on 6/20/15.
//  Copyright © 2015 Sash Zats. All rights reserved.
//

import Cocoa
import Fabric
import Crashlytics
import ParseOSX
import Bolts

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var viewMenu: NSMenuItem! {
        didSet {
        }
    }
    
    func applicationWillBecomeActive(notification: NSNotification) {

    }
    
    func applicationShouldHandleReopen(sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        return true
    }

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        Fabric.with([Crashlytics()])
        Parse.setApplicationId("MIElOdZDocDFoVGmT4eNiQSIYhRyPklAuPOiVNqo", clientKey:"I9WrcpwyCUcwpCX6FNWPqZxHUqtxgKKOqJHUiiSV")

        NSApp.activateIgnoringOtherApps(true)
        setMenuReference()
        
        PFAnalytics.trackAppOpenedWithLaunchOptions(nil)
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        return true
    }
    
    func application(sender: NSApplication, openFiles filenames: [AnyObject]) {
        if let filenames = filenames as? [String] {
            if filenames.count != 2 {
                NSApp.replyToOpenOrPrint(.Failure)
                return
            }
            FileOpeningService.sharedInstance.deferredPaths = filenames
            NSApp.replyToOpenOrPrint(.Success)
        } else {
            NSApp.replyToOpenOrPrint(.Failure)
        }
    }
        
    private func setMenuReference() {
        if let window = NSApplication.sharedApplication().windows.first as? NSWindow {
            if let controller = window.windowController() as? WindowController {
                controller.viewMenu = viewMenu
            }
        }
    }
}

