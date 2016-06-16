//
//  UI+SectionedViewType.swift
//  RxDataSources
//
//  Created by Krunoslav Zaher on 6/27/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import UIKit

func indexSet(values: [Int]) -> NSIndexSet {
    let indexSet = NSMutableIndexSet()
    for i in values {
        indexSet.add(i)
    }
    return indexSet
}

extension UITableView : SectionedViewType {
  
    public func insertItemsAtIndexPaths(paths: [IndexPath], animationStyle: UITableViewRowAnimation) {
        self.insertRows(at: paths, with: animationStyle)
    }
    
    public func deleteItemsAtIndexPaths(paths: [IndexPath], animationStyle: UITableViewRowAnimation) {
        self.deleteRows(at: paths, with: animationStyle)
    }
    
    public func moveItemAtIndexPath(from: IndexPath, to: IndexPath) {
        self.moveRow(at: from, to: to)
    }
    
    public func reloadItemsAtIndexPaths(paths: [IndexPath], animationStyle: UITableViewRowAnimation) {
        self.reloadRows(at: paths, with: animationStyle)
    }
    
    public func insertSections(sections: [Int], animationStyle: UITableViewRowAnimation) {
        self.insertSections(indexSet(values: sections) as IndexSet, with: animationStyle)
    }
    
    public func deleteSections(sections: [Int], animationStyle: UITableViewRowAnimation) {
        self.deleteSections(indexSet(values: sections) as IndexSet, with: animationStyle)
    }
    
    public func moveSection(from: Int, to: Int) {
        self.moveSection(from, toSection: to)
    }
    
    public func reloadSections(sections: [Int], animationStyle: UITableViewRowAnimation) {
        self.reloadSections(indexSet(values: sections) as IndexSet, with: animationStyle)
    }

  public func performBatchUpdates<S: SectionModelType>(changes: Changeset<S>, animationConfiguration: AnimationConfiguration) {
        self.beginUpdates()
        _performBatchUpdates(view: self, changes: changes, animationConfiguration: animationConfiguration)
        self.endUpdates()
    }
}

extension UICollectionView : SectionedViewType {
    public func insertItemsAtIndexPaths(paths: [IndexPath], animationStyle: UITableViewRowAnimation) {
        self.insertItems(at: paths)
    }
    
    public func deleteItemsAtIndexPaths(paths: [IndexPath], animationStyle: UITableViewRowAnimation) {
        self.deleteItems(at: paths)
    }

    public func moveItemAtIndexPath(from: IndexPath, to: IndexPath) {
        self.moveItem(at: from, to: to)
    }
    
    public func reloadItemsAtIndexPaths(paths: [IndexPath], animationStyle: UITableViewRowAnimation) {
        self.reloadItems(at: paths)
    }
    
    public func insertSections(sections: [Int], animationStyle: UITableViewRowAnimation) {
        self.insertSections(indexSet(values: sections) as IndexSet)
    }
    
    public func deleteSections(sections: [Int], animationStyle: UITableViewRowAnimation) {
        self.deleteSections(indexSet(values: sections) as IndexSet)
    }
    
    public func moveSection(from: Int, to: Int) {
        self.moveSection(from, toSection: to)
    }
    
    public func reloadSections(sections: [Int], animationStyle: UITableViewRowAnimation) {
        self.reloadSections(indexSet(values: sections) as IndexSet)
    }
    
  public func performBatchUpdates<S: SectionModelType>(changes: Changeset<S>, animationConfiguration: AnimationConfiguration) {
        self.performBatchUpdates({ () -> Void in
            _performBatchUpdates(view: self, changes: changes, animationConfiguration: animationConfiguration)
        }, completion: { (completed: Bool) -> Void in
        })
    }
}

public protocol SectionedViewType {
    func insertItemsAtIndexPaths(paths: [IndexPath], animationStyle: UITableViewRowAnimation)
    func deleteItemsAtIndexPaths(paths: [IndexPath], animationStyle: UITableViewRowAnimation)
    func moveItemAtIndexPath(from: IndexPath, to: IndexPath)
    func reloadItemsAtIndexPaths(paths: [IndexPath], animationStyle: UITableViewRowAnimation)
    
    func insertSections(sections: [Int], animationStyle: UITableViewRowAnimation)
    func deleteSections(sections: [Int], animationStyle: UITableViewRowAnimation)
    func moveSection(from: Int, to: Int)
    func reloadSections(sections: [Int], animationStyle: UITableViewRowAnimation)

    func performBatchUpdates<S>(changes: Changeset<S>, animationConfiguration: AnimationConfiguration)
}

func _performBatchUpdates<V: SectionedViewType, S: SectionModelType>(view: V, changes: Changeset<S>, animationConfiguration:AnimationConfiguration) {
    typealias I = S.Item
  
    view.deleteSections(sections: changes.deletedSections, animationStyle: animationConfiguration.deleteAnimation)
    // Updated sections doesn't mean reload entire section, somebody needs to update the section view manually
    // otherwise all cells will be reloaded for nothing.
    //view.reloadSections(changes.updatedSections, animationStyle: rowAnimation)
    view.insertSections(sections: changes.insertedSections, animationStyle: animationConfiguration.insertAnimation)
    for (from, to) in changes.movedSections {
        view.moveSection(from: from, to: to)
    }
    
    view.deleteItemsAtIndexPaths(
        paths: changes.deletedItems.map { IndexPath(item: $0.itemIndex, section: $0.sectionIndex) },
        animationStyle: animationConfiguration.deleteAnimation
    )
    view.insertItemsAtIndexPaths(
        paths: changes.insertedItems.map { IndexPath(item: $0.itemIndex, section: $0.sectionIndex) },
        animationStyle: animationConfiguration.insertAnimation
    )
    view.reloadItemsAtIndexPaths(
        paths: changes.updatedItems.map { IndexPath(item: $0.itemIndex, section: $0.sectionIndex) },
        animationStyle: animationConfiguration.reloadAnimation
    )
    
    for (from, to) in changes.movedItems {
        view.moveItemAtIndexPath(
            from: IndexPath(item: from.itemIndex, section: from.sectionIndex),
            to: IndexPath(item: to.itemIndex, section: to.sectionIndex)
        )
    }
}
