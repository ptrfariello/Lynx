//
//  helper_functions.swift
//  Lynx
//
//  Created by Pietro on 06/05/22.
//

import Foundation


func deg2rad(_ number: Double) -> Double {
    return number * Double.pi / 180
}



func extract_coord_Json(data: Data) throws -> [Place]{
    var out: [Place] = []
    let parsedJSON = try JSONDecoder().decode([coord].self, from: data)
    fullISO8610Formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    for point in parsedJSON{
        out.append(Place(crd: point))
    }
    return out
}

func myRound(value: Float, decimalPlaces: Float = 1.0)-> Float {
    let powerTen = pow(10, decimalPlaces)
    return round(powerTen * value) / powerTen;
}









