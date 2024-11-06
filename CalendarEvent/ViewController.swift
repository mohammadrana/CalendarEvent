//
//  ViewController.swift
//  CalendarEvent
//
//  Created by Mohammad Masud Rana on 29/10/24.
//

import UIKit
import EventKit

class ViewController: UIViewController {
    
    var addedEvent = [EventModel]()
    let eventManager = EventManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    // Request for Calendar permission
    @IBAction func requestCalendarPermission(_ sender: UIButton) {
        eventManager.requestAccess { granted, error in
            if granted {
                if !self.eventManager.calendarIsExist(byName: Constants.calenderName) {
                    self.eventManager.createCalendar(name: Constants.calenderName, color: UIColor.blue) { success, error in
                        if success {
                            print("Create \(Constants.calenderName) calendar")
                            self.alertShow(title: "Successfully", message: "Create \(Constants.calenderName) calendar")
                        }
                    }
                }else {
                    print("Already have Workopolo calendar")
                }
            } else if let error = error {
                print("Access denied: \(error.localizedDescription)")
            }
        }
    }
    
    @IBAction func addEvent(_ sender: Any) {
        addEvent()
    }
    
    @IBAction func addRecursiveEvent(_ sender: Any) {
        addRecursiveEvent()
    }
    
    @IBAction func removeCalendar(_ sender: Any) {
        eventManager.removeCalendar(calendarIdentifier: eventManager.getCalendarID(byTitle: Constants.calenderName) ?? "") { granted, error in
            if granted {
                print("Remove workopolo calendar")
                self.alertShow(title: "Remoced", message: "Remove \(Constants.calenderName) calendar")
            }else {
                print("Not Remove")
            }
        }
        
    }
    
    // MARK: - Remove all events in a specific calendar with a certain title
    @IBAction func removeAllEvent(_ sender: Any) {
        // Get the calendar ID for the "Constants.calenderName" calendar
        if let calendarID = eventManager.getCalendarID(byTitle: Constants.calenderName) {
            // Remove all events with the title "Custom Work Activity" in the "Work Activities" calendar
            eventManager.removeAllEvents(withTitle: "Custom Work Activity", calendarIdentifier: calendarID) { success, error in
                if success {
                    print("All events with title 'Custom Work Activity' removed from \(Constants.calenderName)' calendar.")
                    self.alertShow(title: "Removed", message: "All events with title 'Custom Work Activity' removed from \(Constants.calenderName)' calendar.")
                } else if let error = error {
                    print("Failed to remove events: \(error.localizedDescription)")
                }
            }
        } else {
            print("Calendar 'Workopolo' not found.")
        }
    }
    
    // MARK: - Add event to iPhone calendar app
    func addEvent() {
        // Request calendar access
        eventManager.requestAccess { granted, error in
            if granted {
                // Create a repeating event on Monday and Wednesday
                let title = "Custom Work Activity"
                let notes = "Details about the custom activity"
                let startDate = Calendar.current.date(byAdding: .minute, value: 16, to: Date() )!//Date()  // Replace with actual start date
                let endDate = Calendar.current.date(byAdding: .hour, value: 1, to: startDate)!
                let alertMinutesBefore = 15
                
                self.eventManager.addEventWithCalendar(title: title, notes: notes, startDate: startDate, endDate: endDate, alertMinutesBefore: alertMinutesBefore, recurrenceDays: nil, calendarIdentifier: self.eventManager.getCalendarID(byTitle: Constants.calenderName) ?? "" ) { success, error in
                    if success {
                        print("Custom repeating event created successfully!")
                        self.alertShow(title: "Successfully", message: "Custom event created successfully!")
                    } else if let error = error {
                        print("Event creation failed or already exists: \(error.localizedDescription)")
                    }
                }
            } else if let error = error {
                print("Access denied: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Add recursive event to iPhone calendar app
    func addRecursiveEvent() {
        // Request calendar access
        eventManager.requestAccess { granted, error in
            if granted {
                // Create a repeating event on Monday and Wednesday
                let title = "Custom Recursive Work Activity"
                let notes = "Details about the custom activity"
                let startDate = Calendar.current.date(byAdding: .minute, value: 16, to: Date() )!//Date()  // Replace with actual start date
                let endDate = Calendar.current.date(byAdding: .hour, value: 1, to: startDate)!
                let alertMinutesBefore = 15
                let recurrenceDays = [EKRecurrenceDayOfWeek(.sunday), EKRecurrenceDayOfWeek(.thursday)]
                
                self.eventManager.addEventWithCalendar(title: title, notes: notes, startDate: startDate, endDate: endDate, alertMinutesBefore: alertMinutesBefore, recurrenceDays: recurrenceDays, calendarIdentifier: self.eventManager.getCalendarID(byTitle: Constants.calenderName) ?? "" ) { success, error in
                    if success {
                        print("Custom repeating event created successfully!")
                        self.alertShow(title: "Successfully", message: "Custom repeating event created successfully!")
                    } else if let error = error {
                        print("Event creation failed or already exists: \(error.localizedDescription)")
                    }
                }
            } else if let error = error {
                print("Access denied: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Remove all event from iPhone calender in a specific title
    func removeAllEvents() {
        eventManager.removeAllEvents(withTitle: "Custom Work Activity", calendarIdentifier: "") { success, errorr in
            if success {
                print("Removed event")
            }else {
                print("Not Removed event")
            }
        }
    }
    
    
    @IBAction func calendarSelection(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CalendarViewController") as! CalendarViewController
        self.navigationController?.pushViewController(vc, animated: true)
        
        vc.didSelectCalendars = {(calendarList) in
            print(calendarList.count)
        }
        
    }
    
    func alertShow(title: String, message: String) {
        DispatchQueue.main.async {
            // create the alert
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }
    }

}


