//
//  BookingTestDoubles.swift
//  Bookings
//
//  Created by Yanlin Li  on 7/8/2025.
//

import BookingModels
import Foundation

// MARK: - BookingFixtures

public enum BookingFixtures {
  public static func weeklyBooking(
    title: String = "Exams T3",
    start: Date = Date(timeIntervalSince1970: 1_798_128_000),
    duration: TimeInterval = 2 * 60 * 60)
    -> WeeklyBooking
  {
    WeeklyBooking(
      title: title,
      bookingType: "EXAMS",
      roomID: "K-H6-LG03",
      roomName: "Tyree Energy Technology LG03",
      buildingID: "K-H6",
      buildingName: "Tyree Energy Technologies Building",
      start: start,
      end: start.addingTimeInterval(duration),
      usage: "TUSM",
      capacity: 50,
      abbreviation: "TETBLG03")
  }
}
