//
//  MRCalcSaveGet.swift
//  Lynx
//
//  Created by Pietro on 14/05/22.
//

import Foundation
import MapKit



func selectMarkersRoutes(markers: [StopMarker], routes: [Route], start: Date, end: Date)->([StopMarker], [Route]){
    let markers = select_markers(markers: markers, from: start, to: end)
    let routes = select_routes(routes: routes, from: start, to: end)
    return (markers, routes)
}

func getMarkersRoutes(points: [Point])->([StopMarker], [Route]){
    var routeDist = 0.0
    var j=0
    var routes: [Route] = []
    var startPoint: Point!
    var notSameSpotCount = 0
    
    var spot = false
    var markers: [StopMarker] = []
    if points.count < 2{
        return (markers, routes)
    }
    for i in 0...points.count-1-1 {
        let point = points[i]
        let nextPoint = points[i+1]
        let dist = distance(p1: point, p2: nextPoint)
        routeDist += dist
        let basePoint = points[i-j]
        if sameSpot(p1: point, p2: nextPoint){
            let stay = (nextPoint.time - basePoint.time)/60
            j+=1
            if stay > 45 && !spot{
                notSameSpotCount = 0
                spot = true
                routeDist = routeDist*Constants.shared.meters_to_nm
                if startPoint != nil && routeDist > Constants.shared.route_min_distance{
                    routes.append(Route(start: startPoint, end: basePoint, dist: routeDist))
                }
                let place = StopMarker(spot: basePoint, dep: nextPoint.time)
                markers.append(place)
                routeDist = 0
            }
        }else{
            notSameSpotCount += 1
            if spot{
                startPoint = point
                let place = StopMarker(spot: basePoint, dep: nextPoint.time)
                markers.removeLast()
                markers.append(place)
                routeDist = 0
            }
            if notSameSpotCount > 5{
            spot = false
            j = 0
            }
        }
    }
    return (markers, routes)
}
