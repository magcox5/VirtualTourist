//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Molly Cox on 7/11/18.
//  Copyright © 2018 Molly Cox. All rights reserved.
//

import Foundation
import UIKit
import MapKit

//class FlickrClient {

extension virtualTouristModel  {
    
    func getFlickrPhotos(vtBBox: String){
        
        let methodParameters: [String: String?] =
            [Constants.FlickrParameterKeys.SafeSearch:Constants.FlickrParameterValues.UseSafeSearch,
             Constants.FlickrParameterKeys.BoundingBox:vtBBox,
             Constants.FlickrParameterKeys.Per_Page:Constants.FlickrParameterValues.Per_Page,
             Constants.FlickrParameterKeys.Extras:Constants.FlickrParameterValues.MediumURL,
             Constants.FlickrParameterKeys.APIKey:Constants.FlickrParameterValues.APIKey,
             Constants.FlickrParameterKeys.Method:Constants.FlickrParameterValues.SearchMethod,
             Constants.FlickrParameterKeys.Format:Constants.FlickrParameterValues.ResponseFormat,
             Constants.FlickrParameterKeys.NoJSONCallback:Constants.FlickrParameterValues.DisableJSONCallback]
//        displayImageFromFlickrBySearch(methodParameters: methodParameters as [String : AnyObject], withPageNumber: <#Int#>)
        
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
                
                self.displayImageFromFlickrBySearch(methodParameters: methodParameters as [String : AnyObject], withPageNumber: randomPage)

                
                //Store photos in core data
                // for each photo in photosDictionary[randompage]
                // if an image exists at the url, set the image and title for our app
                //let imageURL = NSURL(string: photosDictionary[randomPage].imageURLString)
                //if let imageData = NSData(contentsOf: imageURL! as URL) {
                //    performUIUpdatesOnMain {
                //        self.setUIEnabled(enabled: true)
                //        self.photoImageView.image = UIImage(data: imageData as Data)
                //        self.photoTitleLabel.text = photoTitle ?? "(Untitled)"
                //    }
                //} else {
                //    let error = "image does not exist at \(String(describing: imageURL))"
                //    displayError(error: error)
                //}
                
                //let newPhoto = Photo(fileName: photosDictionary[randomPage].fileName as String,
                //  photo: imageData as Binary,
                //  title: photosDictionary[randomPage].title as String
                //let np = Pin(latitude: newCoordinates.latitude as Double,
                //             context: fetchedResultsController.managedObjectContext)
                // print("Just added photos")
            }
        }
        // start the task!
        task.resume()
        
    }

    // MARK: Get Images from Random page
    private func displayImageFromFlickrBySearch(methodParameters:  [String:AnyObject], withPageNumber: Int) {
        
        var methodParametersToPass: [String:AnyObject]
        methodParametersToPass = methodParameters
        
        // add page parameter to methodParameters dictionary
        methodParametersToPass[Constants.FlickrParameterKeys.Page] = "\(withPageNumber)" as AnyObject
        
        // create session and request
        let session = URLSession.shared
        let request = NSURLRequest(url: flickrURLFromParameters(parameters: methodParametersToPass) as URL)
        
        // create network request
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            // if an error occurs, print it and re-enable the UI
            func displayError(error: String) {
                print(error)
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                displayError(error: "There was an error with your request: \(String(describing: error))")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                let error = "Your request returned a status code other than 2xx!"
                displayError(error: error)
                return
            }
            
            guard let data = data else
            {
                let error = "No Data was returned by this request!"
                displayError(error: error)
                return
            }
            
            
            // Deserialize JSON and extract necessary values
            let parsedResult: AnyObject!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
            } catch
            {
                let error = "Could not parse data the data as JSON: '\(data)'"
                displayError(error: error)
                return
            }
            /* GUARD: Did Flicker return an error (stat != ok)? */
            guard let stat = parsedResult[Constants.FlickrResponseKeys.Status]
                as? String, stat == Constants.FlickrResponseValues.OKStatus
                else {
                    let error = "Flickr API returned an error.  See error code and message in \(parsedResult)"
                    displayError(error: error)
                    return
            }
            
            
            guard let photosDictionary =
                parsedResult[Constants.FlickrResponseKeys.Photos] as? [String: AnyObject] else {
                    let error = "Cannot find key '\(Constants.FlickrResponseKeys.Photos)' in  \(parsedResult)"
                    displayError(error: error)
                    return
            }
            
            guard let photosArray = photosDictionary["photo"] as? [[String: AnyObject]]
                else {
                    let error = "Cannot find key '\(Constants.FlickrResponseKeys.Photo)' in \(photosDictionary)"
                    displayError(error: error)
                    return
            }
            
            if photosArray.count == 0 {
                let error = "No photos found.  Search Again"
                displayError(error: error)
                return
            } else {
                //let randomPhotoIndex = Int(arc4random_uniform(UInt32(photosArray.count)))
                //let photoDictionary = photosArray[randomPhotoIndex] as [String:AnyObject]
                //let photoTitle = photoDictionary[Constants.FlickrResponseKeys.Title] as? String
            
                let photoIndex = photosArray.count
                print("The photoIndex is:  ", photoIndex)
                for i in 0...photoIndex-1 {
                    
                    let photoDictionary = photosArray[i] as [String:AnyObject]
                    let photoTitle = photoDictionary[Constants.FlickrResponseKeys.Title] as? String
                    

                    guard let imageURLString = photoDictionary[Constants.FlickrResponseKeys.MediumURL] as? String else {
                        let error = "Cannot find key '\(Constants.FlickrResponseKeys.MediumURL)' in \(photoDictionary)"
                        displayError(error: error)
                        return
                    }
                    // if an image exists at the url, set the image and title for our app
                    let imageURL = NSURL(string: imageURLString)
                    if let imageData = NSData(contentsOf: imageURL! as URL) {
                        //performUIUpdatesOnMain {
                        //    self.setUIEnabled(enabled: true)
                        //    self.photoImageView.image = UIImage(data: imageData as Data)
                        //    self.photoTitleLabel.text = photoTitle ?? "(Untitled)"
                        //}
                        // Add image to core database
                        //self.addPhoto(flickrFileName: imageURLString, flickrPhoto: imageData, flickrTitle: photoTitle!)
                        
                        
                    } else {
                        let error = "image does not exist at \(String(describing: imageURL))"
                        displayError(error: error)
                    }
                }
            }
        }
        // start the task!
        task.resume()
    }

    func addPhoto(flickrFileName: String, flickrPhoto: NSData, flickrTitle: String) {
        // Store fileName, Photo, and Title
//        let photo = Photo(context: dataController.viewContext)
        //photo.fileName = flickrFileName
        //photo.photo = flickrPhoto
        //photo.title = flickrTitle
//        try? dataController.viewContext.save()
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
    
    // MARK: Shared Instance
    
 //   class func sharedInstance() -> virtualTouristModel {
 //       struct Singleton {
 //           static var sharedInstance = virtualTouristModel()
 //       }
 //       return Singleton.sharedInstance
 //   }
    

}

