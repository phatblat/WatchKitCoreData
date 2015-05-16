//
//  DualContextDataController.swift
//  WatchKitCoreData
//
//  Created by Ben Chatelain on 4/17/15.
//  Copyright (c) 2015 Ben Chatelain. All rights reserved.
//

import CoreData


public class DualContextDataController: DataController {

    public let mainContext: NSManagedObjectContext
    private let privateContext: NSManagedObjectContext

    private let initCallback: InitCallback?
    private let dataStore = "DataStore.sqlite"
    private let dataModel = "WatchKitCoreData.momd"

    // MARK: - Public

    /// Initializes a new instance, spinning off the store setup to a background
    /// queue.
    ///
    /// :param: callback An InitCallBack to be called once the Core Data stack
    ///                  is done being stood up. Called on the main queue.
    ///
    /// :returns: an initialized DataController
    public required init(callback: InitCallback?) {
        initCallback = callback

        // Non-optional properties must be initialized in init, before any other calls
        mainContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        privateContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)

        initializeCoreData()
    }

    convenience init() {
        self.init(callback: nil)
    }

    public func save() {
        if !privateContext.hasChanges && !mainContext.hasChanges {
            // Nothing to save
            return
        }

        mainContext.performBlockAndWait() {
            [unowned self] () -> Void in

            var error: NSError? = nil
            if !self.mainContext.save(&error) {
                println("Error saving mainContext: \(error)")
                return
            }

            self.privateContext.performBlock { () -> Void in
                var privateError: NSError? = nil
                if !self.privateContext.save(&privateError) {
                    println("Error saving privateContext: \(privateError)")
                }
            }
        }
    }

    public func dataStoreDirectory() -> NSURL {
        // App documents directory
        return NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last as! NSURL
    }

    // MARK: - Private

    /// http://martiancraft.com/blog/2015/03/core-data-stack/
    private func initializeCoreData() {
        if let modelURL = NSBundle(forClass: self.dynamicType).URLForResource(dataModel.stringByDeletingPathExtension, withExtension: dataModel.pathExtension),
                let mom = NSManagedObjectModel(contentsOfURL: modelURL) {
            println("modelURL: \(modelURL)")

            let coordinator = NSPersistentStoreCoordinator(managedObjectModel: mom)

            privateContext.persistentStoreCoordinator = coordinator
            mainContext.parentContext = privateContext

            // Stand up the store in the background to avoid blocking the main queue
            let priority = DISPATCH_QUEUE_PRIORITY_BACKGROUND
            dispatch_async(dispatch_get_global_queue(priority, 0)) {
                [unowned self, unowned coordinator] in

                let options: [NSObject : AnyObject] = [
                    NSMigratePersistentStoresAutomaticallyOption: true,
                    NSInferMappingModelAutomaticallyOption: true,
                    NSSQLitePragmasOption: ["journal_mode": "DELETE"]
                ]

                if let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last as? NSURL {
                    let storeURL = documentsURL.URLByAppendingPathComponent(self.dataStore)
                    println("storeURL: \(storeURL)")

                    var error: NSError? = nil
                    if let store = coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: options, error: &error) {
                        if let callback = self.initCallback {
                            // Call the callback on the main queue
                            dispatch_sync(dispatch_get_main_queue()) {
                                callback()
                            }
                        }
                    }
                    else {
                        println("Error standing up store: \(error)")
#if DEBUG
                        // Blow away store
                        if !NSFileManager.defaultManager().removeItemAtPath(storeURL.path!, error: &error) {
                            println("Error removing store: \(error)")
                        }

                        // Try again
                        if let store = coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: options, error: &error),
                        let callback = self.initCallback {
                            // Call the callback on the main queue
                            dispatch_sync(dispatch_get_main_queue()) {
                                callback()
                            }
                        }
#endif
                    }
                }
            }
        }
        else {
            println("Unable to locate \(dataModel) in bundle")
        }

    }

}
