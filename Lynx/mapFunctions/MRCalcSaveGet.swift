//
//  MRCalcSaveGet.swift
//  Lynx
//
//  Created by Pietro on 14/05/22.
//

import Foundation


let route_min_distance = 5.0
let meters_to_nm = 0.00053996

func getMarkersRoutes(points: [Point])->([StopMarker], [Route]){
    var markers: [StopMarker], routes: [Route]
    let result = markersRoutes(points: points)
    markers = result.0
    routes = result.1
    return (markers, routes)
}

func selectMarkersRoutes(markers: [StopMarker], routes: [Route], start: Date, end: Date)->([StopMarker], [Route]){
    let markers = select_markers(markers: markers, from: start, to: end)
    let routes = select_routes(routes: routes, from: start, to: end)
    return (markers, routes)
}

func markersRoutes(points: [Point])->([StopMarker], [Route]){
    var dist = 0.0
    var routeDist = 0.0
    var j=0
    var routes: [Route] = []
    var startPoint: Point!
    
    var spot = false
    var markers: [StopMarker] = []
    if points.count < 2{
        return (markers, routes)
    }
    for i in 0...points.count-1-1 {
        let point = points[i]
        let nextPoint = points[i+1]
        let distance = distance(p1: point, p2: nextPoint)
        dist += distance; routeDist += distance
        
        let basePoint = points[i-j]
        if sameSpot(p1: point, p2: nextPoint){
            let stay = (nextPoint.time - basePoint.time)/60
            j+=1
            if stay > 45 && !spot{
                spot = true
                routeDist = routeDist*meters_to_nm
                if startPoint != nil && routeDist > route_min_distance{
                    routes.append(Route(start: startPoint, end: basePoint, dist: routeDist))
                }
                let place = StopMarker(spot: points[i-j/2], dep: point.time)
                markers.append(place)
                routeDist = 0
            }
        }else{
            if spot{
                startPoint = point
                let place = StopMarker(spot: basePoint, dep: point.time)
                _ = markers.popLast()
                markers.append(place)
                routeDist = 0
            }
            spot = false
            j = 0
        }
    }
    let OlympicMarine = StopMarker(spot: Point(time: Date.now, coord: fast_sailing), dep: Date.now)
    OlympicMarine.stays = 0
    OlympicMarine.locationName = "Fast Sailing, Olympic Marine"
    markers.append(OlympicMarine)
    return (markers, routes)
}
