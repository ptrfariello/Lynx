//
//  shareddata.swift
//  Lynx
//
//  Created by Pietro on 16/05/22.
//

import Foundation
import UIKit

class sharedData{
    static let shared = sharedData()
    
    var startDate: Date = Date.now.addingTimeInterval(-3600*24*14)
    var endDate: Date = Date.now
    
    var locations: [Location] = get_saved_locations() ?? [Constants.shared.fast_sailing_location]
    var points: [Point] = get_saved_points()
    
    
    private init(){}
    
}
