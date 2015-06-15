//
//  Timer.swift
//  WatchKitCoreData
//
//  Created by Ben Chatelain on 5/16/15.
//  Copyright (c) 2015 Ben Chatelain. All rights reserved.
//

import CoreData
import Foundation
import WatchKitCoreDataFramework

@objc
public class Timer: NSObject {

    let context: NSManagedObjectContext

    private var timer: NSTimer?
    private var counter: Counter?

    public init(context: NSManagedObjectContext) {
        self.context = context

        super.init()

        setup()
    }

    public func start() {
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
    }

    public func stop() {
        timer?.invalidate()
        timer = nil
    }

    public func reset() {
        counter?.count = 0
        save()
    }

    // MARK: - Internal

    func update() {
        print("update")
        counter?.count++
        save()
    }

    // MARK: - Private Methods

    private func setup() {
        let request = NSFetchRequest(entityName: "Counter")
        do {
            if let result = try! context.executeFetchRequest(request) as? [Counter] {
                if result.count < 1 {
                    insert()
                    return
                }
                // Save a reference
                self.counter = result.first
            }
            else {
                insert()
            }
        }
    }

    private func insert() {
        if let entity = NSEntityDescription.entityForName("Counter", inManagedObjectContext: context),
        let counter = NSManagedObject(entity: entity, insertIntoManagedObjectContext: context) as? Counter {
            counter.count = 0
            self.counter = counter
            save()
        }
    }

    private func save() {
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }

}

