//
//  FetchedResultsControllerDelegate.swift
//  WatchKitCoreData
//
//  Created by Ben Chatelain on 4/24/15.
//  Copyright (c) 2015 Ben Chatelain. All rights reserved.
//

import CoreData

public typealias SectionChangeHandler = (atIndex: Int) -> Void
public typealias ChangeHandler = (object: AnyObject) -> Void

@objc
public class FetchedResultsControllerDelegate: NSObject, NSFetchedResultsControllerDelegate {

    public var onSectionInsert: SectionChangeHandler?
    public var onSectionDelete: SectionChangeHandler?

    public var onInsert: ChangeHandler?
    public var onDelete: ChangeHandler?
    public var onUpdate: ChangeHandler?
    public var onMove: ChangeHandler?

    public var ignoreNextUpdates: Bool = false

    // MARK: - NSFetchedResultsControllerDelegate

    public func controllerWillChangeContent(controller: NSFetchedResultsController)  {
        print("controllerWillChangeContent:")
    }

    public func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType)  {
        print("controller:didChangeSection:atIndex:forChangeType:")

        switch type {
        case .Insert:
            onSectionInsert?(atIndex: sectionIndex)
        case .Delete:
            onSectionDelete?(atIndex: sectionIndex)
        default:
            return
        }
    }

    public func controller(controller: NSFetchedResultsController, didChangeObject changedObject: NSManagedObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        print("controller:didChangeObject:atIndexPath:forChangeType:")

        switch type {
        case .Insert:
            onInsert?(object: changedObject)
        case .Delete:
            onDelete?(object: changedObject)
        case .Update:
            onUpdate?(object: changedObject)
        case .Move:
            onMove?(object: changedObject)
        }
    }

    public func controllerDidChangeContent(controller: NSFetchedResultsController)  {
        print("controllerDidChangeContent:")
    }

}
