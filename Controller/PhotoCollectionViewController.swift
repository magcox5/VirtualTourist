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
    MKMapViewDelegate {
    
    // MARK:  - Variables
    var currentPin: Pin!
    var fetchedResultsController: NSFetchedResultsController<Photo>!
//    let dataController = DataController(modelName: "VirtualTourist")
    var dataController: DataController!
    var vtCoordinate = CLLocationCoordinate2D(latitude: 37.335743, longitude: -122.009389)
    var vtSpan = MKCoordinateSpanMake(0.03, 0.03)
    var vtBBox = ""
    var newPin = true
    var photoCount: Int = 0
    var pinPhotos: [Photo] = []

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
        // Delete current photos in coredata and array, then reload new ones
        for photo in self.pinPhotos {
            dataController.viewContext.delete(photo)
        }
        self.pinPhotos = []
        getNewPhotos()
        try? dataController.viewContext.save()
    }
    
    
    
    fileprivate func getNewPhotos() {
 virtualTouristModel.sharedInstance().getFlickrPhotos(vtBBox: vtBBox) {(success, error, data, imageCount) in
            if success {
                DispatchQueue.main.async {
                    self.pinWithoutPhotos.isHidden = true
                    for i in 0...imageCount - 1 {
                            let photo = Photo(context: self.dataController.viewContext)
                            photo.fileName = data[i]["FileName"] as? String
                            photo.title = data[i]["Title"] as? String
                            self.currentPin.addToPhotos(photo)
                            self.pinPhotos.append(photo)
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
        pinWithoutPhotos.isHidden = false

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
            try? dataController.viewContext.save()
        } else {
            reloadPhotos()
        }

        // Register cell classes
        //photoCollectionView!.register(PhotoCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        //photoCollectionView?.delegate = self
        //photoCollectionView?.dataSource = self

        // Do any additional setup after loading the view.
        mapView.centerCoordinate = vtCoordinate
        
    }

    fileprivate func reloadPhotos() {
        DispatchQueue.main.async {
            let photoFetchRequest = self.createPhotoFetchRequest() as NSFetchRequest<Photo>
            self.pinPhotos = try! self.dataController.viewContext.fetch(photoFetchRequest) as [Photo]
            self.photoCount = self.pinPhotos.count
            self.photoCollectionView.reloadData()
        }
    }
    
    fileprivate func createPhotoFetchRequest() -> NSFetchRequest<Photo> {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", currentPin)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        return fetchRequest
    }
    
    //function for loading images that are stored or that are being downloaded
    private func downloadImage(using cell: PhotoCell, photo: Photo, collectionView: UICollectionView, index: IndexPath) {
        if let imageData = photo.photo {
            DispatchQueue.main.async {
                cell.photoImage.image = UIImage(data: Data(referencing: imageData as NSData))
            }
        } else {
            if let imageUrl = URL(string: photo.fileName!) {
                do {
                    let imageData = try Data(contentsOf: imageUrl)
                    let image = UIImage(data: imageData)
                    DispatchQueue.main.async {
                        cell.photoImage.image = image
                    }
                    photo.photo = imageData as NSData
                } catch{
                    print("failed to download image from URL")
                }
            }
        }
    }

    
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
        cell.backgroundColor = UIColor.white
        
        DispatchQueue.main.async {
            cell.photoImage.image = nil
        }
        
        let photo = self.pinPhotos[indexPath.row]
        downloadImage(using: cell, photo: photo, collectionView: collectionView, index: indexPath)
        return cell

    }

}

