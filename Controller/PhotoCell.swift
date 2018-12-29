//
//  photoCell.swift
//  VirtualTourist
//
//  Created by Molly Cox on 10/23/18.
//  Copyright © 2018 Molly Cox. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    
    static let identifier = "photoCell"
    var imageUrl: String = ""
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var photoActivityIndicator: UIActivityIndicatorView!
    
}
