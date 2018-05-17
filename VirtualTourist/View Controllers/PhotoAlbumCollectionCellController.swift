//
//  PhotoAlbumCollectionCellController.swift
//  VirtualTourist
//
//  Created by Max Boguslavskiy on 14/05/2018.
//  Copyright © 2018 Max Boguslavskiy. All rights reserved.
//

import UIKit

class PhotoAlbumCollectionCellController: UICollectionViewCell {
    var imageUrl: String = ""

    @IBOutlet weak var photoAlbumImage: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

}
