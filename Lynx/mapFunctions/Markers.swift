//
//  Markers.swift
//  Lynx
//
//  Created by Pietro on 13/05/22.
//

import Foundation
import MapKit

let sameSpotDistance = 0.25 //nm



class StopMarker: Point{
    var arrival: [Date]
    var departure: [Date]
    var stays: Int = 1
    
    
    init(spot: Point, dep: Date) {
        self.arrival = [spot.time]
        self.departure = [dep]
        super.init(time: spot.time, coord: spot.coordinate)
    }
    
    
    func print_info()->String{
        
        var txt = ""
        for (i, arrival) in arrival.enumerated() {
            let stay = departure[i]-arrival
            let date = arrival.addingTimeInterval(stay)
            if stay/60 < 46.0 {return "Haven't left yet"}
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
    
}

struct geocodedLocation: Codable{
    var lat = 0.0
    var lon = 0.0
    var locationName = ""
    
    init(coord: CLLocationCoordinate2D, name: String){
        self.lat = coord.latitude
        self.lon = coord.longitude
        self.locationName = name
    }
}


func marker_return(markers: [StopMarker])->[StopMarker]{
    var markers = markers
    var i = markers.count-1
    while i > 0{
        let marker1 = markers[i]
        for k in (0...i-1).reversed(){
            let marker2 = markers[k]
            let dist = distance(p1: marker1, p2: marker2)*meters_to_nm
            if dist < sameSpotDistance {
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
    //markers.last?.arrival.remove(at: 0)
    //markers.last?.departure.remove(at: 0)
    return markers
}

func select_markers(markers: [StopMarker], from: Date, to: Date)->[StopMarker]{
        let out = markers.filter{$0.arrival[0] > from && $0.departure[0] < to}
        return out
}



