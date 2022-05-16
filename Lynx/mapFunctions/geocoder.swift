//
//  geocoder.swift
//  Lynx
//
//  Created by Pietro on 06/05/22.
//

import Foundation
import MapKit




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

func geoCode(lat: Double, lon: Double) async -> String{
    var out = ""
    let geocoder = CLGeocoder()
    let location = CLLocation(latitude: lat, longitude: lon)
    let placemarks = try? await geocoder.reverseGeocodeLocation(location)
    if placemarks != nil{
        for placemark in placemarks! {
            let sea = placemark.ocean ?? ""
            var name = placemark.name ?? ""
            var locality = placemark.locality ?? ""
            //let gr = placemark.isoCountryCode ?? ""
            if (locality == name){locality = ""}
            if (name == sea){name = ""}
            out = add_to_string(base: out, add: sea)
            out = add_to_string(base: out, add: name)
            out = add_to_string(base: out, add: locality)
            //out = add_to_string(base: out, add: gr)
            out = out == "" ? "Unknown" : out
            if let index = select_location(coordinates: CLLocationCoordinate2D(latitude: lat, longitude: lon), locations: sharedData.shared.locations)?.0{
                sharedData.shared.locations[index].locationName = out
            }
            
        }
    }
    out = out == "" ? "Unknown" : out
    return out
}


