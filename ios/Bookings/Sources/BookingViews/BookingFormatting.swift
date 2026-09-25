//
//  BookingFormatting.swift
//  Bookings
//
//  Created by Yanlin Li  on 8/8/2025.
//

import BookingModels
import Foundation

enum BookingFormatting {

  // MARK: Internal

  struct Facility: Identifiable {
    let name: String
    let symbol: String

    var id: String { name }
  }

  static func locationDescription(for booking: WeeklyBooking) -> (String, String) {
    guard let buildingName = booking.buildingName, !buildingName.isEmpty else {
      return (booking.roomName, "")
    }

    return (booking.roomName, buildingName)
  }

  static func sectionTitle(for date: Date) -> String {
    date.formatted(.dateTime.weekday(.wide).month(.abbreviated).day())
  }

  static func timeRange(for booking: WeeklyBooking, calendar _: Calendar = .current) -> String {
    let formatter = DateFormatter()

    #warning(" New feature to allow user toggle different date format")
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "h:mm a"
    return "\(formatter.string(from: booking.start)) – \(formatter.string(from: booking.end))"
  }

  static func fullDate(for date: Date) -> String {
    date.formatted(.dateTime.weekday(.wide).day().month(.wide).year())
  }

  static func capacity(for booking: WeeklyBooking) -> String {
    "\(booking.capacity) people"
  }

  static func spansMultipleDays(_ booking: WeeklyBooking, calendar: Calendar = .current) -> Bool {
    !calendar.isDate(booking.start, inSameDayAs: booking.end)
  }

  static func fieldLabel(_ label: String) -> String {
    label.uppercased()
  }

  static func fieldAccessibilityLabel(label: String, value: String) -> String {
    "\(label), \(value)"
  }

  static func facilities(for booking: WeeklyBooking) -> [Facility] {
    let groups: [(items: [String], symbol: String)] = [
      (booking.writingMedia, "pencil.and.outline"),
      (booking.audioVisual, "tv"),
      (booking.infoTechnology, "desktopcomputer"),
      (booking.microphone, "mic"),
      (booking.accessibility, "figure.roll"),
      (booking.service, "wrench.and.screwdriver"),
    ]
    return groups.flatMap { group in
      group.items.compactMap { item in
        let name = item.trimmingCharacters(in: .whitespacesAndNewlines)
        return Facility(name: name, symbol: facilitySymbol(for: name, fallback: group.symbol))
      }
    }
  }

  // MARK: Private

  private static func facilitySymbol(for name: String, fallback: String) -> String {
    let name = name.lowercased()
    if name.contains("air conditioning") { return "snowflake" }
    if name.contains("power") { return "powerplug" }
    if name.contains("weekend") { return "calendar" }
    if name.contains("camera") { return "video" }
    if name.contains("projector") { return "videoprojector" }
    return fallback
  }
}
