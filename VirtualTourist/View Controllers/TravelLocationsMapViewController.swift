//
//  TravelLocationsMapViewController.swift
//  VirtualTourist
//
//  Created by Max Boguslavskiy on 02/05/2018.
//  Copyright © 2018 Max Boguslavskiy. All rights reserved.
//

import MapKit
import UIKit
import CoreData

class TravelLocationsMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var myAnnotations = [CLLocation]()
    var regionHasBeenCentered = false
    var dataController: DataController!
    var fetchedResultsController:NSFetchedResultsController<Pin>!
    let locationManager = CLLocationManager()

    private let reuseIdentifier = "MyIdentifier"

    fileprivate func setUpGestureRecognition() {
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(addWaypoint(longGesture:)))
        longGesture.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(longGesture)
    }

    fileprivate func setUpAutomaticCenterOnUserLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    fileprivate func setUpFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "pins")

        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch couldn't be performed \(error.localizedDescription)")
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let pins = loadAnnotations() {
            showPins(pins: pins)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setUpGestureRecognition()
        setUpFetchedResultsController()
        setUpAutomaticCenterOnUserLocation()
    }

    func loadAnnotations() -> [Pin]? {
        if let controller = fetchedResultsController {
            if let objects = controller.fetchedObjects {
                return objects as [Pin]
            }
        }
        return nil
    }

    func showPins(pins: [Pin]) {
        for pin in pins {
            let annotation = MKPointAnnotation()
            let coordinate:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
        }
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

    @objc func addWaypoint(longGesture: UIGestureRecognizer) {

        if longGesture.state == .began {
            let touchPoint = longGesture.location(in: mapView)
            let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = newCoordinates
            mapView.addAnnotation(annotation)
            addAnnotation(coordinate: newCoordinates)
        }
        
    }

    /// Adds a new notebook to the end of the `notebooks` array
    func addAnnotation(coordinate: CLLocationCoordinate2D) {
        let pin = Pin(context: dataController.viewContext)
        pin.longitude = coordinate.longitude
        pin.latitude = coordinate.latitude
        pin.creationDate = Date()
        try? dataController.viewContext.save()
    }

    // setup annotation view
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }

        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) as? MKPinAnnotationView
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            annotationView?.tintColor = .green                // do whatever customization you want
            annotationView?.canShowCallout = false            // but turn off callout
        } else {
            annotationView?.annotation = annotation
        }

        return annotationView
    }

    private func findPin(coordinate: CLLocationCoordinate2D) -> Pin? {
        let predicate = NSPredicate(format: "latitude == %lf AND longitude == %lf", coordinate.latitude, coordinate.longitude)
        var pin: Pin?
        do {
            try pin = fetchPin(predicate)
        } catch {
            print("\(#function) error:\(error)")
        }
        return pin
    }

    private func fetchPin(_ predicate: NSPredicate, sorting: NSSortDescriptor? = nil) throws -> Pin? {
        let fr: NSFetchRequest<Pin> = Pin.fetchRequest()
        fr.predicate = predicate
        if let sorting = sorting {
            fr.sortDescriptors = [sorting]
        }
        guard let pin = try? dataController.viewContext.fetch(fr).first else {
            print("nil")
            return nil
        }
        return pin
    }

    // perform action on click on annotation
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let photoAlbumViewController = self.storyboard!.instantiateViewController(withIdentifier: "PhotoAlbumViewControllerID") as! PhotoAlbumViewController
        photoAlbumViewController.dataController = dataController
        // fetch Pin
        if let coordinate = view.annotation?.coordinate {
            let pin = findPin(coordinate: coordinate)
            photoAlbumViewController.pin = pin
            self.navigationController!.pushViewController(photoAlbumViewController, animated: true)
        }
    }

}
