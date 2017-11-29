//
//  Constants.swift
//  VirtualTourist
//
//  Created by Molly Cox on 11/27/17.
//  Copyright © 2017 Molly Cox. All rights reserved.
//

// Taken from "Sleeping in the Library" and "On The Map" apps

    // MARK: Constants
    struct Constants {
        
        // MARK: API Key
        static let ApiKey : String = "40711feae697263b6f0b3452fe6c0ca7"
        
        // MARK:  Secret
        static let Secret : String =
        "6dce7b392e0cfee3"
        
        // MARK:  Content-Type
        static let ContentType: String = "application/json"
        
        // MARK: URLs
        static let ApiScheme = "https://"
        static let ApiHost = "parse.udacity.com"
        static let ApiPath = "/parse/classes"
        static let ApiSearch = "/StudentLocation?limit=100&order=-updatedAt"
        static let ApiStudent = "/StudentLocation"
        static let signupURL = "https://auth.udacity.com/sign-up?next=https%3A%2F%2Fclassroom.udacity.com%2Fauthenticated"
        static let UdacityURL = "https://www.udacity.com/api/session"
        
        // MARK:  HTTP Header Fields
        static let httpHeaderApiKey = "X-Parse-REST-API-Key"
        static let httpHeaderAppID = "X-Parse-Application-Id"
        static let httpHeaderContentType = "Content-Type"
        
        
    }

    // MARK: Flickr
    struct Flickr {
        static let APIBaseURL = "https://api.flickr.com/services/rest/"
    }
    
    // MARK: Flickr Parameter Keys
    struct FlickrParameterKeys {
        static let Method = "method"
        static let APIKey = "api_key"
        static let GalleryID = "gallery_id"
        static let Extras = "extras"
        static let Format = "format"
        static let NoJSONCallback = "nojsoncallback"
    }
    
    // MARK: Flickr Parameter Values
    struct FlickrParameterValues {
        static let APIKey = "40711feae697263b6f0b3452fe6c0ca7"
        static let ResponseFormat = "json"
        static let DisableJSONCallback = "1" /* 1 means "yes" */
        static let GalleryPhotosMethod = "flickr.galleries.getPhotos"
        static let GalleryID = "5704-72157622566655097"
        static let MediumURL = "url_m"
    }
    
    // MARK: Flickr Response Keys
    struct FlickrResponseKeys {
        static let Status = "stat"
        static let Photos = "photos"
        static let Photo = "photo"
        static let Title = "title"
        static let MediumURL = "url_m"
    }
    
    // MARK: Flickr Response Values
    struct FlickrResponseValues {
        static let OKStatus = "ok"
    }

