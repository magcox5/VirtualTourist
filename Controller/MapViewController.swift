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
    private var fetchedResultsController:NSFetchedResultsController<Pin>!
    private var vtCoordinate = Constants.MapStartingValues.startingCoordinate
    private var vtSpan = Constants.MapStartingValues.startingSpan
    private var vtBBox: String = " "
    private var newPin: Bool = true
    private var currentPin: Pin!
    private var deletePins: Bool = false

   //declare the defaults...
   let defaults:UserDefaults = UserDefaults.standard

    // MARK:  Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var deletePinsMsg: UIBarButtonItem!
    @IBOutlet weak var editPinMsg: UIBarButtonItem!
    @IBOutlet weak var vtToolbar: UIToolbar!

   // MARK: Actions
    @IBAction func editPins(_ sender: Any) {
        if vtToolbar.isHidden == true {
            vtToolbar.isHidden = false
            deletePins = true
            editPinMsg.title = "Done"
        } else {
            vtToolbar.isHidden = true
            deletePins = false
            editPinMsg.title = "Edit"
        }
    }
   
   // MARK:  Core Data setup - Fetched Results Controller
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true),NSSortDescriptor(key: "latitude", ascending: false)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
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

   // MARK:  - MKMapView
    fileprivate func displayPinLocations() {

        setupFetchedResultsController()

        var annotations = [MKPointAnnotation]()
        
        for pin in fetchedResultsController.fetchedObjects! {
            let lat = CLLocationDegrees(pin.latitude)
            let lon = CLLocationDegrees(pin.longitude)
            
            // The lat and lon are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            
            // Create the annotation and set its coordiate, title, and subtitle properties
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
    
    fileprivate func mapViewRegionDidChangeFromUserInteraction() -> Bool {
        let view = self.mapView.subviews[0]
        //  Look through gesture recognizers to determine whether this region change is from user interaction
        if let gestureRecognizers = view.gestureRecognizers {
            for recognizer in gestureRecognizers {
                if( recognizer.state == UIGestureRecognizer.State.began || recognizer.state == UIGestureRecognizer.State.ended ) {
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
        if gestureRecognizer.state != UIGestureRecognizer.State.ended {
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
         guard let pinName = pinName else {return}
                  let np = Pin(latitude: newCoordinates.latitude as Double,
                             longitude: newCoordinates.longitude as Double,
                             name: pinName,
                             startingPhotoNumber: 1,
                             context: fetchedResultsController.managedObjectContext)
                  try? self.dataController.viewContext.save()
                  print("Just created a new pin: \(np)")
                  self.currentPin = np
         // Convert coordinates to a bbox string
         self.vtBBox = virtualTouristModel.sharedInstance().convertCoordToBBox(latLon: newCoordinates)
         
         // Segue to collection view to display photos
         let controller = self.storyboard!.instantiateViewController(withIdentifier: "photoVC") as? PhotoCollectionViewController
         controller?.vtCoordinate = annotation.coordinate
         controller?.vtSpan = self.mapView.region.span
         controller?.newPin = true
         controller?.currentPin = self.currentPin
         controller?.dataController = self.dataController
         controller?.vtBBox = self.vtBBox
         self.present(controller!, animated: true, completion: nil)
      }
      
    }
    
    @objc func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
      // Get coordinates for selected pin
      let annotation = view.annotation as! MKPointAnnotation
      print("The latitude is: ", annotation.coordinate.latitude)
      print("The longitude is: ", annotation.coordinate.longitude)
      vtBBox = virtualTouristModel.sharedInstance().convertCoordToBBox(latLon: annotation.coordinate)
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
               if deletePins == false {
                  controller?.currentPin = selectedPin
                  present(controller!, animated: true, completion: nil)
               } else {
                  // Delete pin from map and database
                  DispatchQueue.main.async {
                     self.mapView.removeAnnotations(mapView.annotations)
                     self.dataController.viewContext.delete(selectedPin)
                     try? self.dataController.viewContext.save()
                     self.displayPinLocations()
                  }
               }
               break
            }
         }
      }
   }
}
extension MapViewController {
    fileprivate func getPinName(coordinates: CLLocationCoordinate2D, completionHandler: @escaping (String?, Error?) -> ()) {
        let pinLat: CLLocationDegrees = coordinates.latitude
        let pinLon: CLLocationDegrees = coordinates.longitude
        let pinLoc: CLLocation = CLLocation(latitude: pinLat, longitude: pinLon)
        CLGeocoder().reverseGeocodeLocation(pinLoc, completionHandler: { (placemarks, error) in
            if error == nil {
                let firstLocation = placemarks?[0]
               let pinName = firstLocation!.name!
                completionHandler(pinName, nil)
            } else {
                // An error occurred during geocoding
                completionHandler(" ", error)
            }
        })
    }

    fileprivate func setupLongPressGestureRecognizer() {
        // Set variables for detecting long press to drop pin
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.handleLongPress(_:)))
        lpgr.minimumPressDuration = 0.5
        lpgr.delaysTouchesBegan = true
        lpgr.delegate = self
        mapView.delegate = self
        mapView.isUserInteractionEnabled = true
        mapView.addGestureRecognizer(lpgr)
    }

    fileprivate func setMapDefaults() {
        // If not, set default center and map zoom level and save to defaults...
        print("Never run this program before... Set default values")
        defaults.set(true, forKey: "HasBeenOpenedBefore")
        defaults.set(Constants.MapStartingValues.mapLatitude, forKey: "MapLatitude")
        defaults.set(Constants.MapStartingValues.mapLongitude, forKey: "MapLongitude")
        defaults.set(Constants.MapStartingValues.mapLatitudeDelta, forKey: "MapLatitudeDelta")
        defaults.set(Constants.MapStartingValues.mapLongitudeDelta, forKey: "MapLongitudeDelta")
    }

    fileprivate func setMapRegion() {
        var mapRegion = MKCoordinateRegion(center: vtCoordinate, span: vtSpan)
        vtCoordinate = CLLocationCoordinate2D(latitude: defaults.double(forKey: "MapLatitude"), longitude: defaults.double(forKey: "MapLongitude"))
        mapRegion.center = vtCoordinate
        mapRegion.span.latitudeDelta = defaults.double(forKey: "MapLatitudeDelta")
        mapRegion.span.longitudeDelta = defaults.double(forKey: "MapLongitudeDelta")
        mapView.setRegion(mapRegion, animated: true)
        print("Current span is: \(mapView.region.span)")
        print("Current center is: \(mapView.region.center)")
    }
    

}
