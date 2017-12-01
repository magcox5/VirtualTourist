//
//  Photo+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Molly Cox on 11/29/17.
//  Copyright © 2017 Molly Cox. All rights reserved.
//
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var fileName: String?
    @NSManaged public var photo: NSData?
    @NSManaged public var title: String?
    @NSManaged public var pin: Pin?

}
