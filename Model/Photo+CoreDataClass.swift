//
//  Photo+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Molly Cox on 10/5/17.
//  Copyright © 2017 Molly Cox. All rights reserved.
//
//

import Foundation
import CoreData


public class Photo: NSManagedObject {
    @objc convenience init(context: NSManagedObjectContext) {
        
        // An EntityDescription is an object that has access to all
        // the information you provided in the Entity part of the model
        // you need it to create an instance of this class.
        if let ent = NSEntityDescription.entity(forEntityName: "Photo", in: context) {
            self.init(entity: ent, insertInto: context)
            self.fileName = " "
            self.photo = nil
            self.title = " "
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
}
