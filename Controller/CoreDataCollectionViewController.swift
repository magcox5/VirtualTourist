//
//  CoreDataCollectionViewController.swift
//  VirtualTourist
//
//  Created by Molly Cox on 10/5/17.
//  Copyright © 2017 Molly Cox. All rights reserved.
//

import UIKit
import CoreData

// MARK: - CoreDataCollectionViewController: UICollectionViewController

class CoreDataCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate
{
    // MARK: Variables
    private let reuseIdentifier = "Cell"
    @IBOutlet var collectionView: UICollectionView!

    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if let fc = _fetchedResultsController {
            return (fc.sections?.count)!
        } else {
            return 0
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let fc = _fetchedResultsController {
            return (fc.sections![section].numberOfObjects)
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        cell.backgroundColor = UIColor.white
        return cell
    }

//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        <#code#>
//    }
    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
 //       <#code#>
 //   }
    
//class CoreDataCollectionViewController: UICollectionViewController, NSFetchedResultsControllerDelegate {

    var _fetchedResultsController: NSFetchedResultsController<Pin>? = nil
    var blockOperations: [BlockOperation] = []
    var shouldReloadCollectionView = false

    // Set the context
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    var dataController:DataController!
    
    var fetchedResultsController:NSFetchedResultsController<Photo>!
    
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    //let stack = delegate.stack
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        setupFetchedResultsController()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    
        if type == NSFetchedResultsChangeType.insert {
            print("Insert Object: \(String(describing: newIndexPath))")
        
            if (collectionView?.numberOfSections)! > 0 {
            
                if collectionView?.numberOfItems( inSection: newIndexPath!.section ) == 0 {
                    self.shouldReloadCollectionView = true
                } else {
                    blockOperations.append(
                        BlockOperation(block: { [weak self] in
                            if let this = self {
                                DispatchQueue.main.async {
                                    this.collectionView!.insertItems(at: [newIndexPath!])
                                }
                            }
                        })
                    )
                }
            
            } else {
                self.shouldReloadCollectionView = true
            }
        }
        else if type == NSFetchedResultsChangeType.update {
            print("Update Object: \(String(describing: indexPath))")
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let this = self {
                        DispatchQueue.main.async {
                            this.collectionView!.reloadItems(at: [indexPath!])
                        }
                    }
                })
            )
        }
        else if type == NSFetchedResultsChangeType.move {
            print("Move Object: \(String(describing: indexPath))")
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let this = self {
                        DispatchQueue.main.async {
                            this.collectionView!.moveItem(at: indexPath!, to: newIndexPath!)
                        }
                    }
                })
            )
        }
        else if type == NSFetchedResultsChangeType.delete {
            print("Delete Object: \(String(describing: indexPath))")
            if collectionView?.numberOfItems( inSection: indexPath!.section ) == 1 {
                self.shouldReloadCollectionView = true
            } else {
                blockOperations.append(
                    BlockOperation(block: { [weak self] in
                        if let this = self {
                            DispatchQueue.main.async {
                                this.collectionView!.deleteItems(at: [indexPath!])
                            }
                        }
                    })
                )
            }
        }
}

public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
    if type == NSFetchedResultsChangeType.insert {
        print("Insert Section: \(sectionIndex)")
        blockOperations.append(
            BlockOperation(block: { [weak self] in
                if let this = self {
                    DispatchQueue.main.async {
                        this.collectionView!.insertSections(NSIndexSet(index: sectionIndex) as IndexSet)
                    }
                }
            })
        )
    }
    else if type == NSFetchedResultsChangeType.update {
        print("Update Section: \(sectionIndex)")
        blockOperations.append(
            BlockOperation(block: { [weak self] in
                if let this = self {
                    DispatchQueue.main.async {
                        this.collectionView!.reloadSections(NSIndexSet(index: sectionIndex) as IndexSet)
                    }
                }
            })
        )
    }
    else if type == NSFetchedResultsChangeType.delete {
        print("Delete Section: \(sectionIndex)")
        blockOperations.append(
            BlockOperation(block: { [weak self] in
                if let this = self {
                    DispatchQueue.main.async {
                        this.collectionView!.deleteSections(NSIndexSet(index: sectionIndex) as IndexSet)
                    }
                }
            })
        )
    }
}

func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    
        // Checks if we should reload the collection view to fix a bug @    /http://openradar.appspot.com/12954582
        if (self.shouldReloadCollectionView) {
            DispatchQueue.main.async {
                self.collectionView?.reloadData();
            }
        } else {
            DispatchQueue.main.async {
                self.collectionView!.performBatchUpdates({ () -> Void in
                    for operation: BlockOperation in self.blockOperations {
                        operation.start()
                    }
                }, completion: { (finished) -> Void in
                    self.blockOperations.removeAll(keepingCapacity: false)
                })
            }
        }
        }

        deinit {
            for operation: BlockOperation in blockOperations {
                operation.cancel()
            }
            blockOperations.removeAll(keepingCapacity: false)
        }

}
