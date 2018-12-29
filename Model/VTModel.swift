//
//  VTModel.swift
//  VirtualTourist
//
//  Created by Molly Cox on 9/25/18.
//  Copyright © 2018 Molly Cox. All rights reserved.
//  Credit:  Singleton article
//           https://medium.com/@nimjea/singleton-class-in-swift-17eef2d01d88

import Foundation

class virtualTouristModel {

    // MARK: - Properties
    static let shared = virtualTouristModel()
    
    // Initialization
    private init() {}
}
