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
import CoreData

class PhotoAlbumViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newCollectionButton: UIToolbar!
    var regionHasBeenCentered = false
    var dataController: DataController!
    var annotation: MKPointAnnotation!
    var fetchedResultsController:NSFetchedResultsController<Photo>!
    
    @IBAction func returnBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func newCollectionButton(_ sender: Any) {
        fetchPhotos()
    }
    
    let locationManager = CLLocationManager()
    
    fileprivate func setUpAutomaticCenterOnUserLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    fileprivate func setUpFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "photos")
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch couldn't be performed \(error.localizedDescription)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        mapView.addAnnotation(annotation)
        setUpAutomaticCenterOnUserLocation()
        setUpFetchedResultsController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchPhotos()
        
        
        // fetch photos
        // if photos array is empty - show hide collection view
        // else - show collection
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    func fetchPhotos() {
        FlickrClient.sharedInstance().searchByLatLon(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude) { (success, photoArray, errorString) in
            performUIUpdatesOnMain {
                if success {
                    if let photoArray = photoArray {
                        self.fillPhotoCollection(photoArray)
                    }
                    self.collectionView.isHidden = false
                } else {
                    self.collectionView.isHidden = true
                    let alert = UIAlertController(title: "Error", message: "\(String(describing: errorString))", preferredStyle: UIAlertControllerStyle.alert)
                    
                    // add an action (button)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    
                    // show the alert
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func displayError(_ error: String) {
        let alert = UIAlertController(title: "Error", message: "\(error)", preferredStyle: UIAlertControllerStyle.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    func fillPhotoCollection(_ photoArray: [[String: AnyObject]]) {
        print(photoArray as Any)
        if photoArray.count == 0 {
            displayError("No Photos Found. Search Again.")
            return
        } else {
            // select first 20 photos
            for photo in photoArray {
                downloadPhoto(photo)
                addPhotoToPhotoCollection()
                savePhotoAsPhotoObject()
            }
        }
    }
    
    func downloadPhoto(_ photo: [String: AnyObject]) {
        print("download photo")
        let photoDictionary = photo as [String: AnyObject]
        let photoTitle = photoDictionary[FlickrClient.FlickrResponseKeys.Title] as? String
        print(photoTitle as Any)
        
        /* GUARD: Does our photo have a key for 'url_m'? */
        guard let imageUrlString = photoDictionary[FlickrClient.FlickrResponseKeys.MediumURL] as? String else {
            displayError("Cannot find key '\(FlickrClient.FlickrResponseKeys.MediumURL)' in \(photoDictionary)")
            return
        }
        
        // if an image exists at the url, set the image and title
        let imageURL = URL(string: imageUrlString)
        if let imageData = try? Data(contentsOf: imageURL!) {
            print(imageData)
//            performUIUpdatesOnMain {
//                self.setUIEnabled(true)
//                self.photoImageView.image = UIImage(data: imageData)
//                self.photoTitleLabel.text = photoTitle ?? "(Untitled)"
//            }
        } else {
            displayError("Image does not exist at \(String(describing: imageURL))")
        }
    }
    
    func addPhotoToPhotoCollection() {
        print("addPhoto to Collection")
    }
    
    func savePhotoAsPhotoObject() {
        print("save photo as photo object")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        
        if !regionHasBeenCentered {
            let span: MKCoordinateSpan = MKCoordinateSpanMake(40.0, 40.0)
            let userLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
            let region: MKCoordinateRegion = MKCoordinateRegionMake(userLocation, span)
            
            mapView.setRegion(region, animated: true)
            regionHasBeenCentered = true
        }

    }
}
