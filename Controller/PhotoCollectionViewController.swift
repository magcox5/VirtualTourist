//
//  PhotoCollectionViewController.swift
//  VirtualTourist
//
//  Created by Molly Cox on 11/9/17.
//  Copyright © 2017 Molly Cox. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,
    MKMapViewDelegate,
    NSFetchedResultsControllerDelegate {
    
    // MARK:  - Variables
    var pin: Pin!
    var fetchedResultsController: NSFetchedResultsController<Photo>!
//    let dataController = DataController(modelName: "VirtualTourist")
    var dataController: DataController!
    var blockOperations: [BlockOperation] = []
    var vtCoordinate = CLLocationCoordinate2D(latitude: 37.335743, longitude: -122.009389)
    var vtSpan = MKCoordinateSpanMake(0.03, 0.03)
    var vtBBox = ""
    var newPin = true

    // MARK: - Properties
    fileprivate let reuseIdentifier = "photoCell"
    fileprivate let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    fileprivate let itemsPerRow: CGFloat = 3

    // MARK: - Outlets
    
    @IBOutlet weak var pinWithoutPhotos: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var newCollection: UIToolbar!
    @IBOutlet weak var okButton: UIBarButtonItem!
    
    @IBOutlet weak var photoCollectionView: UICollectionView!
    
    @IBAction func okButton(_ sender: Any) {
        //TODO: return to previous (map) screen
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func newCollection(_ sender: Any) {
        getNewPhotos()
        photoCollectionView.reloadData()
    }
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        
        if let pin = pin {
            let predicate = NSPredicate(format: "pin == %@", pin)
            fetchRequest.predicate = predicate
        }
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "fileName", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)

        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
        
        fetchedResultsController.delegate = self
    }
    
    fileprivate func getNewPhotos() {
 virtualTouristModel.sharedInstance().getFlickrPhotos(vtBBox: vtBBox) {(success, error, data, photoCount) in
            if success {
                DispatchQueue.main.async {
                    self.pinWithoutPhotos.isHidden = true
                    for i in 0...photoCount - 1 {
                        if data[i]["Title"] != nil {
                            print(i, data[i]["Title"]!,data[i]["FileName"]! )
                            let photo = Photo(context: self.dataController.viewContext)
                            photo.photo = data[i]["Photo"] as? NSData
                            photo.fileName = data[i]["FileName"] as? String
                            photo.title = data[i]["Title"] as? String
                        }
                    }
                    try? self.dataController.viewContext.save()
                }
            } else {
                let alert = UIAlertController(title: "Error", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title:NSLocalizedString("Ok", comment: "Default Action"), style: .default))
                alert.message = error!
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupFetchedResultsController()
        pinWithoutPhotos.isHidden = false

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Set the region
        var mapRegion = MKCoordinateRegion(center: vtCoordinate, span: vtSpan)
        mapRegion.center = vtCoordinate
        mapView.setRegion(mapRegion, animated: true)
        let annotation = MKPointAnnotation()
        annotation.coordinate = vtCoordinate
        mapView.addAnnotation(annotation)

        // get flickr photos if this is a new pin
        if newPin {
            getNewPhotos()
        }

        // Register cell classes
        photoCollectionView!.register(PhotoCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        photoCollectionView?.delegate = self
        photoCollectionView?.dataSource = self

        // Do any additional setup after loading the view.
        mapView.centerCoordinate = vtCoordinate
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if let fc = fetchedResultsController {
            return (fc.sections?.count)!
        } else {
            return 0
        }

    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let fc = fetchedResultsController {
            return (fc.sections![section].numberOfObjects)
        } else {
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoCell
        let aPhoto = fetchedResultsController.object(at: indexPath)
        cell.backgroundColor = UIColor.white
        
        // Configure cell
        print("The photo we're looking at is ", aPhoto.fileName! as Any)
        let vtImage = UIImage(data: aPhoto.photo! as Data)
        cell.photoImage.image = vtImage
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}

extension PhotoCollectionViewController {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        blockOperations.removeAll(keepingCapacity: false)
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            photoCollectionView.performBatchUpdates ({
                for operation in self.blockOperations {
                    operation.start()
                }
            }, completion: {(completed) in
            
            })
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            case .insert:
            blockOperations.append(BlockOperation(block: {
                self.photoCollectionView.insertItems(at: [newIndexPath!])
            }))
            case .delete:
            blockOperations.append(BlockOperation(block: {
                self.photoCollectionView.deleteItems(at: [indexPath!])
            }))
        default:
            break
        }
    }
}
