//
//  AppGroupDataController.swift
//  WatchKitCoreData
//
//  Created by Ben Chatelain on 5/15/15.
//  Copyright (c) 2015 Ben Chatelain. All rights reserved.
//

import Foundation

public class AppGroupDataController: SingleContextDataController {

    public override func dataStoreDirectory() -> NSURL {
        let appGroupIdentifier = "group.com.phatblat.WatchKitCoreData"
        return NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier(appGroupIdentifier)!
    }

}
