//
//  DateTimeParser.swift
//  RideWorld
//
//  Created by Владислав Пуличев on 29.04.17.
//  Copyright © 2017 Владислав Пуличев. All rights reserved.
//

import DateToolsSwift

struct DateTimeParser {
  
  /// Parsing dateTime from string. Returns user friendly date as string
  static func getDateTime(from dateTime: String) -> String {
    let dateInCurrentTimeZone = stringToDate(dateTime)
    var dateInCurrentTimeZoneString: String!
    
    if (countOfDaysFromToday(for: dateInCurrentTimeZone) <= 3) {
      dateInCurrentTimeZoneString = dateInCurrentTimeZone.timeAgoSinceNow
    } else {
      dateInCurrentTimeZoneString = getUserFriendDateString(to: dateTime)
    }
    
    return dateInCurrentTimeZoneString
  }
  
  /// Converting string date from firebase database to Date
  static func stringToDate(_ str: String) -> Date {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss +zzzz"
    
    guard let formattedDate = formatter.date(from: str) else {
      formatter.dateFormat = "yyyy-MM-dd HH:mm:ss a +zzzz"
      formatter.amSymbol = "AM"
      formatter.pmSymbol = "PM"
      
      guard let formattedDateWithAMPM = formatter.date(from: str) else {
        return Date()
      }
      
      return formattedDateWithAMPM
    }
    
    return formattedDate
  }
  
  static func countOfDaysFromToday(for date: Date) -> Int {
    let calendar = NSCalendar.current
    
    // Replace the hour (time) of both dates with 00:00
    let date1 = calendar.startOfDay(for: date)
    let date2 = calendar.startOfDay(for: Date()) // today
    
    let components = calendar.dateComponents([.day], from: date1, to: date2)
    
    return components.value(for: .day)!
  }
  
  /// Returns date as string with MMM d, yyyy format
  private static func getUserFriendDateString(to date: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss +zzzz"
    if let date = dateFormatter.date(from: date) {
      dateFormatter.dateFormat = "MMM d, yyyy"
      return dateFormatter.string(from: date)
    } else {
      return ""
    }
  }
}
