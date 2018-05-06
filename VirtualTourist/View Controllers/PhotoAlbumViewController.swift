//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Max Boguslavskiy on 04/05/2018.
//  Copyright © 2018 Max Boguslavskiy. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class PhotoAlbumViewController: UIViewController {
    
    @IBOutlet weak var mkMapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newCollectionButton: UIToolbar!

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.isHidden = true
    }
    
    @IBAction func newCollectionButton(_ sender: Any) {
        print("new collection")
    }
}
