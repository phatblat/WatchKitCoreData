//
//  NavigationController.swift
//  WatchKitCoreData
//
//  Created by Ben Chatelain on 5/18/15.
//  Copyright (c) 2015 Ben Chatelain. All rights reserved.
//

import UIKit
import WatchKitCoreDataFramework

class NavigationController: UINavigationController, DataConsumer {

    var dataController: DataController? {
        didSet {
            for vc in viewControllers {
                if let dc = vc as? DataConsumer {
                    dc.dataController = dataController
                }
            }
        }
    }

}
