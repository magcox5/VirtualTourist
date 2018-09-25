//
//  VTModel.swift
//  VirtualTourist
//
//  Created by Molly Cox on 9/25/18.
//  Copyright © 2018 Molly Cox. All rights reserved.
//

import Foundation

class virtualTouristModel: NSObject {
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> virtualTouristModel {
        struct Singleton {
            static var sharedInstance = virtualTouristModel()
        }
        return Singleton.sharedInstance
    }
    

    
}
