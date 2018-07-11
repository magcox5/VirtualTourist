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

class FlickrClient {
    
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
                print("Just added photos")
                
                
                
            }
        }
        // start the task!
        task.resume()
        
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
    
    class func sharedInstance() -> FlickrClient {
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        return Singleton.sharedInstance
    }
    

}

