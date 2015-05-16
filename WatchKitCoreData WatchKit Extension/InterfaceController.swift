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

    @IBOutlet weak var counterLabel: WKInterfaceLabel?

    var dataController: DataController?

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)

        println(NSHomeDirectory())

        counterLabel?.setText("-1")
        dataController = AppGroupDataController() {}
    }

    /// This method is called when watch view controller is about to be visible to user
    override func willActivate() {
        super.willActivate()
    }

    /// This method is called when watch view controller is no longer visible
    override func didDeactivate() {
        super.didDeactivate()
    }

}
