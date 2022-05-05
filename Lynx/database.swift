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


func getData (url: String, start: String, end: String) -> Array<coord> {
    var url = "http://10.0.16.17:3000/"+url
    url =  url + "?start=" + start + "&end=" + end
    var out: [coord] = []
    if let url = URL(string: url) {
       URLSession.shared.dataTask(with: url) {data, response, error in
    if let data = data {
        let jsonDecoder = JSONDecoder()
        do {
        let parsedJSON = try jsonDecoder.decode([coord].self, from: data)
            out = parsedJSON
                } catch {
        print(error)
                }
               }
       }.resume()
    }
    return out
}
