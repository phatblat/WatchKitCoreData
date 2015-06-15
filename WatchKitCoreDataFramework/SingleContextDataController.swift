//
//  SingleContextDataController.swift
//  WatchKitCoreData
//
//  Created by Ben Chatelain on 5/14/15.
//  Copyright (c) 2015 Ben Chatelain. All rights reserved.
//

import CoreData

public class SingleContextDataController: DataController {

    public let mainContext: NSManagedObjectContext

    private let initCallback: InitCallback?
    private let dataStore = "DataStore.sqlite"
    private let dataModel = "WatchKitCoreData.momd"

    // MARK: - Public

    /// Initializes a new instance, spinning off the store setup to a background
    /// queue.
    ///
    /// - parameter callback: An InitCallBack to be called once the Core Data stack
    ///                  is done being stood up. Called on the main queue.
    ///
    /// - returns: an initialized DataController
    public required init(callback: InitCallback?) {
        initCallback = callback

        // Non-optional properties must be initialized in init, before any other calls
        mainContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        mainContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy;

        initializeCoreData()
    }

    convenience init() {
        self.init(callback: nil)
    }

    /// Saves changes from the mainContext down to the persistent store. This is
    /// done synchronously on the calling queue.
    public func save() {
        if !mainContext.hasChanges {
            // Nothing to save
            return
        }

        mainContext.performBlockAndWait() {
            [unowned self] () -> Void in

            do {
                try self.mainContext.save()
            } catch {
                print("Error saving mainContext: \(error)")
                return
            }
        }
    }

    /// Provides the URL to the folder where the persistent store is expected to reside.
    /// Subclasses may override to point wherever desired.
    public func dataStoreDirectory() -> NSURL {
        // App documents directory
        return NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last!
    }

    // MARK: - Private

    /// http://martiancraft.com/blog/2015/03/core-data-stack/
    private func initializeCoreData() {
        if let modelURL = NSBundle(forClass: self.dynamicType).URLForResource(dataModel.stringByDeletingPathExtension, withExtension: dataModel.pathExtension),
        let mom = NSManagedObjectModel(contentsOfURL: modelURL) {
            print("modelURL: \(modelURL)")

            let coordinator = NSPersistentStoreCoordinator(managedObjectModel: mom)
            mainContext.persistentStoreCoordinator = coordinator

            // Stand up the store in the background to avoid blocking the main queue
            let priority = DISPATCH_QUEUE_PRIORITY_BACKGROUND
            dispatch_async(dispatch_get_global_queue(priority, 0)) {
                [unowned self, unowned coordinator] in

                let options: [NSObject : AnyObject] = [
                    NSMigratePersistentStoresAutomaticallyOption: true,
                    NSInferMappingModelAutomaticallyOption: true,

                    // Use WAL mode to prevent getting jetsam'd
                    // https://developer.apple.com/library/ios/technotes/tn2408/_index.html
                    NSSQLitePragmasOption: ["journal_mode": "DELETE"]
                ]

                let storeURL = self.dataStoreDirectory().URLByAppendingPathComponent(self.dataStore)
                print("storeURL: \(storeURL)")

                do {
                    try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: options)
                    if let callback = self.initCallback {
                        // Call the callback on the main queue
                        dispatch_sync(dispatch_get_main_queue()) {
                            callback()
                        }
                    }
                } catch {
                    print("Error standing up store: \(error)")
#if DEBUG
                        // Blow away store
                        do {
                            try! NSFileManager.defaultManager().removeItemAtPath(storeURL.path!)
                        }

                    // Try again
                    try! coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: options)

                    if let callback = self.initCallback {
                        // Call the callback on the main queue
                        dispatch_sync(dispatch_get_main_queue()) {
                            callback()
                        }
                    }
#endif
                }
            }
        }
        else {
            print("Unable to locate \(dataModel) in bundle")
        }
    }

}

