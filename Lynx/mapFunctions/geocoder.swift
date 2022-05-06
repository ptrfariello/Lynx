//
//  geocoder.swift
//  Lynx
//
//  Created by Pietro on 06/05/22.
//

import Foundation
import MapKit


func geoCode(location: CLLocationCoordinate2D, marker_text: UILabel){
    var out = ""
    let geocoder = CLGeocoder()
    let location = CLLocation(latitude: location.latitude, longitude: location.longitude)
    geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
        for placemark in placemarks! {
            let sea = placemark.ocean ?? ""
            var name = placemark.name ?? ""
            var locality = placemark.locality ?? ""
            let gr = placemark.isoCountryCode ?? ""
            if (locality == name){locality = ""}
            if (sea == name){name = ""}
            out = sea
            out = (name != "") ? out+", \(name)" : out
            out = (locality != "") ? out+", \(locality)" : out
            out = (gr != "") ? out+", \(gr)" : out
            marker_text.text = out
        }
    })
}
