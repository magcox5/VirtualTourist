//
//  FlickrConvenience.swift
//  VirtualTourist
//
//  Created by Molly Cox on 12/5/18.
//  Copyright © 2018 Molly Cox. All rights reserved.
//

import Foundation
import UIKit
import MapKit

extension virtualTouristModel  {
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
    
    func isValueInRange(value: Double, min: Double, max: Double) -> Bool {
        return !(value < min || value > max)
    }

}

