//
//  Pin+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Molly Cox on 10/5/17.
//  Copyright © 2017 Molly Cox. All rights reserved.
//
//

import Foundation
import CoreData


public class Pin: NSManagedObject {
    // MARK: Initializer
    
    @objc convenience init(latitude: Double, longitude: Double, name: String, startingPhotoNumber: Int, context: NSManagedObjectContext) {
        
        // An EntityDescription is an object that has access to all
        // the information you provided in the Entity part of the model
        // you need it to create an instance of this class.
        if let ent = NSEntityDescription.entity(forEntityName: "Pin", in: context) {
            self.init(entity: ent, insertInto: context)
            self.latitude = latitude
            self.longitude = longitude
            self.name = name
            self.startingPhotoNumber = 1
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
}
