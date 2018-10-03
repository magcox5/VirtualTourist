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

private let reuseIdentifier = "Cell"

class PhotoCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,
    MKMapViewDelegate,
    NSFetchedResultsControllerDelegate {
    
    // MARK:  - Variables
    var _fetchedResultsController: NSFetchedResultsController<Photo>!
    let dataController = DataController(modelName: "VirtualTourist")
//    var dataController: DataController!
    var blockOperations: [BlockOperation] = []
    var vtCoordinate = CLLocationCoordinate2D(latitude: 37.335743, longitude: -122.009389)
    var vtSpan = MKCoordinateSpanMake(0.03, 0.03)
    var vtBBox = ""
    var newPin = true
    
    // MARK: - Outlets
    
    @IBOutlet weak var pinWithoutPhotos: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var newCollection: UIToolbar!
    @IBOutlet weak var okButton: UIBarButtonItem!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBAction func okButton(_ sender: Any) {
        //TODO: return to previous (map) screen
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func newCollection(_ sender: Any) {
        //TODO:  refresh photos in collection
    }
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "fileName", ascending: true)]
        _fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try _fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupFetchedResultsController()
        //pinWithoutPhotos.isHidden = false
        pinWithoutPhotos.isHidden = true

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
            virtualTouristModel.sharedInstance().getFlickrPhotos(vtBBox: vtBBox) {(success, error, data, photoCount) in
                if success {
                    DispatchQueue.main.async {
                        for i in 0...photoCount - 1 {
                            if data[i]["Title"] != nil {
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

        // Register cell classes
        collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView?.delegate = self
        collectionView?.dataSource = self

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
