//
//  database.swift
//  LynxTracker
//
//  Created by Pietro on 04/05/22.
//

import Foundation
import CoreLocation
import MapKit
import CoreData


let webSite_url = "http://windmaster.ai:3000/"

struct coord: Codable{
    var Time: String
    var SOG: Float
    var COG: Float
    var Lat: Double
    var Long: Double
    var TWS: Float
    var TWA: Float
    var TWD: Float
    
    init(time: String, sog: Float, cog: Float, lat: Double, lon:Double, tws: Float, twa: Float, twd: Float) {
        self.Time = time
        self.SOG = sog
        self.COG = cog
        self.Lat = lat
        self.Long = lon
        self.TWS = tws
        self.TWA = twa
        self.TWD = twd
    }
}

public class Place: NSObject, MKAnnotation {

    public var title: String?
    var time: Date
    var sog: Float? = 0.0
    var cog: Float? = 0.0
    var lat: Double? = 0.0
    var lon: Double? = 0.0
    var tws: Float? = 0.0
    var twa: Float? = 0.0
    var twd: Float? = 0.0
    
    enum Key:String{
        case title = "title"
        case time = "time"
        case sog = "sog"
        case cog = "cog"
        case lat = "lat"
        case lon = "lon"
        case tws = "tws"
        case twa = "twa"
        case twd = "twd"
    }
    
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
    
    func toCoord() -> coord {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        let time = date_to_iso(date: self.time)
        let coord = coord(time: time, sog: self.sog ?? 0, cog: self.cog ?? 0, lat: self.lat ?? 0, lon: self.lon ?? 0, tws: self.tws ?? 0, twa: self.twa ?? 0, twd: self.twd ?? 0)
        return coord
    }
    
    init(time: Date, coord: CLLocationCoordinate2D){
        self.time = time
        self.coordinate = coord
    }
    
    init(crd: coord){
        let fullISO8610Formatter = DateFormatter()
        fullISO8610Formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        self.time = fullISO8610Formatter.date(from: crd.Time) ?? Date.distantFuture
        self.twd = crd.TWD
        self.twa = crd.TWA
        self.tws = crd.TWS
        self.lon = crd.Long
        self.lat = crd.Lat
        self.cog = crd.COG
        self.sog = crd.SOG
        self.coordinate = CLLocationCoordinate2D(latitude: crd.Lat, longitude: crd.Long)
    }
    
    func getCoord() -> CLLocationCoordinate2D{
        return self.coordinate
    }
}



func getData (url: String, start: String, end: String) async throws -> [Place] {
    var url = webSite_url+url
    //var url = "http://10.0.16.17:3000/"+url
    url =  url + "?start=" + start + "&end=" + end
    var out: [Place] = []
    
    guard let url = URL(string: url) else{
        print("invalid url")
        return out
    }
    
    let (data, _) = try await URLSession.shared.data(from: url)
    out = try extract_Json(data: data)
    return out
}
