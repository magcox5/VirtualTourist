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

class MapViewController:  UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate  {
    
    // MARK:  Variables
    var vtCoordinate = CLLocationCoordinate2D(latitude: 37.335743, longitude: -122.009389)
    var vtSpan = MKCoordinateSpanMake(0.03, 0.03)
    var mapRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.335743, longitude: -122.009389), span: MKCoordinateSpanMake(0.03, 0.03))

    @IBOutlet weak var mapView: MKMapView!
    //declare the defaults...
    let defaults:UserDefaults = UserDefaults.standard
    
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set variables for detecting long press to drop pin
        let lpgr = UILongPressGestureRecognizer(target: self, action: Selector(("handleLongPress:")))
        lpgr.minimumPressDuration = 0.5
        lpgr.delaysTouchesBegan = true
        lpgr.delegate = self
        //self.collectionView.addGestureRecognizer(lpgr)
        //self.navigationController?.title = "Virtual Tourist"
            mapView.delegate = self
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
        vtCoordinate = CLLocationCoordinate2D(latitude: defaults.double(forKey: "MapLatitude"), longitude: defaults.double(forKey: "MapLongitude"))
        mapRegion.center = vtCoordinate
        mapRegion.span.latitudeDelta = defaults.double(forKey: "MapLatitudeDelta")
        mapRegion.span.longitudeDelta = defaults.double(forKey: "MapLongitudeDelta")
        mapView.setRegion(mapRegion, animated: true)
        print("Current span is: \(mapView.region.span)")
        print("Current center is: \(mapView.region.center)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Get the pin locations to populate the map
        
        //        OnTheMapClient.sharedInstance().getStudentLocations(studentLocations: studentLocations, completionHandlerForStudentLocations:
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
    
    private func displayPinLocations() {
        //            var annotations = [MKPointAnnotation]()
        //            let locations = self.studentLocations.thisStudentArray
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
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .blue
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        //            if control == view.rightCalloutAccessoryView {
        //                if let toOpen = view.annotation?.subtitle! {
        //                    if OnTheMapClient.useableURL(thisURL: toOpen) {
        //                        //if (mapClient?.useableURL(thisURL: toOpen))! {
        //                        if let url = URL(string: toOpen) {
        //                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        //                        }
        //                    } else {
        //                        displayError(errorString: "Looks like this isn't a valid URL...")
        //                    }
        //                }
        //            }
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

    func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state != UIGestureRecognizerState.ended {
            return
        }
        print("Long press on screen detected")
        
//        let p = gestureReconizer.locationInView(self.collectionView)
//        let indexPath = self.collectionView.indexPathForItemAtPoint(p)
//
//        if let index = indexPath {
//            var cell = self.collectionView.cellForItemAtIndexPath(index)
//            // do stuff with your cell, for example print the indexPath
//            print(index.row)
//        } else {
//            print("Could not find index path")
//        }
    }
}

