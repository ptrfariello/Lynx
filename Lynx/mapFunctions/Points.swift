//
//  PlacesMarkersFunctions.swift
//  Lynx
//
//  Created by Pietro on 09/05/22.
//

import Foundation
import MapKit


let fullISO8610Formatter = DateFormatter()

struct database_point: Codable{
    var Time: String? = ""
    var SOG: Float? = 0.0
    var COG: Float? = 0.0
    var Lat: Double? = 0.0
    var Long: Double? = 0.0
    var TWS: Float? = 0.0
    var TWA: Float? = 0.0
    var TWD: Float? = 0.0
    var Depth: Float? = 0.0
    var Temp: Float? = 0.0
}

struct storage_point: Codable{
    var Time: Date
    var SOG: Float
    var COG: Float
    var Lat: Double
    var Long: Double
    var TWS: Float
    var TWA: Float
    var TWD: Float
    
    init(place: Point) {
        self.Time = place.time
        self.SOG = place.sog
        self.COG = place.cog
        self.Lat = place.lat
        self.Long = place.lon
        self.TWS = place.tws
        self.TWA = place.twa
        self.TWD = place.twd
    }
}

class Point: NSObject, MKAnnotation {

    public var title: String?
    var time: Date
    var sog: Float = 0.0
    var cog: Float = 0.0
    var lat: Double = 0.0
    var lon: Double = 0.0
    var tws: Float = 0.0
    var twa: Float = 0.0
    var twd: Float = 0.0
    var depth: Float = 0.0
    var temp: Float = 0.0
    var color: UIColor = UIColor.gray
    var to_print: String = ""
    var locationName = ""
    
    public var coordinate: CLLocationCoordinate2D
    
    init(time: Date, sog: Float, cog: Float, lat: Double, lon:Double, tws: Float, twa: Float, twd: Float){
        self.time = time
        self.sog = sog
        self.cog = cog
        self.lat = lat
        self.lon = lon
        self.tws = tws
        self.twa = twa
        self.twd = twd
        self.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        
    }
    
    init(time: Date, coord: CLLocationCoordinate2D){
        self.time = time
        self.coordinate = coord
    }
    
    init(crd: database_point){
        self.time = fullISO8610Formatter.date(from: crd.Time ?? "") ?? Date.distantFuture
        self.twd = crd.TWD ?? 0
        self.twa = crd.TWA ?? 0
        self.tws = crd.TWS ?? 0
        self.lon = crd.Long ?? 0
        self.lat = crd.Lat ?? 0
        self.cog = crd.COG ?? 0
        self.sog = crd.SOG ?? 0
        self.depth = crd.Depth ?? 0
        self.coordinate = CLLocationCoordinate2D(latitude: crd.Lat ?? 0, longitude: crd.Long ?? 0)
    }
    
    init(point: storage_point){
        self.time = point.Time
        self.twd = point.TWD
        self.twa = point.TWA
        self.tws = point.TWS
        self.lon = point.Long
        self.lat = point.Lat
        self.cog = point.COG
        self.sog = point.SOG
        self.coordinate = CLLocationCoordinate2D(latitude: point.Lat, longitude: point.Long)
    }
    
    func getLocationName(savedLocation: [Location]){
        if self.locationName.count > 3 {return}
        if let location = select_location(coordinates: self.coordinate, locations: savedLocation)?.1{
            self.locationName = location.name
        }
    }
    
    
    func getCoord() -> CLLocationCoordinate2D{
        return self.coordinate
    }
}


func distance(p1: Point, p2: Point)->Double{
   return MKMapPoint(p1.coordinate).distance(to: MKMapPoint(p2.coordinate))
}

func avgSpeed(p1: Point, p2: Point)->Double{
    let dist = distance(p1: p1, p2: p2)*Constants.shared.meters_to_nm
    var time = p2.time - p1.time
    if abs(time)*1000<1{return 0}
    time = time / (60 * 60)
    return abs(dist/time)
}

func sameSpot(p1: Point, p2: Point)->Bool{
    return avgSpeed(p1: p1, p2: p2) < Constants.shared.sameSpotSpeed
}


func get_angle(point1: Point, point2: Point, point3: Point, min_distance: Double)->Double{
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

func delete_imp(points: [Point], num: Int, min_dist: Double, angle: Double, s: Double)->[Point]{
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

func place_avg(places: [Point])-> Point{
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
    return Point(time: date, coord: coord)
}

func select_points(points: [Point], from:Date, to:Date)->[Point]{
        var out = points.filter{$0.time > from && $0.time < to}
        out = out.sorted(by: { $0.time < $1.time })
        return out
}


