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
    
    // MARK: Authentication (GET) Methods
    /*
     Method: https://www.udacity.com/api/session
     Method Type: POST
     Required Parameters:
     udacity - (Dictionary) a dictionary containing a username/password pair used for authentication
     username - (String) the username (email) for a Udacity student
     password - (String) the password for a Udacity student
     */
//    func authenticateWithViewController(_ hostViewController: UIViewController, _ params: [String: AnyObject], completionHandlerForAuth: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
//        
//        // get session ID with login and password
//        self.getSessionID(params) { (success, sessionID, userID, errorString) in
//            if success {
//                // success! we have the sessionID!
//                self.sessionID = sessionID
//                self.userID = userID
//                completionHandlerForAuth(success, errorString)
//            } else {
//                completionHandlerForAuth(success, errorString)
//            }
//        }
//    }
//
//    private func getSessionID(_ params: [String: AnyObject], completionHandlerForSession: @escaping (_ success: Bool, _ sessionID: String?, _ userID: String?, _ errorString: String?) -> Void) {
//
//        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
//        let jsonBody = "{\"\(JSONBodyKeys.Udacity)\": {\"\(JSONBodyKeys.Username)\": \"\(params["email"] ?? "email" as AnyObject)\", \"\(JSONBodyKeys.Password)\": \"\(params["password"] ?? "password" as AnyObject)\"}}"
//        /* 2. Make the request */
//        let _ = taskForPOSTMethod(Methods.AuthenticationSession, parameters: nil, jsonBody: jsonBody) { (results, error) in
//
//            /* 3. Send the desired value(s) to completion handler */
//            if error != nil {
//                completionHandlerForSession(false, nil, nil, "Login Failed.")
//            } else {
//                if let session = results?[UdacityClient.JSONResponseKeys.Session] as? NSDictionary, let account = results?[UdacityClient.JSONResponseKeys.Account] as? NSDictionary {
//                    if let sessionID = session[UdacityClient.JSONResponseKeys.SessionID] as? String, let userID = account[UdacityClient.JSONResponseKeys.RegisteredKey] as? String {
//                        completionHandlerForSession(true, sessionID, userID, nil)
//                    } else {
//                        print("Could not find \(UdacityClient.JSONResponseKeys.SessionID) in \(results!)")
//                        completionHandlerForSession(false, nil, nil, "Login Failed (SessionID).")
//                    }
//                } else {
//                    print("Could not find \(UdacityClient.JSONResponseKeys.Session) in \(results!)")
//                    completionHandlerForSession(false, nil, nil, "Login Failed (Session).")
//                }
//            }
//        }
//    }

    private func searchByLatLon(latitude: Double, longitude: Double, completionHandlerForSession: @escaping (_ success: Bool, _ sessionID: String?, _ userID: String?, _ errorString: String?) -> Void) {
        let methodParameters = [
            FlickrParameterKeys.Method: FlickrParameterValues.SearchMethod,
            FlickrParameterKeys.APIKey: FlickrParameterValues.APIKey,
            FlickrParameterKeys.BoundingBox: bboxString(latitude: latitude, longitude: longitude),
            FlickrParameterKeys.SafeSearch: FlickrParameterValues.UseSafeSearch,
            FlickrParameterKeys.Extras: FlickrParameterValues.MediumURL,
            FlickrParameterKeys.Format: FlickrParameterValues.ResponseFormat,
            FlickrParameterKeys.NoJSONCallback: FlickrParameterValues.DisableJSONCallback
        ]
        let _ = taskForGETMethod("hello", parameters: methodParameters as [String : AnyObject]) { (results, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            if error != nil {
                completionHandlerForSession(false, nil, nil, "Login Failed.")
            } else {
                if let session = results?[FlickrResponseKeys.Status] as? NSDictionary, let account = results?[FlickrResponseKeys.Status] as? NSDictionary {
                    if let sessionID = session[FlickrResponseKeys.Status] as? String, let userID = account[FlickrResponseKeys.Status] as? String {
                        completionHandlerForSession(true, sessionID, userID, nil)
                    } else {
                        print("Could not find \(FlickrResponseKeys.Status) in \(results!)")
                        completionHandlerForSession(false, nil, nil, "Login Failed (SessionID).")
                    }
                } else {
                    print("Could not find \(FlickrResponseKeys.Status) in \(results!)")
                    completionHandlerForSession(false, nil, nil, "Login Failed (Session).")
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
