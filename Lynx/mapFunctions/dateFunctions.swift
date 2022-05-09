//
//  dateFunctions.swift
//  Lynx
//
//  Created by Pietro on 09/05/22.
//

import Foundation

func print_date(date: Date, hour: Bool) -> String{
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone(abbreviation: "EEST")
    if hour{dateFormatter.dateFormat = "HH:mm, d MMM y"}
    else {dateFormatter.dateFormat = "d MMM y"}
    return dateFormatter.string(from: date)
}

func print_time(interval: TimeInterval, minutes: Bool) -> String{
    let timeFormatter = DateComponentsFormatter()
    if minutes {timeFormatter.allowedUnits = [.hour, .minute]}
    else {timeFormatter.allowedUnits = [.hour]}
    return timeFormatter.string(from: interval) ?? ""
}

func date_to_iso(date: Date)->String{
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    return dateFormatter.string(from: date)
}

func iso_to_date(date: String)->Date{
    let fullISO8610Formatter = DateFormatter()
    fullISO8610Formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    return fullISO8610Formatter.date(from: date) ?? Date.now
}
