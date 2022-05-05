//
//  database.swift
//  LynxTracker
//
//  Created by Pietro on 04/05/22.
//

import Foundation

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


func getData (url: String, start: String, end: String) async throws -> Array<coord> {
    var url = "http://windmaster.ai/"+url
    url =  url + "?start=" + start + "&end=" + end
    var out: [coord] = []
    
    guard let url = URL(string: url) else{
        print("invalid url")
        return out
    }
    
    let (data, _) = try await URLSession.shared.data(from: url)
    let parsedJSON = try JSONDecoder().decode([coord].self, from: data)
    out = parsedJSON
    
    
    return out
}
