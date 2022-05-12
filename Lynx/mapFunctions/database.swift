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


func getData (url: String, start: String, end: String) async throws -> [Point] {
    var url = webSite_url+url
    //var url = "http://10.0.16.17:3000/"+url
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

