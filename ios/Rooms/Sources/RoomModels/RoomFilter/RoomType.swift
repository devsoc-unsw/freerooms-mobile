//
//  RoomType.swift
//  Rooms
//
//  Created by Yanlin Li  on 18/5/2026.
//

import Foundation

/// Represents different types of rooms with their display names and usage codes
public enum RoomType: String, CaseIterable, Identifiable {
  case auditorium = "AUD"
  case computerLab = "CMLB"
  case laboratory = "LAB"
  case lectureHall = "LCTR"
  case meetingRoom = "MEET"
  case studio = "SDIO"
  case tutorialRoom = "TUSM"
  case libraryStudyRoom = "LIB"

  // MARK: Public

  public var id: String { rawValue }

  public var displayName: String {
    switch self {
    case .auditorium:
      "Auditorium"
    case .computerLab:
      "Computer Lab"
    case .laboratory:
      "Laboratory"
    case .lectureHall:
      "Lecture Hall"
    case .meetingRoom:
      "Meeting Room"
    case .studio:
      "Studio"
    case .tutorialRoom:
      "Tutorial Room"
    case .libraryStudyRoom:
      "Library Study Room"
    }
  }
}
