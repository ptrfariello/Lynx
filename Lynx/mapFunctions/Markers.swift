//
//  Markers.swift
//  Lynx
//
//  Created by Pietro on 13/05/22.
//

import Foundation
import MapKit

class StopMarker: Point{
    var arrival: [Date]
    var departure: [Date]
    var stays: Int = 1
    var data: [Float] = []
    var isData: Bool = false
    var locationName: String = ""
    
    
    init(spot: Point, dep: Date) {
        self.arrival = [spot.time]
        self.departure = [dep]
        super.init(time: spot.time, coord: spot.coordinate)
       
    }
    
    init(marker: StopMarker){
        self.arrival = marker.arrival
        self.departure = marker.departure
        self.locationName = marker.locationName
        super.init(time: marker.arrival[0], coord: marker.coordinate)
    }
    
    func print_info()->String{
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
        txt.removeLast()
        return txt
    }
    
    func geoCode(){
        var out = ""
        let coordinate = self.coordinate
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            if placemarks != nil{
                for placemark in placemarks! {
                    let sea = placemark.ocean ?? ""
                    var name = placemark.name ?? ""
                    var locality = placemark.locality ?? ""
                    let gr = placemark.isoCountryCode ?? ""
                    if (locality == name){locality = ""}
                    if (name == sea){name = ""}
                    out = add_to_string(base: out, add: sea)
                    out = add_to_string(base: out, add: name)
                    out = add_to_string(base: out, add: locality)
                    out = add_to_string(base: out, add: gr)
                }
            }
            self.locationName = out
        })
    }
    
}

func markers(points: [Point])->([StopMarker], [Double], Double){
    var dist = 0.0
    var routeDist = 0.0
    var j=0
    var routesLength: [Double] = []
    
    var spot = false
    var markers: [StopMarker] = []
    if points.count < 2{
        return (markers, routesLength, 0)
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
            }
        }else{
            if spot{
                let place = StopMarker(spot: basePoint, dep: point.time)
                markers.append(place)
                routeDist = routeDist*0.000539957
                routesLength.append(routeDist)
                routeDist = 0
            }
            spot = false
            j = 0
        }
    }
    let OlympicMarine = StopMarker(spot: Point(time: Date.now, coord: fast_sailing), dep: Date.now)
    OlympicMarine.stays = 0
    markers.append(OlympicMarine)
    return (markers, routesLength, dist*0.000539957)
}

func marker_return(markers: [StopMarker])->[StopMarker]{
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

func geoCodeMarkers(markers: [StopMarker]){
    Task{do{
        for marker in markers{
        marker.geoCode()
        }
    }}
}
