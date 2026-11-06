//
//  RoomAmenity.swift
//  Rooms
//
//  Created by Nicole Xie on 06/11/2026.
//

/// Amenities backed by the room's facility metadata.
public enum RoomAmenity: String, CaseIterable, Identifiable, Sendable {
  case writingBoard
  case charging
  case microphone
  case projector
  case airConditioning
  case audioLoop

  // MARK: Public

  public var id: Self { self }

  public var displayName: String {
    switch self {
    case .writingBoard: "Writing board"
    case .charging: "Charging / power"
    case .microphone: "Microphone"
    case .projector: "Projector"
    case .airConditioning: "Air conditioning"
    case .audioLoop: "Audio loop"
    }
  }

  public func isAvailable(in room: Room) -> Bool {
    switch self {
    case .writingBoard:
      room.writingMedia.contains { $0.lowercased().contains("whiteboard") || $0.lowercased().contains("blackboard") }

    case .charging:
      room.accessibility.contains {
        $0.lowercased().contains("power at wall") || $0.lowercased().contains("power at seat")
      }

    case .microphone:
      (room.microphone + room.infoTechnology).contains {
        $0.lowercased().contains("microphone") || $0.lowercased().contains("lavalier")
      }

    case .projector:
      (room.audioVisual + room.infoTechnology).contains { $0.lowercased().contains("projector") }

    case .airConditioning:
      room.accessibility.contains { $0.lowercased().contains("air conditioning") }

    case .audioLoop:
      room.accessibility.contains { $0.lowercased().contains("audio loop") }
    }
  }
}
