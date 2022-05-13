//
//  Routes.swift
//  Lynx
//
//  Created by Pietro on 13/05/22.
//

import Foundation
import UIKit

class Route{
    var startMarker: StopMarker
    var endMarker: StopMarker
    var start: Date
    var end: Date
    var length: Double = 0.0
    
    init(start: StopMarker, end: StopMarker, dist: Double){
        self.startMarker = start
        self.endMarker = end
        self.start = start.departure[0]
        self.end = end.arrival[0]
        self.length = dist
        self.startMarker.color = UIColor.green
        self.endMarker.color = UIColor.blue
        self.startMarker.geoCode()
        self.endMarker.geoCode()
    }
}


func getRoutes(markers: [StopMarker], lengths: [Double])->[Route]{
    var routes: [Route] = []
    for i in 0...markers.count-3{
        let route = Route(start: markers[i], end: markers[i+1], dist: lengths[i+1])
        if route.length > 1.3{
        routes.append(route)
        }
    }
    return routes
}
