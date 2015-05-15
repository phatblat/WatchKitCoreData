//
//  InterfaceController.swift
//  WatchKitCoreData WatchKit Extension
//
//  Created by Ben Chatelain on 5/14/15.
//  Copyright (c) 2015 Ben Chatelain. All rights reserved.
//

import Foundation
import WatchKit
import WatchKitCoreDataFramework

class InterfaceController: WKInterfaceController {

    var dataController: DataController?

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)

        println(NSHomeDirectory())

        dataController = AppGroupDataController() {}
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
