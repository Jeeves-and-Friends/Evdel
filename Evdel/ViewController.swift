//
//  DiffViewController.swift
//  Evdel
//
//  Created by Sash Zats on 6/20/15.
//  Copyright © 2015 Sash Zats. All rights reserved.
//

import Cocoa
import EvdelKit

class DiffViewController: NSViewController {
    
    let DiffAttachmentAttributeName = "DiffAttachmentAttributeName"
    
    @IBOutlet var textView: NSTextView!
    @IBOutlet weak var textScrollView: NSScrollView!

    let diffService: Differ = Differ()
    
    var fileMode: [Diff.DiffType] = [.Insertion, .None, .Deletion] {
        didSet {
            reloadDiff()
        }
    }
    
    var diffPaths: [String]?

    override func viewDidLoad() {
        super.viewDidLoad()

        if FileOpeningService.sharedInstance.deferredPaths != nil {
            diffPaths = FileOpeningService.sharedInstance.deferredPaths!
            log("Opening files from the service")
        } else {
            
            let arguments = NSProcessInfo.processInfo().arguments
            if arguments.count < 3 {
                return
            }
            log("Opening files from command line arguments: \(arguments)")
            diffPaths = pathsFromArguments(arguments)
        }
        log("Paths: \(diffPaths)")
        
        reloadDiff()
        
        //setup notifications
        FileOpeningService.sharedInstance.openHandler = openFileHandler
    }
    
    // MARK: - Public 
    
    func openDiff(leftPath leftPath: String, rightPath: String) {
        if let diffs = diffsForFilePair(leftPath: leftPath, rightPath: rightPath) {
            displayDiffs(diffs, allowedOperations: fileMode)
        }
    }
    
    
    // MARK: - Handlers

    func openFileHandler(service: FileOpeningService) {
        if let paths = service.deferredPaths where paths.count == 2 {
            openDiff(leftPath: paths[0], rightPath: paths[1])
        }
    }
    
    // MARK: - Private    
    
    private func reloadDiff() {
        if let diffPaths = diffPaths where diffPaths.count == 2 {
            openDiff(leftPath: diffPaths[0], rightPath: diffPaths[1])
        }
    }
    
    private func displayDiffs(diffs: [Diff], allowedOperations: [Diff.DiffType]) {
        let attributedString = NSMutableAttributedString()
        for diff in diffs {
            if allowedOperations.contains({ $0 == diff.type }) {
                attributedString.appendAttributedString(attributedStringForDiff(diff))
            }
        }

        let globalAttributes = [
            NSFontAttributeName: textView.font!,
            NSForegroundColorAttributeName: NSColor.grayColor()
        ]
        let range = NSRange(location:0, length: attributedString.length)
        attributedString.addAttributes(globalAttributes, range: range)
        textView.textStorage?.setAttributedString(attributedString)
    }
    
    private func attributedStringForDiff(diff: Diff) -> NSAttributedString {
        var attributes: [String: AnyObject] = [DiffAttachmentAttributeName: DiffObject(diff: diff)]
        switch diff.type {
        case .Insertion:
            attributes[NSBackgroundColorAttributeName] = NSColor(calibratedRed:0.86, green:0.959, blue:0.807, alpha:1)
        case .Deletion:
            attributes[NSBackgroundColorAttributeName] = NSColor(calibratedRed:0.999, green:0.878, blue:0.856, alpha:1)
        default:
            break
        }
        return NSAttributedString(string: diff.text, attributes: attributes)
    }
    
    private func diffsForFilePair(leftPath leftPath: String, rightPath: String) -> [Diff]? {
        guard let left = string(path: leftPath), right = string(path: rightPath) else {
            return nil
        }
        return diffService.diff(left: left, right: right)
    }
    
    private func pathsFromArguments(arguments: [String]) -> [String]? {
        if arguments.count < 3 {
            return nil
        }

        if let left = reachablePathForPath(arguments[1], pwd: arguments[3]),
               right = reachablePathForPath(arguments[2], pwd: arguments[3]) {
            return [left, right]
        }
        return nil
    }
    
    private func reachablePathForPath(path: String, pwd: String?) -> String? {
        let manager = NSFileManager.defaultManager()
        if manager.fileExistsAtPath(path) {
            return path
        }
        guard let pwd = pwd else {
            return nil
        }
        let result = pwd + path
        if manager.fileExistsAtPath(result) {
            return result
        }
        return nil
    }
    
    private func string(path path: String) -> String? {
        let manager = NSFileManager.defaultManager()
        var isDirectory: ObjCBool = false
        if !manager.fileExistsAtPath(path, isDirectory: &isDirectory) || isDirectory {
            log("File does not exist at \(path)")
            return nil
        }
        do {
            return try String(contentsOfFile: path, encoding: NSUTF8StringEncoding)
        } catch (let e) {
            log("Failed to read the string from \(path): \(e)")
            return nil
        }
    }

}

extension DiffViewController {

    @IBAction func makeTextSmaller(sender: AnyObject) {
//        textView.makeFontSmaller()
    }
    
    @IBAction func makeTextLarger(sender: AnyObject) {
//        textView.makeFontLarger()
    }

    @IBAction func toggleWordWrap(sender: NSMenuItem) {
        let wordWrappingEnabled = sender.state == NSOffState
        sender.state = wordWrappingEnabled ? NSOnState : NSOffState
//        textView.lineBreakMode = wordWrappingEnabled ? NSLineBreakMode.ByWordWrapping : NSLineBreakMode.ByClipping
    }
}
