//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Molly Cox on 9/25/17.
//  Copyright © 2017 Molly Cox. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate

{
    
    // MARK:  Variables
    var vtCoordinate = CLLocationCoordinate2D(latitude: 37.335743, longitude: -122.009389)
    var vtSpan = MKCoordinateSpanMake(0.03, 0.03)

    // MARK:  Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var deletePinsMsg: UIBarButtonItem!
    @IBOutlet weak var editPinMsg: UIBarButtonItem!
    @IBOutlet weak var vtToolbar: UIToolbar!
    
    @IBAction func editPins(_ sender: Any) {
        if vtToolbar.isHidden == true {
            vtToolbar.isHidden = false
            editPinMsg.title = "Done"
        } else {
            vtToolbar.isHidden = true
            editPinMsg.title = "Edit"
        }
    }

    //declare the defaults...
    let defaults:UserDefaults = UserDefaults.standard
    
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Hide Delete Pins Message on ToolBar
        
        // Set variables for detecting long press to drop pin
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.handleLongPress(_:)))
        lpgr.minimumPressDuration = 0.5
        lpgr.delaysTouchesBegan = true
        lpgr.delegate = self
            mapView.delegate = self
            mapView.isUserInteractionEnabled = true
            mapView.addGestureRecognizer(lpgr)
        // Check to see if last map location saved
        if let hasBeenOpenedBefore = UserDefaults.standard.value(forKey: "HasBeenOpenedBefore") {
           // If so, do nothing...
            print("Program has run before... recall last saved values")
        } else {
            // If not, set default center and map zoom level and save to defaults...
            print("Never run this program before... Set default values")
            defaults.set(true, forKey: "HasBeenOpenedBefore")
            defaults.set(37.335743, forKey: "MapLatitude")
            defaults.set(-122.009389, forKey: "MapLongitude")
            defaults.set(0.2, forKey: "MapLatitudeDelta")
            defaults.set(0.2, forKey: "MapLongitudeDelta")
        }
        
        // Set the region
        var mapRegion = MKCoordinateRegion(center: vtCoordinate, span: vtSpan)
        vtCoordinate = CLLocationCoordinate2D(latitude: defaults.double(forKey: "MapLatitude"), longitude: defaults.double(forKey: "MapLongitude"))
        mapRegion.center = vtCoordinate
        mapRegion.span.latitudeDelta = defaults.double(forKey: "MapLatitudeDelta")
        mapRegion.span.longitudeDelta = defaults.double(forKey: "MapLongitudeDelta")
        mapView.setRegion(mapRegion, animated: true)
        print("Current span is: \(mapView.region.span)")
        print("Current center is: \(mapView.region.center)")
        
        // Set the title
        title = "Virtual Tourist"

        // Get the stack
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let stack = delegate.stack

        // Create a fetchrequest
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        fr.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true),
                              NSSortDescriptor(key: "latitude", ascending: false)]

        // Create the FetchedResultsController
        var fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Display the pin locations on the map
        displayPinLocations()
        
