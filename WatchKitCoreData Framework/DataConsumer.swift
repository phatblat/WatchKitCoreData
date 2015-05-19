//
//  DataConsumer.swift
//  WatchKitCoreData
//
//  Created by Ben Chatelain on 5/18/15.
//  Copyright (c) 2015 Ben Chatelain. All rights reserved.
//

import Foundation
import WatchKitCoreDataFramework

public protocol DataConsumer: class {

    var dataController: DataController? { get set }

}
