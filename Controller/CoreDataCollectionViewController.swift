//
//  CoreDataCollectionViewController.swift
//  VirtualTourist
//
//  Created by Molly Cox on 10/5/17.
//  Copyright © 2017 Molly Cox. All rights reserved.
//

import UIKit
import CoreData

// MARK: - CoreDataCollectionViewController: UIViewController

class CoreDataCollectionViewController: UICollectionViewController {
    
    // MARK: Properties
    
    @objc var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>? {
        didSet {
            // Whenever the frc changes, we execute the search and
            // reload the collection
            fetchedResultsController?.delegate = self as! NSFetchedResultsControllerDelegate
            executeSearch()
            collectionView?.reloadData()
        }
    }
    
    // MARK: Initializers
    
//    @objc init(fetchedResultsController fc : NSFetchedResultsController<NSFetchRequestResult>, style : UITableViewStyle = .plain) {
//        fetchedResultsController = fc
//        super.init(style: style)
//    }

    @objc init(fetchedResultsController fc : NSFetchedResultsController<NSFetchRequestResult>) {
        fetchedResultsController = fc
    }

    
    // Do not worry about this initializer. It has to be implemented
    // because of the way Swift interfaces with an Objective C
    // protocol called NSArchiving. It's not relevant.
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

// MARK: - CoreDataCollectionViewController (Subclass Must Implement)

extension CoreDataCollectionViewController {
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        fatalError("This method MUST be implemented by a subclass of CoreDataCollectionViewController")
    }
}

// MARK: - CoreDataCollectionViewController (Collection Data Source)

extension CoreDataCollectionViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        if let fc = fetchedResultsController {
            return (fc.sections?.count)!
        } else {
            return 0
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let fc = fetchedResultsController {
            return fc.sections![section].numberOfObjects
        } else {
            return 0
        }
    }
    
//    override func collectionView(_ collectionView: UICollectionView, titleForHeaderInSection section: Int) -> String? {
//        if let fc = fetchedResultsController {
//            return fc.sections![section].name
//        } else {
//            return nil
//        }
//    }
    
//    override func collectionView(_ collectionView: UICollectionView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
//        if let fc = fetchedResultsController {
//            return fc.section(forSectionIndexTitle: title, at: index)
//        } else {
//            return 0
//        }
//    }
    
//    override func sectionIndexTitles(for collectionView: UICollectionView) -> [String]? {
//        if let fc = fetchedResultsController {
//            return fc.sectionIndexTitles
//        } else {
//            return nil
//        }
//    }
}

// MARK: - CoreDataCollectionViewController (Fetches)

extension CoreDataCollectionViewController {
    
    @objc func executeSearch() {
        if let fc = fetchedResultsController {
            do {
                try fc.performFetch()
            } catch let e as NSError {
                print("Error while trying to perform a String(describing: search: \n\(e)\n\(String(describing: fetchedResultsController))")
            }
        }
    }
}

// MARK: - CoreDataCollectionViewController: NSFetchedResultsControllerDelegate

extension CoreDataCollectionViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView?.performBatchUpdates(<#T##updates: (() -> Void)?##(() -> Void)?##() -> Void#>, completion: <#T##((Bool) -> Void)?##((Bool) -> Void)?##(Bool) -> Void#>)
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        let set = IndexSet(integer: sectionIndex)
        
        switch (type) {
        case .insert:
            collectionView?.insertSections(set)
        case .delete:
            collectionView?.deleteSections(set)
        default:
            // irrelevant in our case
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch(type) {
        case .insert:
            collectionView?.insertItems(at: [newIndexPath!])
        case .delete:
            collectionView?.deleteItems(at: [indexPath!])
        case .update:
            collectionView?.reloadItems(at: [indexPath!])
        case .move:
            collectionView?.deleteItems(at: [indexPath!])
            collectionView?.insertItems(at: [newIndexPath!])
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        //collectionView.endUpdates()
    }
}

}
