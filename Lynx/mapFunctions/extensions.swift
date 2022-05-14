//
//  extentions.swift
//  Lynx
//
//  Created by Pietro on 09/05/22.
//

import Foundation

extension Date {
    static func - (lhs: Date, rhs: Date) -> Double {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }
}

