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
    var dataController:DataController!
    var fetchedResultsController:NSFetchedResultsController<Pin>!
    var vtCoordinate = CLLocationCoordinate2D(latitude: 37.335743, longitude: -122.009389)
    var vtSpan = MKCoordinateSpanMake(0.1, 0.1)
    var vtBBox: String = " "
    var newPin: Bool = true
    var currentPin: Pin!

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
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true),NSSortDescriptor(key: "latitude", ascending: false)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        //fetchedResultsController.delegate = (self as! NSFetchedResultsControllerDelegate)
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLongPressGestureRecognizer()

        // Check to see if last map location saved
        if UserDefaults.standard.value(forKey: "HasBeenOpenedBefore") != nil {
           // If so, do nothing...
            print("Program has run before... recall last saved values")
        } else {
            setMapDefaults()
        }
        
        // Set the region
        setMapRegion()

        // Set the title
        title = "Virtual Tourist"

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Display the pin locations on the map
        displayPinLocations()
        
    }

    private func displayPinLocations() {

        setupFetchedResultsController()

        var annotations = [MKPointAnnotation]()
        
        for pin in fetchedResultsController.fetchedObjects! {
            let lat = CLLocationDegrees(pin.latitude)
            let lon = CLLocationDegrees(pin.longitude)
            
            // The lat and lon are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            
            // Here we create the annotation and set its coordiate, title, and subtitle properties
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            
            // Finally we place the annotation in an array of annotations.
            annotations.append(annotation)
            
        }
            // When the array is complete, we add the annotations to the map.
            self.mapView.addAnnotations(annotations)
    }
    
    // MARK: - MKMapViewDelegate
    
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
            updateMapLocation()
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
        // Add a pin at site of long press to the map
        let touchPoint = gestureRecognizer.location(in: mapView)
        let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        print("The latitude is: ", newCoordinates.latitude)
        print("The longitude is: ", newCoordinates.longitude)
        let annotation = MKPointAnnotation()
        annotation.coordinate = newCoordinates
        mapView.addAnnotation(annotation)
        print("Annotation Added to the map")

        // Create a fetchrequest
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        fr.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true),
                              NSSortDescriptor(key: "latitude", ascending: false)]
        
        // Create the FetchedResultsController
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        // Create a name for the pin using location data,
        // Then add the pin to core data

        getPinName(coordinates: newCoordinates) { pinName, error in
            guard let pinName = pinName, error == nil else {return}
            DispatchQueue.main.async {
                let np = Pin(latitude: newCoordinates.latitude as Double,
                             longitude: newCoordinates.longitude as Double,
                             name: pinName,
                             startingPhotoNumber: 1,
                             context: fetchedResultsController.managedObjectContext)
                print("Just created a new pin: \(np)")
               self.currentPin = np
            }
        }
        try? dataController.viewContext.save()
            
        // Convert coordinates to a bbox string
        vtBBox = convertCoordToBBox(latLon: newCoordinates)

        // Segue to collection view to display photos
        let controller = storyboard!.instantiateViewController(withIdentifier: "photoVC") as? PhotoCollectionViewController
        controller?.vtCoordinate = annotation.coordinate
        controller?.vtSpan = mapView.region.span
        controller?.newPin = true
        controller?.pin = currentPin
        controller?.dataController = dataController
        present(controller!, animated: true, completion: nil)
    }
    
    @objc func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // Show photos for selected pin
        let controller = storyboard!.instantiateViewController(withIdentifier: "photoVC") as? PhotoCollectionViewController
        controller?.vtCoordinate = (view.annotation?.coordinate)!
        controller?.vtSpan = mapView.region.span
        controller?.vtBBox = vtBBox
        controller?.newPin = false
        controller?.dataController = dataController

      // Go through pin database to find selected pin, then pass to next controller
      let selectedAnnotation = view.annotation
      let selectedAnnotationLat = selectedAnnotation?.coordinate.latitude
      let selectedAnnotationLong = selectedAnnotation?.coordinate.longitude
      var selectedPin: Pin
      if let result = fetchedResultsController.fetchedObjects {
         for pin in result {
            if pin.latitude == selectedAnnotationLat && pin.longitude == selectedAnnotationLong {
               selectedPin = pin
               controller?.pin = selectedPin
               present(controller!, animated: true, completion: nil)
               break
               }
            }
         }
   }
}
extension MapViewController {
    func convertCoordToBBox(latLon: CLLocationCoordinate2D) -> String {
        var minLat: Double = latLon.latitude as Double - Double(Constants.Flickr.SearchBBoxHalfHeight)
        var minLon: Double = latLon.longitude as Double - Double(Constants.Flickr.SearchBBoxHalfWidth)
        var maxLat: Double = latLon.latitude as Double + Double(Constants.Flickr.SearchBBoxHalfHeight)
        var maxLon: Double = latLon.longitude as Double + Double(Constants.Flickr.SearchBBoxHalfWidth)
        
        // If any of the values are out of range, set them to the min or max of the range
        if (!isValueInRange(value: minLat, min: Double(Constants.Flickr.SearchLatRange.0), max: Double(Constants.Flickr.SearchLatRange.1))) {
            minLat = Double(Constants.Flickr.SearchLatRange.0)
        }
        if (!isValueInRange(value: minLon, min: Double(Constants.Flickr.SearchLonRange.0), max: Double(Constants.Flickr.SearchLonRange.1))) {
            minLon = Double(Constants.Flickr.SearchLonRange.0)
        }
        
        if (!isValueInRange(value: maxLat, min: Double(Constants.Flickr.SearchLatRange.0), max: Double(Constants.Flickr.SearchLatRange.1))) {
            maxLat = Double(Constants.Flickr.SearchLatRange.1)
        }
        if (!isValueInRange(value: maxLon, min: Double(Constants.Flickr.SearchLonRange.0), max: Double(Constants.Flickr.SearchLonRange.1))) {
            maxLon = Double(Constants.Flickr.SearchLonRange.1)
        }
        
        return "\(minLon),\(minLat),\(maxLon),\(maxLat)"
    }
    
