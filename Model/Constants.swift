//
//  Constants.swift
//  VirtualTourist
//
//  Created by Molly Cox on 11/27/17.
//  Copyright © 2017 Molly Cox. All rights reserved.
//

import UIKit
import MapKit

// MARK: - Constants

struct Constants {
    
    // MARK: Flickr
    struct Flickr {
        // MARK:  Secret
        static let Secret : String =
        "6dce7b392e0cfee3"
        static let APIScheme = "https"
        static let APIHost = "api.flickr.com"
        static let APIPath = "/services/rest"
        static let APIBaseURL = "https://api.flickr.com/services/rest/"

        static let SearchBBoxHalfWidth = 1.0
        static let SearchBBoxHalfHeight = 1.0
        static let SearchLatRange = (-90.0, 90.0)
        static let SearchLonRange = (-180.0, 180.0)
        static let maxPhotos = 21
    }
    
    // MARK: Flickr Parameter Keys
    struct FlickrParameterKeys {
        static let Method = "method"
        static let APIKey = "api_key"
        static let GalleryID = "gallery_id"
        static let Extras = "extras"
        static let Format = "format"
        static let NoJSONCallback = "nojsoncallback"
        static let SafeSearch = "safe_search"
        static let Text = "text"
        static let BoundingBox = "bbox"
        static let Page = "page"
        static let Per_Page = "per_page"
    }
    
    // MARK: Flickr Parameter Values
    struct FlickrParameterValues {
        static let SearchMethod = "flickr.photos.search"
        static let APIKey = "40711feae697263b6f0b3452fe6c0ca7"
        static let ResponseFormat = "json"
        static let DisableJSONCallback = "1" /* 1 means "yes" */
        static let GalleryPhotosMethod = "flickr.galleries.getPhotos"
        static let MediumURL = "url_m"
        static let UseSafeSearch = "1"
        static let Per_Page = "21"
    }
    
    // MARK: Flickr Response Keys
    struct FlickrResponseKeys {
        static let Status = "stat"
        static let Photos = "photos"
        static let Photo = "photo"
        static let Title = "title"
        static let MediumURL = "url_m"
        static let Pages = "pages"
        static let Total = "total"
    }
    
    // MARK: Flickr Response Values
    struct FlickrResponseValues {
        static let OKStatus = "ok"
    }
    
    struct MapStartingValues {
        static let startingCoordinate = CLLocationCoordinate2D(latitude: 37.335743, longitude: -122.009389)
        static let startingSpan = MKCoordinateSpan.init(latitudeDelta: 0.1, longitudeDelta: 0.1)
        static let mapLatitude = 37.335743
        static let mapLongitude = -122.009389
        static let mapLatitudeDelta = 0.2
        static let mapLongitudeDelta = 0.2
    }
}
