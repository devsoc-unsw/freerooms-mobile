//
//  BookingListGrouping.swift
//  Bookings
//
//  Created by Yanlin Li  on 8/8/2025.
//

import BookingModels
import Foundation

// MARK: - BookingDayGroup

struct BookingDayGroup: Identifiable, Equatable {
  let date: Date
  let bookings: [WeeklyBooking]

  var id: Date { date }
}

// MARK: - BookingListGrouping

enum BookingListGrouping {
  /// Groups by local start-of-day and sorts both sections and rows chronologically.
  static func groups(
    from bookings: [WeeklyBooking],
    calendar: Calendar)
    -> [BookingDayGroup]
  {
    Dictionary(grouping: bookings) {
      calendar.startOfDay(for: $0.start)
    }
    .map { date, bookings in
      BookingDayGroup(date: date, bookings: bookings.sorted { $0.start < $1.start })
    }
    .sorted { $0.date < $1.date }
  }
}

// MARK: - BookingSearch

enum BookingSearch {
  /// Filters event titles using user-friendly, case- and diacritic-insensitive matching.
  static func filter(_ bookings: [WeeklyBooking], query: String) -> [WeeklyBooking] {
    let query = query.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !query.isEmpty else { return bookings }

    return bookings.filter {
      $0.title.range(
        of: query,
        options: [.caseInsensitive, .diacriticInsensitive]) != nil
    }
  }
}
