//
//  Utils.swift
//  CalendarEvent
//
//  Created by Mohammad Masud Rana on 5/11/24.
//

import UIKit

struct Constants {
    static let selectedCalendars = "SelectedCalendars"
    static let calenderName      = "Mohammad"
}

struct DateFormate {
    static let yyyy_MM_dd_HH_mm_ss = "yyyy-MM-dd HH:mm:ss"
}
extension TimeZone {

    func offsetFromUTC() -> String
    {
        let localTimeZoneFormatter = DateFormatter()
        localTimeZoneFormatter.timeZone = self
        localTimeZoneFormatter.dateFormat = "Z"
        return localTimeZoneFormatter.string(from: Date())
    }

    func offsetInHours() -> String
    {
    
        let hours = secondsFromGMT()/3600
        let minutes = abs(secondsFromGMT()/60) % 60
        let tz_hr = String(format: "%+.2d:%.2d", hours, minutes) // "+hh:mm"
        return tz_hr
    }
}

extension Date {
    func toString(_ formatter: String? = DateFormate.yyyy_MM_dd_HH_mm_ss ) -> String? {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = formatter
        // Set the locale to ensure consistent formatting
        dateFormatterGet.locale = Locale(identifier: "en_US_POSIX")
        dateFormatterGet.timeZone = TimeZone.current
        let myString = dateFormatterGet.string(from: self)
        return myString
    }
}

extension Double {
    /// Rounds the double to decimal places value
    mutating func roundToPlaces(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return Darwin.round(self * divisor) / divisor
    }
}

