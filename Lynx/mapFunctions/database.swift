//
//  database.swift
//  LynxTracker
//
//  Created by Pietro on 04/05/22.
//

import Foundation
import CoreLocation
import MapKit

struct coord: Codable{
    let Time: String
    let SOG: Float
    let COG: Float
    let Lat: Double
    let Long: Double
    let TWS: Float
    let TWA: Float
    let TWD: Float
}

@objc class Place: NSObject, MKAnnotation {
    var title: String?
    
    var time: Date
    var sog: Float?
    var cog: Float?
    var lat: Double?
    var lon: Double?
    var tws: Float?
    var twa: Float?
    var twd: Float?
    
    var coordinate: CLLocationCoordinate2D
    
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
    
    func getCoord() -> CLLocationCoordinate2D{
        return self.coordinate
    }
}



func getData (url: String, start: String, end: String) async throws -> [Place] {
    var url = "http://windmaster.ai/"+url
    //var url = "http://10.0.16.17:3000/"+url
    url =  url + "?start=" + start + "&end=" + end
    var out: [Place] = []
    
    guard let url = URL(string: url) else{
        print("invalid url")
        return out
    }
    
    let (data, _) = try await URLSession.shared.data(from: url)
    let parsedJSON = try JSONDecoder().decode([coord].self, from: data)
    let fullISO8610Formatter = DateFormatter()
    fullISO8610Formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    for point in parsedJSON{
        let date = fullISO8610Formatter.date(from: point.Time)
        if date != nil{
        out.append(Place(time: date!, sog: point.SOG, cog: point.COG, lat: point.Lat, lon: point.Long, tws: point.TWS, twa: point.TWA, twd: point.TWD))
        }
    }
    
    return out
}
