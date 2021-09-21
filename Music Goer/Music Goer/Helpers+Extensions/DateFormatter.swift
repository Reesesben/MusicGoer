//
//  DateFormatter.swift
//  Thursday Afternoon Project
//
//  Created by Delstun McCray on 9/17/21.
//

import Foundation

extension DateFormatter {
    static let eventTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
}

extension Date {
    
    func dateAsString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
}
