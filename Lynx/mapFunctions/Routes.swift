//
//  Routes.swift
//  Lynx
//
//  Created by Pietro on 13/05/22.
//

import Foundation
import UIKit

class Route{
    var startPoint: Point
    var endPoint: Point
    var start: Date
    var end: Date
    var length: Double = 0.0
    var avgSpeed: Float = 0.0
    var maxSpeed: Point?
    
    init(start: Point, end: Point, dist: Double){
        self.startPoint = start
        self.endPoint = end
        self.start = start.time
        self.end = end.time
        self.length = dist
        var time = self.end - self.start
        time = time / (60 * 60)
        self.avgSpeed = Float(abs(self.length / time))
    }
    
    
    func loadData(){
        let start_string = date_to_iso(date: self.start)
        let end_string = date_to_iso(date: self.end)
        Task{
                self.avgSpeed = try await getMapData(url: "avgSpeed", start: start_string, end: end_string)[0].sog
                self.maxSpeed = try await getMapData(url: "maxSpeed", start: start_string, end: end_string)[0]
        }
    }
}



func select_routes(routes: [Route], from: Date, to: Date)->[Route]{
        let out = routes.filter{$0.start > from && $0.end < to}
        return out
}
