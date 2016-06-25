//
//  RxCollectionViewSectionedAnimatedDataSource.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 7/2/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import UIKit
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif

public class RxCollectionViewSectionedAnimatedDataSource<S: AnimatableSectionModelType>
    : CollectionViewSectionedDataSource<S>
    , RxCollectionViewDataSourceType {
    public typealias Element = [S]
    public var animationConfiguration = AnimationConfiguration()
    
    // For some inexplicable reason, when doing animated updates first time
    // it crashes. Still need to figure out that one.
    var dataSet = false

    public override init() {
        super.init()
    }
    
    public func collectionView(_ collectionView: UICollectionView, observedEvent: Event<Element>) {
        UIBindingObserver(UIElement: self) { dataSource, newSections in
            #if DEBUG
                self._dataSourceBound = true
            #endif
            if !self.dataSet {
                self.dataSet = true
                dataSource.setSections(sections: newSections)
                collectionView.reloadData()
            }
            else {
                DispatchQueue.main.asynchronously() {
                    let oldSections = dataSource.sectionModels
                    do {
                        let differences = try differencesForSectionedView(initialSections: oldSections, finalSections: newSections)

                        for difference in differences {
                            dataSource.setSections(sections: difference.finalSections)
                            collectionView.performBatchUpdates(changes: difference, animationConfiguration: self.animationConfiguration)
                        }
                    }
                    catch let e {
                        rxDebugFatalError(error: e)
                        self.setSections(sections: newSections)
                        collectionView.reloadData()
                    }
                }
            }
        }.on(observedEvent)
    }
}
