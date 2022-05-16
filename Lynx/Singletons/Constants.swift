//
//  Constants.swift
//  Lynx
//
//  Created by Pietro on 16/05/22.
//

import Foundation
import MapKit
import UIKit

class Constants{
    static let shared = Constants()
    
    let same_photo_place_distance = 1500.0
    let sameSpotDistance = 0.25 //nm
    let webSite_url = "http://windmaster.ai:3000/"
    let points_filename = "pointsData.json"
    let locations_filename = "locations.json"
    let route_min_distance = 5.0
    let meters_to_nm = 0.00053996
    let fast_sailing = CLLocationCoordinate2D(latitude: 37.695670, longitude: 24.060816)
    let fast_sailing_location: Location!
    let startColor = UIColor.red
    let endColor = UIColor.orange
    let sameSpotSpeed = 1.3
    
    
    private init(){
        self.fast_sailing_location = Location(coord: self.fast_sailing, name: "Fast Sailing, Olyimpic Marine")
    }
}
