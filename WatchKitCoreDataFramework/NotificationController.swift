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

        NotificationController.registerForDarwinNotificationsWithIdentifier(listenIdentifier, forwardUsingIdentifier: "ContextChanged")
    }

    // MARK: - Notification Handler

    @objc func contextChanged(notification: NSNotification) {
        print("Sending darwin notification: \(broadcastIdentifier.rawValue)")
        NotificationController.sendDarwinNotificationWithIdentifier(broadcastIdentifier.rawValue)
    }

    // MARK: - Darwin Notifications

    public class func sendDarwinNotificationWithIdentifier(identifier: String) {
        let center = CFNotificationCenterGetDarwinNotifyCenter()
        let deliverImmediately = CFBooleanGetValue(true)
        CFNotificationCenterPostNotification(center, identifier, nil, nil, deliverImmediately)
    }

/// Callback function to convert a Darwin notification (interprocess) into a local NSNotification.
//    typealias CFNotificationCallback = CFunctionPointer<((CFNotificationCenter!, UnsafeMutablePointer<Void>, CFString!, UnsafePointer<Void>, CFDictionary!) -> Void)>
    public class func darwinNotificationCallback(center: CFNotificationCenter!, observer: UnsafeMutablePointer<Void>, name: CFString!, object: UnsafePointer<Void>, userInfo: CFDictionary!) -> Void {
        let identifier = name as NSString
        NSNotificationCenter.defaultCenter().postNotificationName("", object: nil,
            userInfo:["identifier": identifier])
    }

    public class func registerForDarwinNotificationsWithIdentifier(listenIdentifier: ChangeIdentifier, forwardUsingIdentifier localIdentifier: String) {

        let center = CFNotificationCenterGetDarwinNotifyCenter()

        /*
        func CFNotificationCenterAddObserver(_ center: CFNotificationCenter!,
        _ observer: UnsafePointer<Void>,
        _ callBack: CFNotificationCallback,
        _ name: CFString!,
        _ object: UnsafePointer<Void>,
        _ suspensionBehavior: CFNotificationSuspensionBehavior)
        */

        switch (listenIdentifier) {
        case .Phone:
            CFNotificationCenterAddObserver(center,
                nil,
                { _ in
                    // Duplication intentional, since C closures can't capture values
                    let identifier = "PhoneContextChanged"
                    print("Callback called \(identifier)")
                    NSNotificationCenter.defaultCenter().postNotificationName(identifier, object: nil,
                        userInfo: nil)
                },
                listenIdentifier.rawValue,
                nil,
                CFNotificationSuspensionBehavior.DeliverImmediately)
        case .Watch:
            CFNotificationCenterAddObserver(center,
                nil,
                { _ in
                    // Duplication intentional, since C closures can't capture values
                    let identifier = "WatchContextChanged"
                    print("Callback called \(identifier)")
                    NSNotificationCenter.defaultCenter().postNotificationName(identifier, object: nil,
                        userInfo: nil)
                },
                listenIdentifier.rawValue,
                nil,
                CFNotificationSuspensionBehavior.DeliverImmediately)
        }
    }

}
