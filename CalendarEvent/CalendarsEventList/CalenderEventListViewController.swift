//
//  CalenderEventListViewController.swift
//  CalendarEvent
//
//  Created by Mohammad Masud Rana on 4/11/24.
//

import UIKit
import EventKit
import Foundation

class CalenderEventListViewController: UIViewController {

    @IBOutlet weak var eventListTableView: UITableView!
    
    var eventArray = [CalendarEvent]()
    var selectedCalendars = [CalendarObject]()
    var eventManager = EventManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Get selected calendars
        selectedCalendars = eventManager.getCalendarObjects()
        print("selectedCalendars #### \(selectedCalendars)")
        
        // Get selected calendars
        if selectedCalendars.count > 0 {
            eventManager.getCalendarEventsList(selectedCalendars: selectedCalendars) { events in
                self.eventArray = events
                self.eventListTableView.reloadData()
            }
        }else {
            print("You have no selected calendars.")
        }
        
        //getCalendarEventsList(selectedCalendars: selectedCalendars)
        eventListTableView.register(UINib(nibName: "EventListTableViewCell", bundle: nil), forCellReuseIdentifier: "EventListTableViewCell")
        eventListTableView.tableFooterView = UIView()
    }
    
    @IBAction func backToPrevious(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - Table view delegate and data source
extension CalenderEventListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventListTableViewCell", for: indexPath) as! EventListTableViewCell
        let calenderObj = eventArray[indexPath.row]
        
        cell.title.text = calenderObj.title
        cell.message.text = calenderObj.desc + " " + calenderObj.start_date
        
        cell.selectionStyle = .none
            
            
        return cell
 
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
      if editingStyle == .delete {
        let calenderObj = eventArray[indexPath.row]
          eventManager.removeEvent(withIdentifier: calenderObj.event_id, completion: { success, error in
            if success {
                print("Removed....")
                self.eventManager.removeCalendarObject(withIdentifier: calenderObj.event_id)
            }
        })
          
        eventArray.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
      }
    }
    
}


extension CalenderEventListViewController {
    
    // MARK: - Fetch the calendar event list for a given calendar name
    func getCalendarEventsList(selectedCalendars:[CalendarObject])
    {
        
        print("selectedCalendars  \(selectedCalendars)")
        let eventDB = EKEventStore.init()
        var calendarArray = [EKCalendar]()
        
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
            
            print(calendarArray)
            
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
            
            eventListTableView.reloadData()
        }

    }
}
