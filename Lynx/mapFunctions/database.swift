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





func getMapData (url: String, start: String, end: String) async throws -> [Point] {
    var url = Constants.shared.webSite_url+url
    url =  url + "?start=" + start + "&end=" + end
    var out: [Point] = []
    
    guard let url = URL(string: url) else{
        print("invalid url")
        return out
    }
    
    let (data, _) = try await URLSession.shared.data(from: url)
    out = try extract_coord_Json(data: data)
    return out
}

func getLocationsData() async throws -> [Location] {
    let url = Constants.shared.webSite_url+"locations/get"
    var out: [Location] = []
    
    guard let url = URL(string: url) else{
        print("invalid url")
        return out
    }
    print(url)
    let (data, _) = try await URLSession.shared.data(from: url)
    out = try extract_location_Json(data: data)
    return out
}


func setLocationData(lat: Double, lon: Double, name: String) async throws {
    var url = Constants.shared.webSite_url+"locations/set"
    if let name = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed){
        url =  url + "?lat=" + String(lat) + "&lon=" + String(lon) + "&name=" + name
        guard let url = URL(string: url) else{
            print("invalid url")
            return
        }
        let (_, _) = try await URLSession.shared.data(from: url)
    }
}




