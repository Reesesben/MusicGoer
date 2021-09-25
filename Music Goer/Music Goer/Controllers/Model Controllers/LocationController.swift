//
//  LocationController.swift
//  Thursday Afternoon Project
//
//  Created by Delstun McCray on 9/17/21.
//

import Foundation
import CoreLocation

class LocationManager: NSObject {
    
    static let shared = LocationManager()
    
    var location: [Location] = []
    
    public func findLocations(with query: String, completion: @escaping ([Location]) -> Void) {
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(query) { places, error in
            guard let places = places, error == nil else {
                completion([])
                return
            }
            
            let models: [Location] = places.compactMap({ place in
                var name = ""
                if let locationName = place.name {
                    name += locationName
                }
                if let locality = place.locality {
                    name += ", \(locality)"
                }
                
                if let adminRegion = place.administrativeArea {
                    name += ", \(adminRegion)"
                }
                
                
                if let country = place.country {
                    name += ", \(country)"
                }
                
                print("\n\(place)\n\n")
                
                let result = Location(title: name, coordinates: place.location?.coordinate ?? CLLocationCoordinate2D.init(latitude: 0.0, longitude: 0.0))
                self.location.append(result)
                return result
            })
            
            completion(models)
        }
    }
} // End of Class
