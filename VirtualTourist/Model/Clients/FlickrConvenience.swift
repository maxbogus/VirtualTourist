//
//  FlickrConvenience.swift
//  VirtualTourist
//
//  Created by Max Boguslavskiy on 07/05/2018.
//  Copyright © 2018 Max Boguslavskiy. All rights reserved.
//

import UIKit
import Foundation

// MARK: - FlickrClient (Convenient Resource Methods)

extension FlickrClient {
    
    // MARK: Search photos by coordinates (GET) Methods
    func searchByLatLon(latitude: Double, longitude: Double, completionHandlerForSession: @escaping (_ success: Bool, _ photosArray: [[String: AnyObject]]?, _ errorString: String?) -> Void) {
        let methodParameters = [
            FlickrParameterKeys.Method: FlickrParameterValues.SearchMethod,
            FlickrParameterKeys.APIKey: FlickrParameterValues.APIKey,
            FlickrParameterKeys.BoundingBox: bboxString(latitude: latitude, longitude: longitude),
            FlickrParameterKeys.SafeSearch: FlickrParameterValues.UseSafeSearch,
            FlickrParameterKeys.Extras: FlickrParameterValues.MediumURL,
            FlickrParameterKeys.Format: FlickrParameterValues.ResponseFormat,
            FlickrParameterKeys.NoJSONCallback: FlickrParameterValues.DisableJSONCallback,
            FlickrParameterKeys.PerPage: FlickrParameterValues.PerPageValue
        ]
        let _ = taskForGETMethod(parameters: methodParameters as [String : AnyObject]) { (results, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            if error != nil {
                completionHandlerForSession(false, nil, "Search failed.")
            } else {
                print(results as Any)
                if let photosDictionary = results?[FlickrResponseKeys.Photos] as? NSDictionary {
                    if let photosArray = photosDictionary[FlickrResponseKeys.Photo] as? [[String: AnyObject]] {
                        completionHandlerForSession(true, photosArray, nil)
                    } else {
                        print("Could not find \(FlickrResponseKeys.Photo) in \(results!)")
                        completionHandlerForSession(false, nil, "Get photo array failed.")
                    }
                } else {
                    print("Could not find \(FlickrResponseKeys.Photos) in \(results!)")
                    completionHandlerForSession(false, nil, "Get photos dictionary failed.")
                }
            }
        }
    }
    
    private func bboxString(latitude: Double, longitude: Double) -> String {
        // ensure bbox is bounded by minimum and maximums
        let minimumLon = max(longitude - Constants.SearchBBoxHalfWidth, Constants.SearchLonRange.0)
        let minimumLat = max(latitude - Constants.SearchBBoxHalfHeight, Constants.SearchLatRange.0)
        let maximumLon = min(longitude + Constants.SearchBBoxHalfWidth, Constants.SearchLonRange.1)
        let maximumLat = min(latitude + Constants.SearchBBoxHalfHeight, Constants.SearchLatRange.1)
        return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
    }
}
