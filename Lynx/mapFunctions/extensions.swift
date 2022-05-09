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
extension Array where Element: FloatingPoint {
    
    var sum: Element {
        return reduce(0, +)
    }

    var average: Element {
        guard !isEmpty else {
            return 0
        }
        return sum / Element(count)
    }
}
