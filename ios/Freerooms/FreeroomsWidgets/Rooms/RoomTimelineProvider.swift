//
//  RoomTimelineProvider.swift
//  Freerooms
//
//  Created by Matthew Yuen on 19/9/2026.
//

import AppIntents
import Networking
import RoomModels
import RoomServices
import RoomViews
import SwiftUI
import WidgetKit

// MARK: - RoomTimelineProvider

struct RoomTimelineProvider: AppIntentTimelineProvider {

  // MARK: Lifecycle

  init() {
    roomLoader = .default
  }

  // MARK: Internal

  struct Entry: TimelineEntry {
    let date = Date()
    let value: Value

    enum Value {
      case room(Room, image: Image?)
      case missingRoom
      case failed(any Error)
    }
  }

  typealias Intent = RoomConfigurationIntent

  let roomLoader: LiveGraphQLRoomLoader

  func placeholder(in context: Context) -> Entry {
    .placeholder(family: context.family)
  }

  func snapshot(for configuration: RoomConfigurationIntent, in context: Context) async -> Entry {
    guard let selectedRoom = configuration.room else {
      return .missingRoom
    }

    do {
      #warning("TODO: Fetch ONLY the selected room status")
      let room = try await roomLoader.fetch(buildingId: selectedRoom.buildingId)
        .get()
        .first { $0.id == selectedRoom.id }
      guard let room else {
        return .missingRoom
      }
      return .room(room, family: context.family)
    } catch {
      return .failed(error)
    }
  }

  func timeline(for configuration: RoomConfigurationIntent, in context: Context) async -> Timeline<Entry> {
    guard let selectedRoom = configuration.room else {
      return .missingRoom
    }

    do {
      let room = try await roomLoader.fetch(buildingId: selectedRoom.buildingId)
        .get()
        .first { $0.id == selectedRoom.id }
      guard let room else {
        return .missingRoom
      }
      return .room(room, family: context.family)
    } catch {
      return .failed(error)
    }
  }

}

extension RoomTimelineProvider.Entry {
  static var missingRoom: Self {
    Self(value: .missingRoom)
  }

  static func placeholder(family: WidgetFamily) -> Self {
    // Use a random placeholder room
    let previewRoom = Room(
      abbreviation: "Math 101",
      accessibility: [],
      audioVisual: [],
      buildingId: "K-F23",
      capacity: 30,
      floor: "1",
      id: "K-F23-101",
      infoTechnology: [],
      latitude: -33.918793948030846,
      longitude: 151.23134411127646,
      microphone: [],
      name: "Mathematics 101",
      school: "UNSW",
      seating: "Fixed",
      usage: "LCTR",
      service: [],
      writingMedia: [])

    return .room(previewRoom, family: family)
  }

  static func failed(_ error: any Error) -> Self {
    Self(value: .failed(error))
  }

  static func room(_ room: Room, family: WidgetFamily) -> Self {
    let size = Configuration.backgroundImageSize(for: family)
    let uiImage = UIImage(named: room.id, in: .roomViews, with: nil)?
      .preparingThumbnail(of: size)
    let image = uiImage.map(Image.init(uiImage:))
    return Self(value: .room(room, image: image))
  }

}

extension Timeline<RoomTimelineProvider.Entry> {
  static var missingRoom: Self {
    Self(entries: [.missingRoom], policy: .never)
  }

  static func failed(_ error: any Error) -> Self {
    Self(entries: [.failed(error)], policy: .after(.now + Configuration.errorRetryInterval))
  }

  static func room(_ room: Room, family: WidgetFamily) -> Self {
    let reloadPolicy = TimelineReloadPolicy.after(.now + DevSoc.scraperFrequency)
    return Self(entries: [.room(room, family: family)], policy: reloadPolicy)
  }
}
