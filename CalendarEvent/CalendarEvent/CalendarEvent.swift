//
//  CalendarEvent.swift
//  CalendarEvent
//
//  Created by Mohammad Masud Rana on 04/11/24.
//

import Foundation


class CalendarEvent : NSObject {
    var title : String = ""
    var start_date : String = ""
    var end_date : String = ""
    var calendar_id : String = ""
    var event_id : String = ""
    var desc : String = ""
    var lat : Double = -99.0
    var lon : Double = -99.0
    var timezone : String = ""
    var remind_before : Int = -99
    var locationName : String = ""
}




