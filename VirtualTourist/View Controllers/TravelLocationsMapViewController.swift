//
//  TravelLocationsMapViewController.swift
//  VirtualTourist
//
//  Created by Max Boguslavskiy on 02/05/2018.
//  Copyright © 2018 Max Boguslavskiy. All rights reserved.
//

import MapKit
import UIKit

class TravelLocationsMapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var myAnnotations = [CLLocation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(addWaypoint(longGesture:)))
        mapView.addGestureRecognizer(longGesture)
        mapView.showsUserLocation = true
    }
    
    @objc func addWaypoint(longGesture: UIGestureRecognizer) {
        let touchPoint = longGesture.location(in: mapView)
        let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = newCoordinates
        mapView.addAnnotation(annotation)
    }
}
