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
class Timer: NSObject {

    let context: NSManagedObjectContext

    private var timer: NSTimer?

    init(context: NSManagedObjectContext) {
        self.context = context

        super.init()

        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("update"), userInfo: nil, repeats: true)

        var error: NSError?
        var request = NSFetchRequest(entityName: "Counter")
        if let result = context.executeFetchRequest(request, error:&error) as? [Counter] {
            if result.count < 1 {
                insert()
            }
        }
        else {
            insert()
        }
    }

    func update() {
        println("update")
    }

    private func insert() {
        if let entity = NSEntityDescription.entityForName("Counter", inManagedObjectContext: context),
        let counter = NSManagedObject(entity: entity, insertIntoManagedObjectContext: context) as? Counter {
            counter.count = 0

            var error: NSError?
            if !context.save(&error) {
                println("Error saving context: \(error)")
            }
        }
    }

}

