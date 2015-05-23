//
//  InterfaceController.swift
//  WatchKitCoreData WatchKit Extension
//
//  Created by Ben Chatelain on 5/14/15.
//  Copyright (c) 2015 Ben Chatelain. All rights reserved.
//

import CoreData
import Foundation
import WatchKit
import WatchKitCoreDataFramework

@objc
class InterfaceController: WKInterfaceController, DataConsumer {

    @IBOutlet weak var counterLabel: WKInterfaceLabel?

    var dataController: DataController?
    var timer: Timer?

    let notificationController = NotificationController(send: .Watch)

    // MARK: - NSObject

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override init() {
        super.init()

//        NSNotificationCenter.defaultCenter().addObserver(self,
//            selector: Selector("contextChanged:"),
//            name: NSManagedObjectContextDidSaveNotification,
//            object: nil)

        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: Selector("contextChanged:"),
            name: "ContextChanged",
            object: nil)
    }

    // MARK: - WKInterfaceController

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)

        println(NSHomeDirectory())

        counterLabel?.setText("-1")
        dataController = AppGroupDataController() {
            [unowned self] () -> Void in

            self.timer = Timer(context: self.dataController!.mainContext)

            if let objects = self.fetchedResultsController.fetchedObjects as? [Counter],
            let counter = objects.first {
                self.counterLabel?.setText("\(counter.count)")
            }
        }
    }

    /// This method is called when watch view controller is about to be visible to user
    override func willActivate() {
        super.willActivate()
    }

    /// This method is called when watch view controller is no longer visible
    override func didDeactivate() {
        super.didDeactivate()
    }

    // MARK: - Data

    private lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Counter")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "count", ascending: false)]
        fetchRequest.fetchBatchSize = 1

        let context = self.dataController?.mainContext
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: context!,
            sectionNameKeyPath: nil,
            cacheName: nil)

        var error: NSError?
        if !controller.performFetch(&error) {
            println("Error fetching \(error)")
        }
        controller.delegate = self.fetchedResultsControllerDelegate

        return controller
    }()

    private lazy var fetchedResultsControllerDelegate: FetchedResultsControllerDelegate = {
        let delegate = FetchedResultsControllerDelegate()
        delegate.onUpdate = {
            [weak self] (object: AnyObject) in
            println("onUpdate")
            if let counter = object as? Counter {
                self?.counterLabel?.setText("\(counter.count)")
            }
        }
        return delegate
    }()

    // MARK: - Notification Handler

    @objc func contextChanged(notification: NSNotification) {
        println("contextChanged:")
    }

    // MARK: - IBActions

    @IBAction func start() {
        timer?.start()
    }

    @IBAction func stop() {
        timer?.stop()
    }

    @IBAction func reset() {
        timer?.reset()
    }

}
