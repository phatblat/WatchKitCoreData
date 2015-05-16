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

class ViewController: UIViewController {

    @IBOutlet weak var counterLabel: UILabel?

    var dataController: DataController?

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        counterLabel?.text = "-1"
        fetchedResultsController.delegate = fetchedResultsControllerDelegate
    }

    // MARK: - Data

    private lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Counter")
         fetchRequest.sortDescriptors = [NSSortDescriptor(key: "count", ascending: false)]

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

}

