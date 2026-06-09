//
//  SheetBuildingDetails.swift
//  Buildings
//
//  Created by Dicko Evaldo on 23/10/2025.

import BuildingViewModels
import CommonUI
import RoomModels
import SwiftUI

// MARK: - SheetBuildingDetails

public struct SheetBuildingDetails<RoomDestination: View>: View {

  // MARK: Lifecycle

  public init(
    imageProvider: @escaping (String) -> CachedImage,
    roomDestinationBuilder: @escaping (Room) -> RoomDestination)
  {
    self.imageProvider = imageProvider
    self.roomDestinationBuilder = roomDestinationBuilder
  }

  // MARK: Public

  public var body: some View {
    NavigationStack(path: $path) {
      VStack(spacing: 12) {
        switch viewModel.buildingDetailsViewState {
        case .loading:
          loadedContent(
            rooms: SheetBuildingDetailsMetrics.placeholderRooms,
            isPlaceholder: true)
            .allowsHitTesting(false)
            .redacted(reason: .placeholder)

        case .loaded:
          loadedContent(
            rooms: viewModel.availableRooms,
            isPlaceholder: false)

        case .error:
          errorContent
        }
      }
      .padding(.top, SheetBuildingDetailsMetrics.contentTopPadding)
      .navigationDestination(for: Room.self) { room in
        roomDestinationBuilder(room)
          .navigationBarBackButtonHidden()
//              .toolbar() {
//                  ToolbarItem(placement: .topBarTrailing){
//                      Text("Capcity \(String(room.capacity))")
//                          .font(.caption)
//                          .foregroundStyle(.red)
//                  }
//
//              }
      }
    }
    .onChange(of: viewModel.selectedBuildingID) { _, _ in
      path = NavigationPath()
      rowHeight = nil
    }
  }

  // MARK: Private

  @Environment(LiveMapViewModel.self) private var viewModel

  @State private var path = NavigationPath()
  @State private var rowHeight: CGFloat?

  private let imageProvider: (String) -> CachedImage
  private let roomDestinationBuilder: (Room) -> RoomDestination

  private var headerSection: some View {
    HStack(alignment: .top) {
      VStack(alignment: .leading, spacing: 4) {
        Text(viewModel.selectedBuildingName)
          .font(.title)
          .fontWeight(.regular)
          .allowsHitTesting(false)

        HStack {
          Text("\(viewModel.selectedBuildingAvailableRooms) rooms available")
            .font(.subheadline)
            .allowsHitTesting(false)
          Circle()
            .fill(viewModel.selectedBuildingAvailabilityColour)
            .frame(width: 12, height: 12)
        }
      }
      Spacer()
      XButton {
        viewModel.onClearBuildingSelection()
      }
    }
    .padding(.horizontal)
  }

  // MARK: Directions Button

  private var directionsButton: some View {
    Button {
      Task {
        await viewModel.onGetDirection()
      }
    } label: {
      Label("Get Directions", systemImage: "figure.walk")
        .frame(maxWidth: .infinity, maxHeight: 8)
        .font(.footnote)
        .padding()
        .background(Theme.light.accent.primary)
        .foregroundStyle(.white)
        .cornerRadius(20)
    }
    .padding(.horizontal)
  }

  // MARK: Error

  private var errorContent: some View {
    VStack(spacing: 12) {
      headerSection
      ContentUnavailableView {
        Label("Unable to Load Rooms", systemImage: "exclamationmark.triangle.fill")
      } description: {
        Text(viewModel.buildingDetailsErrorMessage ?? "Please try again.")
      } actions: {
        Button("Try Again") {
          retryLoadingRooms()
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .padding(.horizontal)
    }
  }

  // MARK: Header

  private func loadedContent(
    rooms: [Room],
    isPlaceholder: Bool)
    -> some View
  {
    Group {
      headerSection
      buildingImageSection(isPlaceholder: isPlaceholder)
      directionsButton
      buildingContentSection(
        rooms: rooms,
        isPlaceholder: isPlaceholder)
    }
  }

  // MARK: Building Image

  @ViewBuilder
  private func buildingImageSection(isPlaceholder: Bool) -> some View {
    if isPlaceholder {
      RoundedRectangle(cornerRadius: 5)
        .fill(Color.gray.opacity(0.2))
        .frame(maxWidth: .infinity)
        .frame(height: SheetBuildingDetailsMetrics.imageHeight)
        .padding(.horizontal)
    } else if let buildingID = viewModel.selectedBuildingID {
      BuildingImage[buildingID]
        .aspectRatio(contentMode: .fill)
        .frame(maxWidth: .infinity)
        .frame(height: SheetBuildingDetailsMetrics.imageHeight)
        .clipShape(RoundedRectangle(cornerRadius: 5))
        .allowsHitTesting(false)
        .padding(.horizontal)
    }
  }

  // MARK: Room List

  @ViewBuilder
  private func buildingContentSection(
    rooms: [Room],
    isPlaceholder: Bool)
    -> some View
  {
    if viewModel.selectedBuildingID != nil {
      if rooms.isEmpty, !isPlaceholder {
        ContentUnavailableView(
          "No Available Rooms",
          systemImage: "door.left.hand.closed",
          description: Text("All rooms are currently occupied."))

      } else {
        List {
          ForEach(rooms) { room in
            GenericListRowView(
              path: $path,
              rowHeight: $rowHeight,
              room: room,
              rooms: rooms,
              isLoading: isPlaceholder || viewModel.isLoadingAvailableRoom,
              imageProvider: { roomID in
                if isPlaceholder {
                  CachedImage(name: String(describing: roomID), bundle: .module)
                } else {
                  imageProvider(roomID)
                }
              })
          }
        }
        .scrollContentBackground(.hidden)
        .contentMargins(.top, 0, for: .scrollContent)
      }
    }
  }

  private func retryLoadingRooms() {
    guard let buildingID = viewModel.selectedBuildingID else { return }
    Task {
      await viewModel.onSelectBuilding(buildingID)
    }
  }
}

// MARK: - SheetBuildingDetailsMetrics

private enum SheetBuildingDetailsMetrics {

  // MARK: Internal

  static let contentTopPadding: CGFloat = 8
  static let imageHeight: CGFloat = 150

  static let placeholderRooms: [Room] = [
    placeholderRoom(id: "placeholder-room-1", name: "Placeholder Room Name"),
    placeholderRoom(id: "placeholder-room-2", name: "Placeholder Room Name"),
    placeholderRoom(id: "placeholder-room-3", name: "Placeholder Room Name"),
    placeholderRoom(id: "placeholder-room-4", name: "Placeholder Room Name"),
  ]

  // MARK: Private

  private static func placeholderRoom(
    id: String,
    name: String)
    -> Room
  {
    Room(
      abbreviation: name,
      accessibility: [],
      audioVisual: [],
      buildingId: "placeholder-building",
      capacity: 0,
      floor: nil,
      id: id,
      infoTechnology: [],
      latitude: 0,
      longitude: 0,
      microphone: [],
      name: name,
      school: "",
      seating: nil,
      usage: "",
      service: [],
      writingMedia: [],
      status: .available)
  }
}