//        OnTheMapClient.sharedInstance().getStudentLocations(studentLocations: studentLocations, completionHandlerForStudentLocations:
//            { (success, studentLocations, errorString) in
//                if success {
//                    // Switch to Main Queue to display pins on map
//                    DispatchQueue.main.async {
//                        self.displayStudentLocations()
//                    }
//                }else {
//                    self.displayError(errorString: errorString!)
//                }
//        })
    }

    private func displayPinLocations() {
        // var annotations = [MKPointAnnotation]()
        // let locations =
        
        //            for student in locations {
        //                // Notice that the float values are being used to create CLLocationDegree values.
        //                // This is a version of the Double type.
        //                let lat = CLLocationDegrees(student.latitude)
        //                let long = CLLocationDegrees(student.longitude)
        //
        //                // The lat and long are used to create a CLLocationCoordinates2D instance.
        //                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        //
        //                let first = student.firstName
        //                let last = student.lastName
        //                let mediaURL = student.mediaURL
        //
        //                // Here we create the annotation and set its coordiate, title, and subtitle properties
        //                let annotation = MKPointAnnotation()
        //                annotation.coordinate = coordinate
        //                annotation.title = "\(first) \(last)"
        //                annotation.subtitle = mediaURL
        //
        // Finally we place the annotation in an array of annotations.
        //                annotations.append(annotation)
        
        //           }
        // When the array is complete, we add the annotations to the map.
        //           self.mapView.addAnnotations(annotations)
    }
    
    // MARK: - MKMapViewDelegate
    
    // Here we create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
    // method in TableViewDataSource.
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.pinTintColor = .red
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    
    func refreshMap(){
        //            OnTheMapClient.sharedInstance().getStudentLocations(studentLocations: studentLocations, completionHandlerForStudentLocations:
        //                { (success, studentLocations, errorString) in
        //                    if success {
        //                        // Switch to Main Queue to display pins on map
        //                        DispatchQueue.main.async {
        //                            self.displayStudentLocations()
        //                        }
        //                    }else {
        //                        self.displayError(errorString: errorString!)
        //                    }
        //            })
    }
    
    private var mapChangedFromUserInteraction = false
    
    private func mapViewRegionDidChangeFromUserInteraction() -> Bool {
        let view = self.mapView.subviews[0]
        //  Look through gesture recognizers to determine whether this region change is from user interaction
        if let gestureRecognizers = view.gestureRecognizers {
            for recognizer in gestureRecognizers {
                if( recognizer.state == UIGestureRecognizerState.began || recognizer.state == UIGestureRecognizerState.ended ) {
                    return true
                }
            }
        }
        return false
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        mapChangedFromUserInteraction = mapViewRegionDidChangeFromUserInteraction()
        if (mapChangedFromUserInteraction) {
            // user changed map region
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if (mapChangedFromUserInteraction) {
            // user changed map region
            updateMapLocation()
        }
    }
    
    func updateMapLocation() {
        defaults.set(mapView.centerCoordinate.latitude, forKey: "MapLatitude")
        defaults.set(mapView.centerCoordinate.longitude, forKey: "MapLongitude")
        defaults.set(mapView.region.span.latitudeDelta, forKey: "MapLatitudeDelta")
        defaults.set(mapView.region.span.longitudeDelta, forKey: "MapLongitudeDelta")
    }

    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state != UIGestureRecognizerState.ended {
            return
        }
        print("Long press on screen detected")
        // Add a pin at site of long press
        let touchPoint = gestureRecognizer.location(in: mapView)
        let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = newCoordinates
        mapView.addAnnotation(annotation)
        print("Annotation Added")

        // NSNumber(double: (newCoordinates.latitude)! as Double)
        // Now save to pin core data
        
        // Get the stack
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let stack = delegate.stack
        
        // Create a fetchrequest
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        fr.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true),
                              NSSortDescriptor(key: "latitude", ascending: false)]
        
        // Create the FetchedResultsController
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        
        let np =
            Pin(latitude: newCoordinates.latitude as Double,
             longitude: newCoordinates.longitude as Double,
             name: "New Pin",
             startingPhotoNumber: 1,
             context: fetchedResultsController.managedObjectContext)
        print("Just created a new pin: \(np)")

        // Get photos from flickr based on pin location
        // Store photos in Photo entity
        getFlickrPhotos()
        
        // Pass map location to photoVC
        
        // Finally segue to collection view to display photos
        let controller = storyboard!.instantiateViewController(withIdentifier: "photoVC") as? PhotoCollectionViewController
        controller?.vtCoordinate = annotation.coordinate
        controller?.vtSpan = mapView.region.span
        present(controller!, animated: true, completion: nil)
    }
}
extension MapViewController {
    func getFlickrPhotos(){
        // TODO:  go to flickr with pin coordinates and load into photo database for that pin
    }
}
//
//extension MapViewController {
//
//    @objc func executeSearch() {
//        if let fc = fetchedResultsController {
//            do {
//                try fc.performFetch()
//            } catch let e as NSError {
//                print("Error while trying to perform a String(describing: search: \n\(e)\n\(String(describing: fetchedResultsController))")
//            }
//        }
//    }
//}

