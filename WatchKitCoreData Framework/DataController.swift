//
//  DataController.swift
//  WatchKitCoreData
//
//  Created by Ben Chatelain on 5/14/15.
//  Copyright (c) 2015 Ben Chatelain. All rights reserved.
//

import CoreData

public typealias InitCallback = () -> Void

public protocol DataController {

    var mainContext: NSManagedObjectContext { get }

    init(callback: InitCallback?)

    func save()

}
