//
//  coord_filter.swift
//  LynxTracker
//
//  Created by Pietro on 04/05/22.
//

import Foundation
import MapKit

func coord_to_display(start: String, end: String)->[CLLocationCoordinate2D]{
    let input = getData(url: "coords", start: start, end: end)
    var points: [CLLocationCoordinate2D] = []
    for point in input{
        points.append(CLLocationCoordinate2D(latitude: point.Lat, longitude: point.Long))
    }
    return points
}
