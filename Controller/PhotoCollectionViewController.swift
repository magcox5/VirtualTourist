//
//  PhotoCollectionViewController.swift
//  VirtualTourist
//
//  Created by Molly Cox on 11/9/17.
//  Copyright © 2017 Molly Cox. All rights reserved.
//
//  Credits:    John Nolan - downloading images (Github, Udacity Student Hub)
//              Tim Ng - placeholder & activity indicator (Github, Udacity
//              Student Hub)

import UIKit
import MapKit
import CoreData

class PhotoCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,MKMapViewDelegate {
    
    // MARK:  - Variables
    var currentPin: Pin!
    private var fetchedResultsController: NSFetchedResultsController<Photo>!
    var dataController: DataController!
    var vtCoordinate = Constants.MapStartingValues.startingCoordinate
    var vtSpan = Constants.MapStartingValues.startingSpan
    var vtBBox = ""
    var newPin = true
    private var photoCount: Int = 0
    private var viewCount: Int = 0
    private var noPhotosMessage = "No photos for this location"
    private var loadingPhotosMessage = "Downloading photos... please wait"
    private var bottomBarMessageDelete = "Press here to delete selected photos"
    private var bottomBarMessageNew = "New Collection"
    private var pinPhotos: [Photo] = []

    // MARK: - Properties
    fileprivate let reuseIdentifier = "photoCell"
    fileprivate let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    fileprivate let itemsPerRow: CGFloat = 3
    let itemSpacing: CGFloat = 9.0

    // MARK: - Outlets
    @IBOutlet weak var pinWithoutPhotos: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var newOrDeleteCollection: UIBarButtonItem!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    
    // MARK: - Actions
    @IBAction func backButton(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func newOrDeleteCollection(_ sender: Any) {
        
        // If "New Collection" button is pressed...
        // Delete current photos in coredata and array, then reload new ones
        if newOrDeleteCollection.title == bottomBarMessageNew {
            for photo in self.pinPhotos {
                dataController.viewContext.delete(photo)
            }
            self.pinPhotos = []
            getNewPhotos()
            try? dataController.viewContext.save()

        } else {
            //Delete photos in core data and collectionview, return message to "new collection"
            
            let selectedItems = self.photoCollectionView.indexPathsForSelectedItems?.sorted{$1 < $0}
            for itemIndex in selectedItems! {
                // 1st return cells to normal alpha
                    let cell = self.photoCollectionView.cellForItem(at: itemIndex)
                    cell?.alpha=1.0
                    cell?.contentView.alpha=1.0
                    // Delete item from pinPhotos array and core data
                    let itemToDelete = self.pinPhotos[itemIndex.row]
                    self.pinPhotos.remove(at: itemIndex.row)
                    self.photoCount -= 1
                    self.dataController.viewContext.delete(itemToDelete)
            }
            newOrDeleteCollection.title = bottomBarMessageNew
        }
        self.reloadPhotos()
        
    }
    
    // MARK: - Lifecycle
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
            viewCount = 0
            self.pinWithoutPhotos.isHidden = true
            getNewPhotos()
            try? dataController.viewContext.save()
        }
        reloadPhotos()
        
        // Do any additional setup after loading the view.
        mapView.centerCoordinate = vtCoordinate
        
    }

    // MARK:  Functions
    fileprivate func getNewPhotos() {
        
 virtualTouristModel.shared.getFlickrPhotos(vtBBox: vtBBox) {(success, error, data, imageCount) in
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
                // photos not found... show pinWithoutPhotos
                DispatchQueue.main.async {
                    self.pinWithoutPhotos.text = self.noPhotosMessage
                    self.pinWithoutPhotos.isHidden = false
                    let alert = UIAlertController(title: "Error", message: "", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title:NSLocalizedString("Ok", comment: "Default Action"), style: .default))
                    alert.message = error!
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        
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
                cell.photoActivityIndicator.stopAnimating()
                cell.photoImage.image = UIImage(data: Data(referencing: imageData as NSData))
            }
        } else {
            if let imageUrl = URL(string: photo.fileName!) {
                do {
                    DispatchQueue.main.async {
                        cell.photoActivityIndicator.startAnimating()
                    }
                    let imageData = try Data(contentsOf: imageUrl)
                    let image = UIImage(data: imageData)
                    DispatchQueue.main.async {
                        cell.photoImage.image = image
                        cell.photoActivityIndicator.stopAnimating()
                    }
                    photo.photo = imageData as NSData
                } catch{
                    DispatchQueue.main.async {
                        cell.photoActivityIndicator.stopAnimating()
                    }
                    print("failed to download image from URL")
                }
            }
        }
        
    }

    
    // MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, willDisplay cell:UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        self.pinWithoutPhotos.text = self.loadingPhotosMessage
        let photo = self.pinPhotos[indexPath.row]
        let photoCell = cell as! PhotoCell
        photoCell.imageUrl = photo.fileName!
        
        downloadImage(using: photoCell, photo: photo, collectionView: collectionView, index: indexPath)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        self.viewCount += 1
        DispatchQueue.main.async {
            if self.photoCount == 0 {
                self.pinWithoutPhotos.isHidden = false
                if self.viewCount <= 2 {
                    self.pinWithoutPhotos.text = self.loadingPhotosMessage
                } else {
                    self.pinWithoutPhotos.text = self.noPhotosMessage
                }
            } else {
                self.pinWithoutPhotos.isHidden = true
                self.pinWithoutPhotos.text = self.noPhotosMessage
                self.viewCount = 0
            }
        }
        return self.photoCount
        
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoCell
        cell.backgroundColor = UIColor.white
        cell.photoActivityIndicator.startAnimating()
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let cell = collectionView.cellForItem(at: indexPath)
        cell?.alpha=0.5
        cell?.contentView.alpha=0.5
        newOrDeleteCollection.title = bottomBarMessageDelete

    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {

        let cell = collectionView.cellForItem(at: indexPath)
        cell?.alpha=1.0
        cell?.contentView.alpha=1.0
        // if no items are selected, change message back to original message
        if self.photoCollectionView!.indexPathsForSelectedItems == [] {
            newOrDeleteCollection.title = bottomBarMessageNew
        }
        
    }
    
    //Set size of cells relative to the view size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = ((view.frame.width) - (3 * itemSpacing))/3
        let height = width
        return CGSize(width: width, height: height)

    }

}
