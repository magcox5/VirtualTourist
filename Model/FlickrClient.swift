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

extension virtualTouristModel  {
    func getFlickrPhotos(vtBBox: String, completionHandler: @escaping (_ success: Bool, _ errorString: String?, _ dataPhotos: [[String:Any]], _ photoCount: Int) -> Void){
        
        let methodParameters: [String: String?] =
            [Constants.FlickrParameterKeys.SafeSearch:Constants.FlickrParameterValues.UseSafeSearch,
             Constants.FlickrParameterKeys.BoundingBox:vtBBox,
             Constants.FlickrParameterKeys.Per_Page:Constants.FlickrParameterValues.Per_Page,
             Constants.FlickrParameterKeys.Extras:Constants.FlickrParameterValues.MediumURL,
             Constants.FlickrParameterKeys.APIKey:Constants.FlickrParameterValues.APIKey,
             Constants.FlickrParameterKeys.Method:Constants.FlickrParameterValues.SearchMethod,
             Constants.FlickrParameterKeys.Format:Constants.FlickrParameterValues.ResponseFormat,
             Constants.FlickrParameterKeys.NoJSONCallback:Constants.FlickrParameterValues.DisableJSONCallback]

        // create session and request
        let session = URLSession.shared
        let request = NSURLRequest(url: flickrURLFromParameters(parameters: methodParameters as [String : AnyObject]) as URL)
        
        // create network request
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                completionHandler(false, "There was an error with your request: \(error!)", [[:]], 0)
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                completionHandler(false, "Your request returned a status code other than 2xx!", [[:]], 0)
                return
            }
            
            guard let data = data else
            {
                completionHandler(false, "No Data was returned by this request!", [[:]], 0)
                return
            }
            
            
            // Deserialize JSON and extract necessary values
            let parsedResult: AnyObject!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
            } catch
            {
                completionHandler(false, "Could not parse data the data as JSON: '\(data)'", [[:]], 0)
                return
            }
            
            /* GUARD: Did Flicker return an error (stat != ok)? */
            guard let stat = parsedResult[Constants.FlickrResponseKeys.Status]
                as? String, stat == Constants.FlickrResponseValues.OKStatus
                else {
                    completionHandler(false, "Flickr API returned an error.  See error code and message in \(String(describing: parsedResult))", [[:]], 0)
                    return
            }
            
            if let photosDictionary =
                parsedResult[Constants.FlickrResponseKeys.Photos] as? [String: AnyObject]
            {
                /* GUARD: Is "pages" key in the photosDictionary? */
                guard let totalPages = photosDictionary[Constants.FlickrResponseKeys.Pages] as? Int else {
                    completionHandler(false, "Cannot find key '\(Constants.FlickrResponseKeys.Pages)' in \(photosDictionary)", [[:]], 0)
                    return
                }
                
                // pick a random page!
                let pageLimit = min(totalPages, 40)
                let randomPage = Int(arc4random_uniform(UInt32(pageLimit))) + 1
                self.displayImageFromFlickrBySearch(methodParameters: methodParameters as [String : AnyObject], withPageNumber: randomPage) {(success, error, data, photoCount) in
                    if success {
                        completionHandler(true, nil, data, photoCount)
                    }
                    else {
                        completionHandler(false, error, [[:]],0)
                        return
                    }
                }
            }
        }
        // start the task!
        task.resume()
    }

    // MARK: Get Images from Random page
    private func displayImageFromFlickrBySearch(methodParameters:  [String:AnyObject], withPageNumber: Int, completionHandler: @escaping (_ success: Bool, _ errorString: String?, _ dataPhotos: [[String:Any]], _ photoCount: Int) -> Void) {

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
                completionHandler(false, "There was an error with your request: \(String(describing: error))", [[:]], 0)
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                completionHandler(false, "Your request returned a status code other than 2xx!", [[:]], 0)
                return
            }
            
            guard let data = data else
            {
                completionHandler(false, "No Data was returned by this request!", [[:]], 0)
                return
            }
            
            
            // Deserialize JSON and extract necessary values
            let parsedResult: AnyObject!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
            } catch
            {
                completionHandler(false, "Could not parse data the data as JSON: '\(data)'", [[:]], 0)
                return
            }
            /* GUARD: Did Flicker return an error (stat != ok)? */
            guard let stat = parsedResult[Constants.FlickrResponseKeys.Status]
                as? String, stat == Constants.FlickrResponseValues.OKStatus
                else {
                    completionHandler(false, "Flickr API returned an error.  See error code and message in \(String(describing: parsedResult))", [[:]], 0)
                    return
            }
            
            
            guard let photosDictionary =
                parsedResult[Constants.FlickrResponseKeys.Photos] as? [String: AnyObject] else {
                    completionHandler(false, "Cannot find key '\(Constants.FlickrResponseKeys.Photos)' in  \(String(describing: parsedResult))", [[:]], 0)
                    return
            }
            
            guard let photosArray = photosDictionary["photo"] as? [[String: AnyObject]]
                else {
                    completionHandler(false, "Cannot find key '\(Constants.FlickrResponseKeys.Photo)' in \(photosDictionary)", [[:]], 0)
                    return
            }
            
            if photosArray.count == 0 {
                completionHandler(false, "No photos found.  Search Again", [[:]], 0)
                return
            } else {
                let photoIndex = photosArray.count
                var dataPhotos: [[String:Any]] = [[:]]
                for i in 0...photoIndex - 1 {
                    let photoDictionary = photosArray[i] as [String:AnyObject]
                    let photoTitle = photoDictionary[Constants.FlickrResponseKeys.Title] as? String
                    

                    guard let imageURLString = photoDictionary[Constants.FlickrResponseKeys.MediumURL] as? String else {
                        completionHandler(false, "Cannot find key '\(Constants.FlickrResponseKeys.MediumURL)' in \(photoDictionary)", [[:]], 0)
                        return
                    }

                    let imageURL = NSURL(string: imageURLString)
                    if let imageData = NSData(contentsOf: imageURL! as URL) {
                        dataPhotos.append(["FileName": imageURLString, "Photo": imageData,"Title": photoTitle!])
                        
                    } else {
                        completionHandler(false, "image does not exist at \(String(describing: imageURL))", [[:]], 0)
                        return
                    }
                }
                    dataPhotos.removeFirst(1)
                    completionHandler(true, nil, dataPhotos, photoIndex)
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
    
}

