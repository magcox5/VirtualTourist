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

class PhotoCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,MKMapViewDelegate {
    
    // MARK:  - Variables
    var currentPin: Pin!
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    var dataController: DataController!
    var vtCoordinate = CLLocationCoordinate2D(latitude: 37.335743, longitude: -122.009389)
    var vtSpan = MKCoordinateSpan.init(latitudeDelta: 0.03, longitudeDelta: 0.03)
    var vtBBox = ""
    var newPin = true
    var photoCount: Int = 0
    let itemSpacing: CGFloat = 9.0
    var bottomBarMessageDelete = "Press here to delete selected photos"
    var bottomBarMessageNew = "New Collection"
    var pinPhotos: [Photo] = []
    
    // MARK: - Properties
    fileprivate let reuseIdentifier = "photoCell"
    fileprivate let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    fileprivate let itemsPerRow: CGFloat = 3

    // MARK: - Outlets
    
    @IBOutlet weak var pinWithoutPhotos: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var newOrDeleteCollection: UIBarButtonItem!
    @IBOutlet weak var okButton: UIBarButtonItem!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    
    // MARK: - Actions
    @IBAction func okButton(_ sender: Any) {
        //TODO: return to previous (map) screen
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func newOrDeleteCollection(_ sender: Any) {
        // If "New Collection" button is pressed...
        // Delete current photos in coredata and array, then reload new ones
        if newOrDeleteCollection.title == bottomBarMessageNew {
//            for cell in photoCollectionView.visibleCells {
//                if let cell = cell as? PhotoCell {
//                    cell.photoActivityIndicator.startAnimating()
//                }
//            }
            for photo in self.pinPhotos {
                dataController.viewContext.delete(photo)
            }
            self.pinPhotos = []
            getNewPhotos()
            try? dataController.viewContext.save()
//            for cell in photoCollectionView.visibleCells {
//                if let cell = cell as? PhotoCell {
//                    cell.photoActivityIndicator.stopAnimating()
//                }
//            }

        } else {
            //Delete photos in core data and collectionview, return message to "new collection"
            let selectedItems = self.photoCollectionView.indexPathsForSelectedItems?.sorted{$1 < $0}
            print("The sorted order of the indices to delete is:  ", selectedItems!)
            for itemIndex in selectedItems! {
                let itemToDelete = self.pinPhotos[itemIndex.row]
                print(itemToDelete.fileName! as Any)
                self.pinPhotos.remove(at: itemIndex.row)
                photoCount -= 1
                dataController.viewContext.delete(itemToDelete)
//                DispatchQueue.main.async {
//                    self.photoCollectionView.deleteItems(at: [itemIndex])
//                }
                let cell = self.photoCollectionView.cellForItem(at: itemIndex)
                cell?.alpha=1.0
                cell?.contentView.alpha=1.0
            }
            print("Number of photos now is:  ", photoCount)
//            try? dataController.viewContext.save()
                newOrDeleteCollection.title = bottomBarMessageNew
        }
        self.reloadPhotos()
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
                    self.reloadPhotos()
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
        photoCollectionView.allowsMultipleSelection = true
        pinWithoutPhotos.isHidden = true
        newOrDeleteCollection.title = bottomBarMessageNew

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
        }
//        else {
            reloadPhotos()
//        }

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

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.photoCount > 0 {
            DispatchQueue.main.async {
                self.pinWithoutPhotos.isHidden = true
            }
        } else {
            DispatchQueue.main.async {
                self.pinWithoutPhotos.isHidden = false
            }
        }
        return self.photoCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoCell
        cell.backgroundColor = UIColor.white
        cell.photoActivityIndicator.startAnimating()
        
        DispatchQueue.main.async {
            cell.photoImage.image = nil
        }
        
        let photo = self.pinPhotos[indexPath.row]
        downloadImage(using: cell, photo: photo, collectionView: collectionView, index: indexPath)
        
        cell.photoActivityIndicator.stopAnimating()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let cell = collectionView.cellForItem(at: indexPath)
        //let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoCell
        cell?.alpha=0.5
        cell?.contentView.alpha=0.5
    
        print("Index paths for selected items is: ", self.photoCollectionView.indexPathsForSelectedItems!)
        newOrDeleteCollection.title = bottomBarMessageDelete
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {

        let cell = collectionView.cellForItem(at: indexPath)
        cell?.alpha=1.0
        cell?.contentView.alpha=1.0
        // if no items are selected, change message back to original message
        if self.photoCollectionView!.indexPathsForSelectedItems == [] {
            newOrDeleteCollection.title = bottomBarMessageNew
        } else {
            print("Position of photos selected:  ", collectionView.indexPathsForSelectedItems!);
        }
        
    }
    
    //Set size of cells relative to the view size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = ((view.frame.width) - (3 * itemSpacing))/3
        let height = width
        
        return CGSize(width: width, height: height)
    }

}
