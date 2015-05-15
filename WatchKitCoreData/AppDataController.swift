//
//  AppDataController.swift
//  WatchKitCoreData
//
//  Created by Ben Chatelain on 5/14/15.
//  Copyright (c) 2015 Ben Chatelain. All rights reserved.
//

import Foundation
import WatchKitCoreDataFramework

class AppDataController: SingleContextDataController {

    func dataStoreDirectory() -> NSURL {
        let appGroupIdentifier = "group.com.phatblat.WatchKitCoreData"
        return NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier(appGroupIdentifier)!
    }

}
