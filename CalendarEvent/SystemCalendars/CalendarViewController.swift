//
//  CalendarViewController.swift
//  CalendarEvent
//
//  Created by Mohammad Masud Rana on 30/10/24.
//

import UIKit
import EventKit

class CalendarViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var submitBtn: UIButton!
    
    let eventManager = EventManager()
    var calenderList = [CalendarObject]()
    var didSelectCalendars  : (([CalendarObject])->())?
    var selectedCalendars = [CalendarObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        selectedCalendars = eventManager.getCalendarObjects()
        print("selectedCalendars  \(selectedCalendars)")
        getTheListOfCalendar()
        tableView.register(UINib(nibName: "CalendarSourceCell", bundle: nil), forCellReuseIdentifier: "CalendarSourceCell")
        tableView.tableFooterView = UIView()
        submitBtn.layer.cornerRadius = 7.0
    }
    
    // MARK: - Fetch the list of calendars
    func getTheListOfCalendar() {
        eventManager.requestAccess { granted, error in
            if granted {
                self.loadCalendars(skipAppCalendar: false)
            } else if let error = error {
                self.requestAccessToCalendar()
                print("Access denied: \(error.localizedDescription)")
            }
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        //self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Request for Calendar access
    func requestAccessToCalendar() {
        EKEventStore().requestAccess(to: .event, completion: {
            (accessGranted: Bool, error: Error?) in
            
            if accessGranted == true {
                DispatchQueue.main.async(execute: {
                    self.loadCalendars(skipAppCalendar: false)
                })
            } else {
                DispatchQueue.main.async(execute: {
                    print("Workopolo needs access to calender for syncing event.")
                })
            }
        })
    }
    
    // MARK: - Fetch all available calendars with some skip calendars
    func loadCalendars(skipAppCalendar: Bool) {
        let calendars = eventManager.fetchCalendars()
        for calendar in calendars {
            print(calendar.title)
            
            
            if(skipAppCalendar ? calendar.title == Constants.calenderName :  calendar.title ==  "" || calendar.title == "Siri Suggestions" || calendar.title == "Birthdays" || calendar.title == "Contacts" || calendar.title == "Family" || calendar.title.contains("Holidays"))
            {
                continue
            }
            
            print("calendar.title  \(calendar.title)")
            
            var obj = CalendarObject()
            obj.name = calendar.title
            obj.identifier = calendar.calendarIdentifier
            for calendar in selectedCalendars {
                if calendar.identifier == obj.identifier, calendar.isSelected == true {
                    obj.isSelected = true
                }
            }
            calenderList.append(obj)
            
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
    }
    
    @IBAction func submitBtnAction(_ sender: Any) {
//        var selectedCalenders = [CalendarObject]()
//        for obj in calenderList
//        {
//            if(obj.isSelected)
//            {
//                selectedCalenders.append(obj)
//            }
//        }
//        
//        print("calenderList  \(calenderList)")
//          // Remove all calendars objects
//        eventManager.clearCalendarObjects()
//          // Save all new calendars objects
//        eventManager.saveCalendarObjects(selectedCalenders)
        
        self.dismiss(animated: true) {
            //self.didSelectCalendars?(selectedCalenders)
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "CalenderEventListViewController") as! CalenderEventListViewController
            self.navigationController?.pushViewController(vc, animated: true)
       }
    }

}

// MARK: - TableViewDelegate and TableViewDataSource
extension CalendarViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return calenderList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CalendarSourceCell", for: indexPath) as! CalendarSourceCell
        let calenderObj = calenderList[indexPath.row]
        
        cell.calendarName.text = calenderObj.name
            
        if(calenderObj.isSelected)
        {
            cell.sourceSelected.isHidden = false
        }
        else
        {
            cell.sourceSelected.isHidden = true
        }
        
        cell.selectionStyle = .none
            
            
        return cell
 
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell : CalendarSourceCell = tableView.cellForRow(at: indexPath) as! CalendarSourceCell
        
        let calenderObj = calenderList[indexPath.row]
        
        if(calenderObj.isSelected)
        {
            cell.sourceSelected.isHidden = true
            var obj = CalendarObject()
            
            obj.name = calenderObj.name
            obj.identifier = calenderObj.identifier
            obj.isSelected = false
            
            calenderList.remove(at: indexPath.row)
            calenderList.insert(obj, at: indexPath.row)
            
            // Remove caledar from save list
            eventManager.removeCalendarObject(withIdentifier: obj.identifier)
        }
        else
        {
            cell.sourceSelected.isHidden = false
            
            var obj = CalendarObject()
            obj.name = calenderObj.name
            obj.identifier = calenderObj.identifier
            obj.isSelected = true
            
            calenderList.remove(at: indexPath.row)
            calenderList.insert(obj, at: indexPath.row)
            
            // Add calendar to save list
            eventManager.saveCalendarObject(obj)
        }
    }
}
