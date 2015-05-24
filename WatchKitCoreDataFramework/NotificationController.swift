//
//  NotificationController.swift
//  WatchKitCoreData
//
//  Created by Ben Chatelain on 5/22/15.
//  Copyright (c) 2015 Ben Chatelain. All rights reserved.
//

import CoreData
import Foundation

public enum ChangeIdentifier: String {
    case Phone = "PhoneContextChanged"
    case Watch = "WatchContextChanged"
}

@objc
public class NotificationController: NSObject {

    let broadcastIdentifier: ChangeIdentifier
    let listenIdentifier: ChangeIdentifier

    // MARK: - NSObject

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    public init(send: ChangeIdentifier) {
        broadcastIdentifier = send
        switch (broadcastIdentifier) {
            case .Phone: listenIdentifier = .Watch
            case .Watch: listenIdentifier = .Phone
        }

        super.init()

        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: Selector("contextChanged:"),
            name: NSManagedObjectContextDidSaveNotification,
            object: nil)

        NotificationController.registerForDarwinNotificationsWithIdentifier(listenIdentifier.rawValue, forwardUsingIdentifier: "ContextChanged")
    }

    // MARK: - Notification Handler

    @objc func contextChanged(notification: NSNotification) {
        println("Sending darwin notification: \(broadcastIdentifier.rawValue)")
        NotificationController.sendDarwinNotificationWithIdentifier(broadcastIdentifier.rawValue)
    }

    // MARK: - Darwin Notifications

    public class func sendDarwinNotificationWithIdentifier(identifier: String) {
        let center = CFNotificationCenterGetDarwinNotifyCenter()
//        let object: UnsafePointer<Void> = nil
//        let userInfo: CFDictionary = [:]
        let deliverImmediately: Boolean = Boolean()
//        CFStringRef str = (__bridge CFStringRef)identifier
        CFNotificationCenterPostNotification(center, identifier as CFString, nil, nil, deliverImmediately)
    }

/// Callback function to convert a Darwin notification (interprocess) into a local NSNotification.
//    typealias CFNotificationCallback = CFunctionPointer<((CFNotificationCenter!, UnsafeMutablePointer<Void>, CFString!, UnsafePointer<Void>, CFDictionary!) -> Void)>
    public class func darwinNotificationCallback(center: CFNotificationCenter!, observer: UnsafeMutablePointer<Void>, name: CFString!, object: UnsafePointer<Void>, userInfo: CFDictionary!) -> Void {
        let identifier = name as NSString
        NSNotificationCenter.defaultCenter().postNotificationName("", object: nil,
            userInfo:["identifier": identifier])
    }

    public class func registerForDarwinNotificationsWithIdentifier(identifier: String, forwardUsingIdentifier localIdentifier: String) {

        let block: @objc_block
        (CFNotificationCenter!, UnsafeMutablePointer<Void>, CFString!, UnsafePointer<Void>, CFDictionary!) -> Void = {
            (center, observer, name, object, userInfo) in

            let identifier = name as NSString
            println("Callback called with identifier: \(identifier)")

            NSNotificationCenter.defaultCenter().postNotificationName(localIdentifier, object: nil,
                userInfo:["identifier": identifier])
        }

        let imp: COpaquePointer = imp_implementationWithBlock(unsafeBitCast(block, AnyObject.self))
        let callback: CFNotificationCallback = unsafeBitCast(imp, CFNotificationCallback.self)

        let center = CFNotificationCenterGetDarwinNotifyCenter()

        /*
        func CFNotificationCenterAddObserver(_ center: CFNotificationCenter!,
        _ observer: UnsafePointer<Void>,
        _ callBack: CFNotificationCallback,
        _ name: CFString!,
        _ object: UnsafePointer<Void>,
        _ suspensionBehavior: CFNotificationSuspensionBehavior)
        */

        CFNotificationCenterAddObserver(center,
            nil as UnsafePointer<Void>,
            callback,
            identifier as CFString!,
            nil as UnsafePointer<Void>,
            CFNotificationSuspensionBehavior.DeliverImmediately)
    }

}
