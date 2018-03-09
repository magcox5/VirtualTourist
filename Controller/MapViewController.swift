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
    var vtBBox: String = " "

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
         //var annotations = [MKPointAnnotation]()
         //let locations =
        
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

        // Get the stack
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let stack = delegate.stack
        
        // Create a fetchrequest
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        fr.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true),
                              NSSortDescriptor(key: "latitude", ascending: false)]
        
        // Create the FetchedResultsController
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        
        // Get a name for the pin,
        // Then add the pin to core data
//        getPinName(coordinates: newCoordinates, {pinName,error in
//            guard let pinName = pinName, error == nil else {return}
//            DispatchQueue.main.async {
//                let np = Pin(latitude: newCoordinates.latitude as Double,
//                             longitude: newCoordinates.longitude as Double,
//                             name: pinName,
//                             startingPhotoNumber: 1,
//                             context: fetchedResultsController.managedObjectContext)
//                print("Just created a new pin: \(np.latitude, np.longitude, np.name!)")
//            }
//        }
        getPinName(coordinates: newCoordinates) { pinName, error in
            guard let pinName = pinName, error == nil else {return}
            DispatchQueue.main.async {
                let np = Pin(latitude: newCoordinates.latitude as Double,
                             longitude: newCoordinates.longitude as Double,
                             name: pinName,
                             startingPhotoNumber: 1,
                             context: fetchedResultsController.managedObjectContext)
                print("Just created a new pin: \(np)")
            }
        }
            
        // TODO:  Convert coordinates to a bbox string
        vtBBox = convertCoordToBBox(latLon: newCoordinates)
        // Get photos from flickr based on pin location
        // Store photos in Photo entity
        getFlickrPhotos(vtBBox: vtBBox)
        
        // Pass map location to photoVC
        
        // Finally segue to collection view to display photos
        let controller = storyboard!.instantiateViewController(withIdentifier: "photoVC") as? PhotoCollectionViewController
        controller?.vtCoordinate = annotation.coordinate
        controller?.vtSpan = mapView.region.span
        present(controller!, animated: true, completion: nil)
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
                //let pinName = (firstLocation?.country)! + firstLocation?.locality + firstLocation?.administrativeArea + firstLocation?.postalCode
                let pinName = firstLocation!.country! + firstLocation!.locality! + firstLocation!.administrativeArea! + firstLocation!.postalCode!
                completionHandler(pinName, nil)
            } else {
                // An error occurred during geocoding
                completionHandler(" ", error)
            }
        })
    }
    func getFlickrPhotos(vtBBox: String){

        // TODO:  go to flickr with bounding box and load into photo database for that pin
        // TODO: Set necessary parameters!
        let methodParameters: [String: String?] =
            [Constants.FlickrParameterKeys.SafeSearch:Constants.FlickrParameterValues.UseSafeSearch,
             Constants.FlickrParameterKeys.BoundingBox:vtBBox,
             Constants.FlickrParameterKeys.Per_Page:Constants.FlickrParameterValues.Per_Page,
             Constants.FlickrParameterKeys.Extras:Constants.FlickrParameterValues.MediumURL,
             Constants.FlickrParameterKeys.APIKey:Constants.FlickrParameterValues.APIKey,
             Constants.FlickrParameterKeys.Method:Constants.FlickrParameterValues.SearchMethod,
             Constants.FlickrParameterKeys.Format:Constants.FlickrParameterValues.ResponseFormat,
             Constants.FlickrParameterKeys.NoJSONCallback:Constants.FlickrParameterValues.DisableJSONCallback]
//        displayImageFromFlickrBySearch(methodParameters: methodParameters as [String : AnyObject])
        
        // create session and request
        let session = URLSession.shared
        let request = NSURLRequest(url: flickrURLFromParameters(parameters: methodParameters as [String : AnyObject]) as URL)
        
        // create network request
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            // if an error occurs, print it and re-enable the UI
            func displayError(error: String) {
                print(error)
                //DispatchQueue.main.async {
                    //self.setUIEnabled(enabled: true)
                    //self.photoTitleLabel.text = "No photo returned. Try again."
                    //self.photoImageView.image = nil
                //}
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                displayError(error: "There was an error with your request: \(String(describing: error))")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                displayError(error: "Your request returned a status code other than 2xx!")
                return
            }
            
            guard let data = data else
            {
                displayError(error: "No Data was returned by this request!")
                return
            }
            
            
            // Deserialize JSON and extract necessary values
            let parsedResult: AnyObject!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
            } catch
            {
                displayError(error: "Could not parse data the data as JSON: '\(data)'")
                return
            }
            
            /* GUARD: Did Flicker return an error (stat != ok)? */
            guard let stat = parsedResult[Constants.FlickrResponseKeys.Status]
                as? String, stat == Constants.FlickrResponseValues.OKStatus
                else {
                    displayError(error: "Flickr API returned an error.  See error code and message in \(parsedResult)")
                    return
            }
            
            if let photosDictionary =
                parsedResult[Constants.FlickrResponseKeys.Photos] as? [String: AnyObject]
                //                ,
                // photoArray = photosDictionary["photo"] as? [[String: AnyObject]]
            {
                /* GUARD: Is "pages" key in the photosDictionary? */
                guard let totalPages = photosDictionary[Constants.FlickrResponseKeys.Pages] as? Int else {
                    displayError(error: "Cannot find key '\(Constants.FlickrResponseKeys.Pages)' in \(photosDictionary)")
                    return
                }
                
                // pick a random page!
                let pageLimit = min(totalPages, 40)
                let randomPage = Int(arc4random_uniform(UInt32(pageLimit))) + 1
                print("Here's my random page")
                print(randomPage)
                //self.displayImageFromFlickrBySearch(methodParameters: methodParameters, withPageNumber: randomPage)
            }
        }
        // start the task!
        task.resume()
        
        // TODO: Store photos in core data
        print("Now to store photos in core data")
    }

    func isValueInRange(value: Double, min: Double, max: Double) -> Bool {
            return !(value < min || value > max)
        }
    
    // MARK: Helper for Creating a URL from Parameters
    
    private func flickrURLFromParameters(parameters: [String:AnyObject]) -> NSURL {
        
        let components = NSURLComponents()
        components.scheme = Constants.Flickr.APIScheme
        components.host = Constants.Flickr.APIHost
        components.path = Constants.Flickr.APIPath
        components.queryItems = [NSURLQueryItem]() as [URLQueryItem]
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem as URLQueryItem)
        }
        
        return components.url! as NSURL
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

