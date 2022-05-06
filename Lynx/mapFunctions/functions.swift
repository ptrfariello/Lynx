//
//  helper_functions.swift
//  Lynx
//
//  Created by Pietro on 06/05/22.
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
}
func distance(p1: Place, p2: Place)->Double{
   return MKMapPoint(p1.coordinate).distance(to: MKMapPoint(p2.coordinate))
}
func avgSpeed(p1: Place, p2: Place)->Double{
    let dist = distance(p1: p1, p2: p2)*0.000539957
    var time = p2.time - p1.time
    if time*1000<1{return Double.infinity}
    time = time / (60 * 60)
    return dist/time
}
func sameSpot(p1: Place, p2: Place)->Bool{
    return avgSpeed(p1: p1, p2: p2) < 3.3
}

func markers(points: [Place])->[Marker]{
    var j=0
    var spot = false
    var markers: [Marker] = []
    for i in 0...points.count-2 {
        let point = points[i]
        let nextPoint = points[i+1]
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
    return markers
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
        marker.title = String(marker.stays)
    }
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
        print(fraction)
        fraction = (abs(fraction)<1) ? fraction : 1
        let angle = acos(fraction)
        print(angle)
        return angle
    }
    return 0
}

func delete_imp(points: [Place], min_dist: Double, angle: Double, s: Double)->[Place]{
    var points = points
    let speed_threshold = s
    let angle_threshold = deg2rad(angle)
    var i = points.count-1
    while i > 1{
        let angle = get_angle(point1: points[i-2], point2: points[i-1], point3: points[i], min_distance: min_dist)
        if angle > (2*Double.pi-angle_threshold) || angle < angle_threshold{
            points.remove(at: i-1)
            
        }
        if i < (points.count - 1){
            if avgSpeed(p1: points[i-1], p2: points[i])>speed_threshold{
                points.remove(at: i-1)
            }
        }
        i -= 1
    }
    return points
}

func deg2rad(_ number: Double) -> Double {
    return number * Double.pi / 180
}

extension Date {
    static func - (lhs: Date, rhs: Date) -> Double {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }
}

extension Array where Element: FloatingPoint {
    
    var sum: Element {
        return reduce(0, +)
    }

    var average: Element {
        guard !isEmpty else {
            return 0
        }
        return sum / Element(count)
    }

}
