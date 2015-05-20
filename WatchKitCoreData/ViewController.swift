//
//  ViewController.swift
//  WatchKitCoreData
//
//  Created by Ben Chatelain on 5/14/15.
//  Copyright (c) 2015 Ben Chatelain. All rights reserved.
//

import CoreData
import UIKit
import WatchKitCoreDataFramework

@objc
class ViewController: UIViewController, DataConsumer {

    @IBOutlet weak var counterLabel: UILabel?

    var dataController: DataController?
    var timer: Timer?

    // MARK: - NSObject

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: Selector("contextChanged:"),
            name: NSManagedObjectContextDidSaveNotification,
            object: nil)
    }

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        counterLabel?.text = "-1"
        self.timer = Timer(context: self.dataController!.mainContext)

        if let objects = fetchedResultsController.fetchedObjects as? [Counter],
        let counter = objects.first {
            counterLabel?.text = "\(counter.count)"
        }
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
                self?.counterLabel?.text = "\(counter.count)"
            }
        }
        return delegate
    }()

    // MARK: - Notification Handler

    @objc func contextChanged(notification: NSNotification) {
        println("contextChanged:")
    }

    // MARK: - IBActions

    @IBAction func showActionMenu(sender: AnyObject) {
        let menu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        menu.addAction(UIAlertAction(title: "Start", style: UIAlertActionStyle.Default,
            handler: { (alert: UIAlertAction!) in self.start() }))
        menu.addAction(UIAlertAction(title: "Stop", style: UIAlertActionStyle.Default,
            handler: { (alert: UIAlertAction!) in self.stop() }))
        menu.addAction(UIAlertAction(title: "Reset", style: UIAlertActionStyle.Destructive,
            handler: { (alert: UIAlertAction!) in self.reset() }))
        menu.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))

        presentViewController(menu, animated: true, completion: nil)
    }

    func start() {
        timer?.start()
    }

    func stop() {
        timer?.stop()
    }

    func reset() {
        timer?.reset()
    }

}