    func getPinName(coordinates: CLLocationCoordinate2D, completionHandler: @escaping (String?, Error?) -> ()) {
        let pinLat: CLLocationDegrees = coordinates.latitude
        let pinLon: CLLocationDegrees = coordinates.longitude
        let pinLoc: CLLocation = CLLocation(latitude: pinLat, longitude: pinLon)
        CLGeocoder().reverseGeocodeLocation(pinLoc, completionHandler: { (placemarks, error) in
            if error == nil {
                let firstLocation = placemarks?[0]
                let pinName = firstLocation!.country! + firstLocation!.locality! + firstLocation!.administrativeArea! + firstLocation!.postalCode!
                completionHandler(pinName, nil)
            } else {
                // An error occurred during geocoding
                completionHandler(" ", error)
            }
        })
    }

    func isValueInRange(value: Double, min: Double, max: Double) -> Bool {
            return !(value < min || value > max)
        }

    func setupLongPressGestureRecognizer() {
        // Set variables for detecting long press to drop pin
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.handleLongPress(_:)))
        lpgr.minimumPressDuration = 0.5
        lpgr.delaysTouchesBegan = true
        lpgr.delegate = self
        mapView.delegate = self
        mapView.isUserInteractionEnabled = true
        mapView.addGestureRecognizer(lpgr)
    }

    func setMapDefaults() {
        // If not, set default center and map zoom level and save to defaults...
        print("Never run this program before... Set default values")
        defaults.set(true, forKey: "HasBeenOpenedBefore")
        defaults.set(37.335743, forKey: "MapLatitude")
        defaults.set(-122.009389, forKey: "MapLongitude")
        defaults.set(0.2, forKey: "MapLatitudeDelta")
        defaults.set(0.2, forKey: "MapLongitudeDelta")
    }

    func setMapRegion() {
        var mapRegion = MKCoordinateRegion(center: vtCoordinate, span: vtSpan)
        vtCoordinate = CLLocationCoordinate2D(latitude: defaults.double(forKey: "MapLatitude"), longitude: defaults.double(forKey: "MapLongitude"))
        mapRegion.center = vtCoordinate
        mapRegion.span.latitudeDelta = defaults.double(forKey: "MapLatitudeDelta")
        mapRegion.span.longitudeDelta = defaults.double(forKey: "MapLongitudeDelta")
        mapView.setRegion(mapRegion, animated: true)
        print("Current span is: \(mapView.region.span)")
        print("Current center is: \(mapView.region.center)")
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
}
