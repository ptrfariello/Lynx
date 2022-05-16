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



func extract_coord_Json(data: Data) throws -> [Point]{
    var out: [Point] = []
    let parsedJSON = try JSONDecoder().decode([database_point].self, from: data)
    fullISO8610Formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    for point in parsedJSON{
        out.append(Point(crd: point))
    }
    return out
}

func myRound(value: Float, decimalPlaces: Float = 1.0)-> Float {
    let powerTen = pow(10, decimalPlaces)
    return round(powerTen * value) / powerTen;
}

func radiansToDegrees(radians: Double) -> Double { return radians * 180.0 / .pi }


extension Array {
    var middle: Element? {
        guard count != 0 else { return nil }
        let middleIndex = (count > 1 ? count - 1 : count) / 2
        return self[middleIndex]
    }

}







