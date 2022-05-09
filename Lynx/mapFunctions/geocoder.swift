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
            var sea = placemark.ocean ?? ""
            var name = placemark.name ?? ""
            var locality = placemark.locality ?? ""
            let gr = placemark.isoCountryCode ?? ""
            if (locality == name){locality = ""}
            if (name == sea){name = ""}
            out = add_to_string(base: out, add: sea)
            out = add_to_string(base: out, add: name)
            out = add_to_string(base: out, add: locality)
            out = add_to_string(base: out, add: gr)
            marker_text.text = out
        }
    })
}

func add_to_string(base: String, add: String)->String{
    let add = (add == "Aegean Sea") ? "" : add
    if base == "" {
        return add
    }
    if add != ""{
        return "\(base), \(add)"
    }
    return base
}
