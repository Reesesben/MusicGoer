//
//  Location.swift
//  Thursday Afternoon Project
//
//  Created by Delstun McCray on 9/17/21.
//

import Foundation
import CoreLocation
///Holds 2D location and name
class Location: NSObject {
    let title: String
    let coordinates: CLLocationCoordinate2D
    
    init(title: String, coordinates: CLLocationCoordinate2D) {
        self.title = title
        self.coordinates = coordinates
    }
}
