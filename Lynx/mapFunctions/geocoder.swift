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
