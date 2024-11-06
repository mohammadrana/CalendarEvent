# CalendarEvent
To request permissions in Swift for Calendar, you need to use the respective EventKit frameworks.

Include the corresponding entries in your app’s Info.plist for user-facing permissions:

<key>NSCalendarsUsageDescription</key>
<string>We need access to your calendar to sync your events.</string>

To add more functionality to manage calendar events, I’ll expand the EventManager class that:

1. Retrieves a list of calendars and displays them.
2. Allows selection and removal of specific calendars.
3. Creates a new calendar.
4. Adds an event with an alert to a chosen calendar.
5. Handles repeated events and advanced deletion options.

I have the EventManager class, you can use it to display calendars, create events, and delete them.

Summary of Methods
1. fetchCalendars: Retrieves the list of calendars on the device.
2. createCalendar: Creates a new calendar with a specified name and color.
3. getCalendarID: Get the calendar ID for a given calendar name.
4. calendarIsExist: Calendar exist with a given calendar name.
5. getCalendarEventsList: Get the calendar event list for a given calendar array.
6. saveCalendarObject: Save the selected calendar object.
7. saveCalendarObjects: Save the selected calendar object list.
8. getCalendarObjects: Get the all selected calendar object list.
9. removeCalendarObject: Remove the selected calendar object.
10. clearCalendarObjects: Remove all the selected calendar object list.
11. removeCalendar: Deletes a calendar by its identifier.
12. addRecursiveEvent: Adds an event with alert and recurrence options to a specified calendar.
13. addEvent: Adds an event with alert to a specified calendar.
14. removeAllEvents: Deletes all events with a specific title from a calendar.
15. removeEvent: Deletes a single event by its identifier.

This code flow allows your app to manage calendar data efficiently, providing robust options for event scheduling and calendar management.
