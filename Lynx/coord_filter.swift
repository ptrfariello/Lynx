//
//  coord_filter.swift
//  LynxTracker
//
//  Created by Pietro on 04/05/22.
//

import Foundation
import MapKit

func coord_to_display(start: String, end: String) async ->[CLLocationCoordinate2D]{
    var out: [CLLocationCoordinate2D]  = []
    do{
    let input = try await getData(url: "coords", start: start, end: end)
    var points: [CLLocationCoordinate2D] = []
    for point in input{
        let coord = CLLocationCoordinate2D(latitude: point.Lat, longitude: point.Long)
        points.append(coord)
    }
    out = points
    }catch{}
    return out
}
