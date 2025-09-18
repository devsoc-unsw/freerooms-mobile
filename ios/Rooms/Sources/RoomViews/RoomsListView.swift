//
//  RoomsListView.swift
//  Rooms
//
//  Created by Yanlin Li  on 17/9/2025.
//
import BuildingModels
import CommonUI
import RoomModels
import RoomViewModels
import SwiftUI

// MARK: - RoomsListView

public struct RoomsListView: View {

  // MARK: Lifecycle

  public init(
    roomViewModel: RoomViewModel,
    building: Building,
    path: Binding<NavigationPath>,
    imageProvider: @escaping (String) -> Image)
  {
    self.roomViewModel = roomViewModel
    self.building = building
    _path = path
    self.imageProvider = imageProvider
  }

  // MARK: Public

  public var body: some View {
    let rooms = roomViewModel.roomsByBuildingId[building.id] ?? []

    return List {
      imageProvider(building.id)
        .resizable()
        .frame(height: screenHeight / 4)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .listRowInsets(EdgeInsets()) // remove default list padding
        .listRowBackground(Color.clear) // optional, to keep background consistent
        .padding(.bottom)

      ForEach(rooms) { room in
        GenericListRowView(
          path: $path,
          rowHeight: $rowHeight,
          room: room,
          rooms: rooms,
          imageProvider: { roomID in
            RoomImage[roomID]
          })
          .padding(.vertical, 5)
      }
    }
    .toolbar {
      HStack {
        Button {
          roomViewModel.getRoomsInOrder()
        } label: {
          Image(systemName: "arrow.up.arrow.down")
            .resizable()
            .frame(width: 25, height: 20)
        }
      }
      .padding(.trailing, 10)
      .foregroundStyle(theme.label.tertiary)
    }
    .background(Color(UIColor.systemGroupedBackground))
  }

  // MARK: Internal

  @Binding var path: NavigationPath
  @State var rowHeight: CGFloat?

  let screenHeight = UIScreen.main.bounds.height

  let imageProvider: (String) -> Image

  // MARK: Private

  @Environment(Theme.self) private var theme

  private var roomViewModel: RoomViewModel
  private var building: Building

}

// MARK: - PreviewWrapper

private struct PreviewWrapper: View {
  @State var path = NavigationPath()

  var body: some View {
    RoomsListView(
      roomViewModel: PreviewRoomViewModel(),
      building: Building(name: "AGSM", id: "K-B16", latitude: 0, longitude: 0, aliases: [], numberOfAvailableRooms: 1),
      path: $path, imageProvider: {
        RoomImage[$0] // This closure captures BuildingImage
      })
      .defaultTheme()
  }
}

#Preview {
  PreviewWrapper()
}
