//
//  EventManager.swift
//  CalendarEvent
//
//  Created by Mohammad Masud Rana on 29/10/24.
//

import Foundation
import EventKit
import UIKit

class EventManager {
    private let eventStore = EKEventStore()
    
    // Request access to the calendar
    func requestAccess(completion: @escaping (Bool, Error?) -> Void) {
        eventStore.requestAccess(to: .event) { granted, error in
            completion(granted, error)
        }
    }
    
    // Create a new calendar
    func createCalendar(name: String, color: UIColor, completion: @escaping (Bool, Error?) -> Void) {
        guard let source = eventStore.defaultCalendarForNewEvents?.source else {
            completion(false, NSError(domain: "EventManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "No default calendar source found."]))
            return
        }
        
        let calendar = EKCalendar(for: .event, eventStore: eventStore)
        calendar.title = name
        calendar.source = source
        calendar.cgColor = color.cgColor
        
        do {
            try eventStore.saveCalendar(calendar, commit: true)
            completion(true, nil)
        } catch let error {
            completion(false, error)
        }
    }
    
    // Remove a specific calendar by ID
    func removeCalendar(calendarIdentifier: String, completion: @escaping (Bool, Error?) -> Void) {
        guard let calendar = eventStore.calendar(withIdentifier: calendarIdentifier) else {
            completion(false, NSError(domain: "EventManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "Calendar not found."]))
            return
        }
        
        do {
            try eventStore.removeCalendar(calendar, commit: true)
            completion(true, nil)
        } catch let error {
            completion(false, error)
        }
    }
    
    // Create an event with optional alert and recurrence
    func createEvent(
        title: String,
        notes: String?,
        startDate: Date,
        endDate: Date,
        alertMinutesBefore: Int,
        recurrenceDays: [EKRecurrenceDayOfWeek]?,
        completion: @escaping (Bool, Error?) -> Void
    ) {
        eventStore.requestAccess(to: .event) { granted, error in
            guard granted else {
                completion(false, error)
                return
            }
            
            let event = EKEvent(eventStore: self.eventStore)
            event.title = title
            event.notes = notes
            event.startDate = startDate
            event.endDate = endDate
            event.calendar = self.eventStore.defaultCalendarForNewEvents
            
            // Add alert
            let alarm = EKAlarm(relativeOffset: TimeInterval(-alertMinutesBefore * 60))
            event.addAlarm(alarm)
            
            // Add custom recurrence rule
            if let days = recurrenceDays, !days.isEmpty {
                let recurrenceRule = EKRecurrenceRule(recurrenceWith: .weekly, interval: 1, daysOfTheWeek: days, daysOfTheMonth: nil, monthsOfTheYear: nil, weeksOfTheYear: nil, daysOfTheYear: nil, setPositions: nil, end: nil)
                event.addRecurrenceRule(recurrenceRule)
            }
            
            // Save event
            do {
                try self.eventStore.save(event, span: .thisEvent)
                
                var eventArray:[EventModel] = UserDefaults.standard.object(forKey: "AddedEvent") as? [EventModel] ?? []
                eventArray.append(EventModel(event_id: event.eventIdentifier))
                UserDefaults.standard.set(eventArray, forKey: "AddedEvent")
                UserDefaults.standard.synchronize()
                
                completion(true, nil)
            } catch let error {
                completion(false, error)
            }
        }
    }
    
    // Add an event to a specified calendar with alert and recurrence
    func addEventWithCalendar(
        title: String,
        notes: String?,
        startDate: Date,
        endDate: Date,
        alertMinutesBefore: Int,
        recurrenceDays: [EKRecurrenceDayOfWeek]?,
        calendarIdentifier: String = "",
        completion: @escaping (Bool, Error?) -> Void
    ) {
        // Use the specified calendar if provided, else use the default calendar
        let calendar = calendarIdentifier.count > 0
        ? eventStore.calendar(withIdentifier: calendarIdentifier)
        : eventStore.defaultCalendarForNewEvents
    
        guard let selectedCalendar = calendar else {
            completion(false, NSError(domain: "EventManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "No calendar found."]))
            return
        }
        
        // Check if an event with the same title exists in the date range
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: [selectedCalendar])
        let existingEvents = eventStore.events(matching: predicate).filter { $0.title == title }
        
        if !existingEvents.isEmpty {
            // If an event with the same title and date range exists, do not create a new one
            completion(false, NSError(domain: "EventManager", code: 409, userInfo: [NSLocalizedDescriptionKey: "Event with the same title already exists in the specified date range."]))
            return
        }
        
        // If no event exists, create a new one
        let event = EKEvent(eventStore: eventStore)
        event.title = title
        event.notes = notes
        event.startDate = startDate
        event.endDate = endDate
        event.calendar = selectedCalendar
        
        // Add alert
        let alarm = EKAlarm(relativeOffset: TimeInterval(-alertMinutesBefore * 60))
        event.addAlarm(alarm)
        
        // Add custom recurrence rule if specified
        if let days = recurrenceDays, !days.isEmpty {
            let recurrenceRule = EKRecurrenceRule(recurrenceWith: .weekly, interval: 1, daysOfTheWeek: days, daysOfTheMonth: nil, monthsOfTheYear: nil, weeksOfTheYear: nil, daysOfTheYear: nil, setPositions: nil, end: nil)
            event.addRecurrenceRule(recurrenceRule)
        }
        
        do {
            try eventStore.save(event, span: .thisEvent)
            completion(true, nil)
        } catch let error {
            completion(false, error)
        }
    }

    // Remove all events in a specific calendar with a certain title
    func removeAllEvents(withTitle title: String, calendarIdentifier: String = "", startDate: Date = Date.now, endDate: Date = Date.distantFuture, completion: @escaping (Bool, Error?) -> Void) {
        
        // Use the specified calendar if provided, else use the default calendar
        let calendar = calendarIdentifier.count > 0
        ? eventStore.calendar(withIdentifier: calendarIdentifier)
        : eventStore.defaultCalendarForNewEvents
                
        guard let selectedCalendar = calendar else {
            completion(false, NSError(domain: "EventManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "No calendar found."]))
            return
        }
                
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: [selectedCalendar])
        let events = eventStore.events(matching: predicate).filter { $0.title == title }
        print("events  \(events)")
        
        do {
            for event in events {
                try eventStore.remove(event, span: .thisEvent)
            }
            completion(true, nil)
        } catch let error {
            completion(false, error)
        }
    }
    
    // Remove a specific event by identifier
    func removeEvent(withIdentifier identifier: String, completion: @escaping (Bool, Error?) -> Void) {
        guard let event = eventStore.event(withIdentifier: identifier) else {
            completion(false, NSError(domain: "EventManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "Event not found"]))
            return
        }
        
        do {
            try eventStore.remove(event, span: .thisEvent)
            completion(true, nil)
        } catch let error {
            completion(false, error)
        }
    }
}

extension EventManager {
    // Fetch all available calendars
    func fetchCalendars() -> [EKCalendar] {
        return eventStore.calendars(for: .event)
    }
    
    // Function to get calendar ID by title
    func getCalendarID(byTitle title: String) -> String? {
        let calendars = eventStore.calendars(for: .event)
        return calendars.first { $0.title == title }?.calendarIdentifier
    }
    
    // MARK: - Fetch the calendar ID for a given calendar name
    func getCalendarId(byName name: String) -> String? {
        let calendars = eventStore.calendars(for: .event)
        return calendars.first { $0.title == name }?.calendarIdentifier
    }
    
    // MARK: - Check the calendar exist or not
    func calendarIsExist(byName name: String) -> Bool {
        let calendars = fetchCalendars()
        var alreadyHave = false
        for calendar in calendars {
            print(calendar.title)
            
            if(calendar.title == name) {
                alreadyHave = true
                break
            }
        }
        
        if alreadyHave { return true }
        else { return false }
    }
    
    // MARK: - Fetch the calendar event list for a given calendar name
    func getCalendarEventsList(selectedCalendars:[CalendarObject], completion: @escaping ([CalendarEvent]) -> Void)
    {
        print("selectedCalendars::::  \(selectedCalendars)")
        let eventDB = EKEventStore.init()
        var calendarArray = [EKCalendar]()
        var eventArray = [CalendarEvent]()
        
        if(selectedCalendars.count > 0)
        {
            for calendarObj in selectedCalendars
            {
                if let eventCalendar = eventDB.calendar(withIdentifier: calendarObj.identifier){
                    calendarArray.append(eventCalendar)
                }
                else
                {
                    print("Calendar not found on device")
                }
            }
            
            print("calendarArray   \(calendarArray)")
            
            let start = Date()
            let end = Calendar.current.date(byAdding: .day, value: 30, to: Date())
            
            let predicate = eventDB.predicateForEvents(withStart: start, end: end ?? Date(), calendars: calendarArray)
            
            let events = eventDB.events(matching: predicate)
            
            //var eventArray = [CalendarEvent]()
            
            for event in events {
                                
                let calEvent = CalendarEvent()
                
                
                calEvent.calendar_id = event.calendar.calendarIdentifier
                calEvent.event_id = event.eventIdentifier
                calEvent.title = event.title
                calEvent.start_date = event.startDate.toString(DateFormate.yyyy_MM_dd_HH_mm_ss) ?? ""
                calEvent.end_date = event.endDate.toString(DateFormate.yyyy_MM_dd_HH_mm_ss) ?? ""
                calEvent.desc = event.notes ?? ""
                
                calEvent.locationName =  event.location ?? ""
                var latitude = event.structuredLocation?.geoLocation?.coordinate.latitude
                var longitude = event.structuredLocation?.geoLocation?.coordinate.longitude
                
                calEvent.lat = latitude?.roundToPlaces(places: 3) ?? -99
                calEvent.lon = longitude?.roundToPlaces(places: 3) ?? -99
                calEvent.timezone = event.timeZone?.offsetInHours() ?? ""
                
                if let alert = event.alarms?.first
                {
                    print("Alarm offset value \(alert.relativeOffset)")
                    
                    let alertValue = alert.relativeOffset / -60
                    
                    calEvent.remind_before = Int(alertValue)
                    
                    print(calEvent.remind_before)
     
                }
                else
                {
                    calEvent.remind_before = -99
                }
                
                eventArray.append(calEvent)
            }
            
//            for event in eventArray
//            {
//                print(event.title)
//            }
            
            completion(eventArray)
        }
    }
    
    // MARK: - Save Single CalendarObject to UserDefaults
    func saveCalendarObject(_ newCalendarObject: CalendarObject) {
        var calendarObjects = getCalendarObjects()
        
        // Check if the object already exists based on `identifier`
        if calendarObjects.contains(where: { $0.identifier == newCalendarObject.identifier }) {
            print("Object already exists. Not saving duplicate.")
            return
        }
        
        // Add the new object
        calendarObjects.append(newCalendarObject)
        
        // Encode and save to UserDefaults
        if let encodedData = try? JSONEncoder().encode(calendarObjects) {
            UserDefaults.standard.set(encodedData, forKey: Constants.selectedCalendars)
            print("Calendar object saved successfully.")
        } else {
            print("Failed to encode calendar objects.")
        }
    }
    
    // MARK: - Save CalendarObject Array to UserDefaults
    func saveCalendarObjects(_ newCalendarObjects: [CalendarObject]) {
        // Retrieve existing objects from UserDefaults
        var existingObjects = getCalendarObjects()
        
        // Filter out duplicates from new array based on identifier
        let uniqueObjects = newCalendarObjects.filter { newObject in
            !existingObjects.contains { $0.identifier == newObject.identifier }
        }
        
        // Append unique objects to the existing list
        existingObjects.append(contentsOf: uniqueObjects)
        
        // Encode and save the updated array to UserDefaults
        if let encodedData = try? JSONEncoder().encode(existingObjects) {
            UserDefaults.standard.set(encodedData, forKey: Constants.selectedCalendars)
            print("Calendar objects saved successfully.")
        } else {
            print("Failed to encode calendar objects.")
        }
    }
    
    // MARK: - Retrieve CalendarObject Array from UserDefaults
    func getCalendarObjects() -> [CalendarObject] {
        // Decode the data from UserDefaults if available
        if let savedData = UserDefaults.standard.data(forKey: Constants.selectedCalendars),
           let calendarObjects = try? JSONDecoder().decode([CalendarObject].self, from: savedData) {
            return calendarObjects
        }
        
        return [] // Return an empty array if no data found
    }
    
    // MARK: - Remove a CalendarObject from UserDefaults
    func removeCalendarObject(withIdentifier identifier: String) {
        var calendarObjects = getCalendarObjects()
        
        // Filter out the object with the matching identifier
        calendarObjects.removeAll { $0.identifier == identifier }
        
        // Save the updated array back to UserDefaults
        if let encodedData = try? JSONEncoder().encode(calendarObjects) {
            UserDefaults.standard.set(encodedData, forKey: Constants.selectedCalendars)
            print("Calendar object removed successfully.")
        } else {
            print("Failed to encode calendar objects.")
        }
    }
    
    // MARK: - Clear All CalendarObjects from UserDefaults
    func clearCalendarObjects() {
        UserDefaults.standard.removeObject(forKey: Constants.selectedCalendars)
        print("All calendar objects have been removed.")
    }
}
