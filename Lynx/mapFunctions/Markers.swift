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
    
    
    init(spot: Point, dep: Date) {
        self.arrival = [spot.time]
        self.departure = [dep]
        super.init(time: spot.time, coord: spot.coordinate)
    }
    
    
    func print_info()->String{
        var txt = ""
        for (i, arr) in self.arrival.enumerated() {
            let stay = departure[i]-arr
            //let date = arrival.addingTimeInterval(stay/2)
            let date = arr
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





func marker_return(markers: [StopMarker])->[StopMarker]{
    var uniqueMarkers: [[Int]] = [[]]
    var toReturn: [StopMarker] = []
    
    for marker in markers {
        uniqueMarkers.append(markers.indices.filter({distance(p1: marker, p2: markers[$0]) < Constants.shared.sameSpotDistance/Constants.shared.meters_to_nm}))
    }
    
    for markersIndices in Array(Set(uniqueMarkers)) {
        if markersIndices.count<1{continue}
        let to_add = markers[markersIndices[0]]
        var arrivals: [Date] = [], departures: [Date] = []
        for index in markersIndices {
            arrivals.append(markers[index].arrival[0])
            departures.append(markers[index].departure[0])
        }
        to_add.arrival = arrivals
        to_add.departure = departures
        to_add.title = to_add.arrival.count > 1 ? "\(to_add.arrival.count)" : ""
        toReturn.append(to_add)
    }
    return toReturn
}

func select_markers(markers: [StopMarker], from: Date, to: Date)->[StopMarker]{
        let out = markers.filter{$0.arrival[0] > from && $0.departure[0] < to}
        return out
}





