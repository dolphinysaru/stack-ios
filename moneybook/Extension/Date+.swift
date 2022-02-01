//
//  Date+.swift
//  moneybook
//
//  Created by jedmin on 2022/01/02.
//

import Foundation

extension Date {
    static var todayString: String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    
    var toString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        let dateString = dateFormatter.string(from: self)
        return dateString
    }
    
    var toInt: Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let dateString = dateFormatter.string(from: self)
        return Int(dateString) ?? 0
    }
    
    func toString(with format: String = "yyyy-MM-dd") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        let dateString = dateFormatter.string(from: self)
        return dateString
    }
    
    var toShortString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        let dateString = dateFormatter.string(from: self)
        return dateString
    }
    
    var toMediumString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        let dateString = dateFormatter.string(from: self)
        return dateString
    }
    
    var toUTCString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter.string(from: self)
    }
}

extension Date {
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }

    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
}

extension Date {
    func dayNumberOfWeek() -> Int {
        return (Calendar.current.dateComponents([.weekday], from: self).weekday ?? 1) - 1
    }
}

extension Date {
    func getDate(format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        let year = dateFormatter.string(from: self)
        return year
    }
    
    var thisMonth: String {
        getDate(format: "MM")
    }

    var thisYear: String {
        getDate(format: "yyyy")
    }
}
