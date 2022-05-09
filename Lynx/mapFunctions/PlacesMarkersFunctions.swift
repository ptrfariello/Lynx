//
//  PlacesMarkersFunctions.swift
//  Lynx
//
//  Created by Pietro on 09/05/22.
//

import Foundation
import MapKit


class Marker: Place{
    var arrival: [Date]
    var departure: [Date]
    var stays: Int
    
    init(spot: Place, dep: Date) {
        self.arrival = [spot.time]
        self.departure = [dep]
        self.stays = 1
        super.init(time: spot.time, coord: spot.coordinate)
    }
    
    public required convenience init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func print_info()-> String{
        var txt = ""
        for (i, arrival) in arrival.enumerated() {
            let stay = departure[i]-arrival
            let date = arrival.addingTimeInterval(stay)
            if stay>3600{
                txt = txt + print_time(interval: stay, minutes: false)+" hours"
            }else{
                txt = txt + print_time(interval: stay, minutes: true)+" minutes"
            }
            
            txt = txt + ", on " + print_date(date: date, hour: false)+"\n"
        }
        txt = txt + "\n"
        return txt
    }
}

func distance(p1: Place, p2: Place)->Double{
   return MKMapPoint(p1.coordinate).distance(to: MKMapPoint(p2.coordinate))
}

func avgSpeed(p1: Place, p2: Place)->Double{
    let dist = distance(p1: p1, p2: p2)*0.000539957
    var time = p2.time - p1.time
    if abs(time)*1000<1{return Double.infinity}
    time = time / (60 * 60)
    return abs(dist/time)
}

func sameSpot(p1: Place, p2: Place)->Bool{
    return avgSpeed(p1: p1, p2: p2) < 1.5
}

func markers(points: [Place])->([Marker], Double){
    var dist = 0.0
    var j=0
    var spot = false
    var markers: [Marker] = []
    if points.count < 2{
        return (markers, 0)
    }
    for i in 0...points.count-1-1 {
        let point = points[i]
        let nextPoint = points[i+1]
        dist += distance(p1: point, p2: nextPoint)
        let basePoint = points[i-j]
        if sameSpot(p1: point, p2: nextPoint){
            let stay = (nextPoint.time - basePoint.time)/60
            j+=1
            if stay > 45 && !spot{
                spot = true
            }
        }else{
            if spot{
                let place = Marker(spot: basePoint, dep: point.time)
                markers.append(place)
            }
            spot = false
            j = 0
        }
    }
    let OlympicMarine = Marker(spot: Place(time: Date.now, coord: fast_sailing), dep: Date.now)
    OlympicMarine.stays = 0
    markers.append(OlympicMarine)
    return (markers, dist*0.000539957)
}

func marker_return(markers: [Marker])->[Marker]{
    var markers = markers
    var i = markers.count-1
    while i > 0{
        let marker1 = markers[i]
        for k in (0...i-1).reversed(){
            let marker2 = markers[k]
            let dist = distance(p1: marker1, p2: marker2)*0.000539957
            if dist < 0.25 {
                markers[i].arrival = markers[i].arrival + markers[k].arrival
                markers[i].departure = markers[i].departure + markers[k].departure
                i -= 1
                markers.remove(at: k)
                markers[i].stays += 1
            }
        }
        i -= 1
    }
    for marker in markers {
        let stays = marker.stays
        marker.title = (stays>1) ? String(stays) : ""
    }
    markers.last?.arrival.remove(at: 0)
    markers.last?.departure.remove(at: 0)
    return markers
}

func get_angle(point1: Place, point2: Place, point3: Place, min_distance: Double)->Double{
    let side1 = distance(p1: point1, p2: point2)
    let side2 = distance(p1: point2, p2: point3)
    let side3 = distance(p1: point3, p2: point1)
    
    if [side1, side2, side3].allSatisfy({ $0 > min_distance}){
        let num = side1*side1 + side2*side2 - side3*side3
        let denom = 2 * side1 * side2
        var fraction = num/denom
        fraction = (abs(fraction)<1) ? fraction : 1
        let angle = acos(fraction)
        return angle
    }
    return 0
}

func delete_imp(points: [Place], num: Int, min_dist: Double, angle: Double, s: Double)->[Place]{
    var points = points
    let speed_threshold = s
    let angle_threshold = deg2rad(angle)
    var i = points.count-1
    while i > 1{
        let angle = get_angle(point1: points[i-2], point2: points[i-1], point3: points[i], min_distance: min_dist)
        if angle > (2*Double.pi-angle_threshold) || angle < angle_threshold{
            points.remove(at: i-1)
        }
        if i < (points.count - num - 1){
            let mean = place_avg(places: Array(points[i...i+num]))
            let avgSpeed = avgSpeed(p1: mean, p2: points[i-1])
            if avgSpeed > speed_threshold{
                points.remove(at: i-1)
            }
        }
        i -= 1
    }
    return points
}

func place_avg(places: [Place])-> Place{
    var avgInterval = 0.0
    var avgLat = 0.0
    var avgLon = 0.0
    let start = places[0].time
    for place in places{
        let interval = place.time - start
        avgLat += place.coordinate.latitude
        avgLon += place.coordinate.longitude
        avgInterval += interval
    }
    let length = Double(places.count)
    avgLon = avgLon/length
    avgLat = avgLat/length
    avgInterval = avgInterval/length
    let coord = CLLocationCoordinate2D(latitude: avgLat, longitude: avgLon)
    let date = start.addingTimeInterval(avgInterval)
    return Place(time: date, coord: coord)
}
