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
    var avgSpeed: Float = 0.0
    var maxSpeed: Point?
    
    init(start: StopMarker, end: StopMarker, dist: Double){
        self.startMarker = start
        self.endMarker = end
        self.start = start.departure[0]
        self.end = end.arrival[0]
        self.length = dist
        self.startMarker.color = UIColor.green
        self.endMarker.color = UIColor.blue
        var time = self.end - self.start
        time = time / (60 * 60)
        self.avgSpeed = Float(abs(self.length / time))
    }
    
    func loadData(){
        let start_string = date_to_iso(date: self.start)
        let end_string = date_to_iso(date: self.end)
        Task{
            do{
                self.avgSpeed = try await getData(url: "avgSpeed", start: start_string, end: end_string)[0].sog
                self.maxSpeed = try await getData(url: "maxSpeed", start: start_string, end: end_string)[0]
            }
        }
    }
    
 
}


func getRoutes(markers: [StopMarker], lengths: [Double])->[Route]{
    var routes: [Route] = []
    if markers.count<2{
        return routes
    }
    for i in 0...markers.count-3{
        let route = Route(start: markers[i], end: markers[i+1], dist: lengths[i+1])
        if route.length > 5{
            routes.append(route)
        }
    }
    return routes
}
