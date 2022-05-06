//
//  coord_filter.swift
//  LynxTracker
//
//  Created by Pietro on 04/05/22.
//

import Foundation
import MapKit

func coord_to_display(input: [coord]) ->[CLLocationCoordinate2D]{
    var points: [CLLocationCoordinate2D] = []
    for point in input{
        let coord = CLLocationCoordinate2D(latitude: point.Lat, longitude: point.Long)
        points.append(coord)
    
}
    return points
}
