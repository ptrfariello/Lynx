//
//  routesFunctions.swift
//  Lynx
//
//  Created by Pietro on 13/05/22.
//

import Foundation
import MapKit

func getBearingBetweenTwoPoints(point1 : CLLocationCoordinate2D, point2 : CLLocationCoordinate2D) -> Double {

    let lat1 = deg2rad(point1.latitude)
    let lon1 = deg2rad(point1.longitude)

    let lat2 = deg2rad(point2.latitude)
    let lon2 = deg2rad(point2.longitude)

    let dLon = lon2 - lon1

    let y = sin(dLon) * cos(lat2)
    let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
    let radiansBearing = atan2(y, x)

    return radiansToDegrees(radians: radiansBearing)
}


