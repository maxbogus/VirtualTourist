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
    @IBOutlet var uiCollectionView: UICollectionView!
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!

    @IBAction func returnBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func newCollectionButton(_ sender: Any) {
        fetchPhotos()
    }
    
    var regionHasBeenCentered = false
    var dataController: DataController!
    var annotation: MKPointAnnotation!
    var fetchedResultsController:NSFetchedResultsController<Photo>!
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
        uiCollectionView?.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    func fetchPhotos() {
        newCollectionButton.isEnabled = false
        let downloadQueue = DispatchQueue.global()
        
        // call dispatch async to send a closure to the downloads queue
        downloadQueue.async { () -> Void in
            FlickrClient.sharedInstance().searchByLatLon(latitude: self.annotation.coordinate.latitude, longitude: self.annotation.coordinate.longitude) { (success, photoArray, errorString) in
                if success {
                    if let photoArray = photoArray {
                        self.fillPhotoCollection(photoArray)
                    }
                } else {
                    self.updateCollectionView(showCollectionView: true, enableButton: true, errorString: errorString)
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
        if photoArray.count == 0 {
            self.updateCollectionView(showCollectionView: false, enableButton: true, errorString: "No Photos Found. Search Again.")
            return
        } else {
            // select first 20 photos
            for photo in photoArray {
                if let photoObject: [String: AnyObject] = downloadPhoto(photo) {
                    savePhotoAsPhotoObject(photoObject)
                    addPhotoToPhotoCollection(photoObject)
                }
            }
            self.updateCollectionView(showCollectionView: true, enableButton: true)
        }
    }
    
    func updateCollectionView(showCollectionView: Bool, enableButton: Bool, errorString: String? = nil) {
        performUIUpdatesOnMain {
            if let error = errorString {
                self.displayError(error)
            }
            self.uiCollectionView.isHidden = showCollectionView
            self.newCollectionButton.isEnabled = enableButton
        }
    }
    
    func downloadPhoto(_ photo: [String: AnyObject]) -> [String: AnyObject]? {
        print("download photo")
        let photoDictionary = photo as [String: AnyObject]
        let photoTitle = photoDictionary[FlickrClient.FlickrResponseKeys.Title] as? String
        print(photoTitle as Any)
        
        /* GUARD: Does our photo have a key for 'url_m'? */
        guard let imageUrlString = photoDictionary[FlickrClient.FlickrResponseKeys.MediumURL] as? String else {
            displayError("Cannot find key '\(FlickrClient.FlickrResponseKeys.MediumURL)' in \(photoDictionary)")
            return nil
        }
        
        // if an image exists at the url, set the image and title
        let imageURL = URL(string: imageUrlString)
        if let imageData = try? Data(contentsOf: imageURL!) {
            return ["imageUrl": imageUrlString as AnyObject,
                    "imageData": imageData as AnyObject,
                    "photoTitle": photoTitle as AnyObject]
        } else {
            displayError("Image does not exist at \(String(describing: imageURL))")
            return nil
        }
    }
    
    func addPhotoToPhotoCollection(_ photoObject: [String: AnyObject]) {
        print("addPhoto to Collection")
        print(photoObject)
//        performUIUpdatesOnMain {
//            self.photoImageView.image = UIImage(data: imageData)
//            self.photoTitleLabel.text = photoTitle ?? "(Untitled)"
//        }
    }
    
    func savePhotoAsPhotoObject(_ photoObject: [String: AnyObject]) {
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
    
    private func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let photo = fetchedResultsController.object(at: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! PhotoAlbumCollectionCellController
        
        // Set the image
        cell.photoAlbumImage?.image = UIImage(data: photo.image!)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath)
        
    }
}
