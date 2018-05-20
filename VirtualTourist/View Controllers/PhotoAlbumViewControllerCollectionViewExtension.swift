//
//  PhotoAlbumViewControllerCollectionViewExtension.swift
//  VirtualTourist
//
//  Created by Max Boguslavskiy on 18/05/2018.
//  Copyright © 2018 Max Boguslavskiy. All rights reserved.
//

import Foundation
import UIKit
import CoreData

extension PhotoAlbumViewController {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! PhotoAlbumCollectionCellController
        cell.photoAlbumImage?.image = nil
        cell.activityIndicator.startAnimating()
        
        let photo = fetchedResultsController.object(at: indexPath)
        
        setUpImage(using: cell, photo: photo, collectionView: collectionView, index: indexPath)

        return cell
    }
    
    private func setUpImage(using cell: PhotoAlbumCollectionCellController, photo: Photo, collectionView: UICollectionView, index: IndexPath) {
        if let imageData = photo.image {
            cell.activityIndicator.stopAnimating()
            cell.photoAlbumImage?.image = UIImage(data: imageData)
        }
        else {
            if let imageUrl = photo.imageUrl {
                cell.activityIndicator.startAnimating()
                if let photoDict = downloadPhoto(imageUrl) {
                    let photoData = photoDict["imageData"] as! Data
                    performUIUpdatesOnMain {
                        cell.photoAlbumImage?.image = UIImage(data: photoData)
                        cell.activityIndicator.stopAnimating()
                        photo.image = photoData
                        DispatchQueue.global(qos: .background).async {
                            try? self.dataController.viewContext.save()
                        }
                    }
                }
            }
        }

    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photoToDelete = fetchedResultsController.object(at: indexPath)
        dataController.viewContext.delete(photoToDelete)
        try? dataController.viewContext.save()
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying: UICollectionViewCell, forItemAt: IndexPath) {
        
        if collectionView.cellForItem(at: forItemAt) == nil {
            return
        }

    }
    
}
