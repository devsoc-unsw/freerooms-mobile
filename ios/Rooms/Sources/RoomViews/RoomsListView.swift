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
    building: Building,
    path: Binding<NavigationPath>,
    imageProvider: @escaping (String) -> CachedImage)
  {
    self.building = building
    _path = path
    self.imageProvider = imageProvider
  }

  // MARK: Public

  public var body: some View {
    let rooms = roomViewModel.getDisplayedRooms(for: building.id)

    return List {
      imageProvider(building.id)
        .frame(height: screenHeight * RoomLayoutConstants.buildingHeroImageHeightFraction)
        .clipShape(RoundedRectangle(cornerRadius: RoomLayoutConstants.buildingHeroImageCornerRadius))
        .listRowInsets(EdgeInsets()) // remove default list padding
        .listRowBackground(Color.clear) // optional, to keep background consistent
        .padding(.bottom)

      ForEach(rooms) { room in
        GenericListRowView(
          path: $path,
          rowHeight: $rowHeight,
          room: room,
          rooms: rooms,
          isLoading: roomViewModel.isLoading,
          imageProvider: { roomID in
            RoomImage[roomID]
          })
          .padding(.vertical, RoomLayoutConstants.listRowVerticalPadding)
      }
      .redacted(reason: roomViewModel.isLoading ? .placeholder : [])
    }
    .refreshable {
      Task {
        await roomViewModel.reloadRooms()
      }
    }
    .background(InteractivePopGestureEnabler())
    .navigationBarBackButtonHidden(true)
    .toolbar {
      ToolbarItem(placement: .topBarLeading) {
        Button("Back", systemImage: "chevron.left") {
          dismiss()
        }
        .padding(.vertical, 4)
        .font(.title2)
        .buttonBorderShape(.circle)
        .liquidGlass(
          glass: {
            $0
          },
          fallback: {
            $0
              .padding(8)
              .buttonStyle(.borderedProminent)
              .tint(theme.background.primary.opacity(0.8))
              .foregroundStyle(theme.accent.primary)
          })
      }

      ToolbarItem(placement: .topBarTrailing) {
        HStack {
          Button {
            roomViewModel.getRoomsInOrder()
          } label: {
            Image(systemName: "arrow.up.arrow.down")
              .resizable()
              .frame(width: RoomLayoutConstants.toolbarSortIconWidth, height: RoomLayoutConstants.toolbarIconHeight)
          }
        }
        .padding(RoomLayoutConstants.toolbarIconPadding)
        .foregroundStyle(theme.accent.primary)
      }
    }
    .scrollContentBackground(.hidden)
    .background(theme.background.primary)
  }

  // MARK: Internal

  @Binding var path: NavigationPath
  @State var rowHeight: CGFloat?

  let screenHeight = UIScreen.main.bounds.height

  let imageProvider: (String) -> CachedImage

  // MARK: Private

  @Environment(\.dismiss) private var dismiss
  @Environment(Theme.self) private var theme
  @Environment(LiveRoomViewModel.self) private var roomViewModel

  private var building: Building

}

// MARK: - InteractivePopGestureEnabler

private struct InteractivePopGestureEnabler: UIViewControllerRepresentable {
  final class Controller: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
      navigationController?.interactivePopGestureRecognizer?.isEnabled = true
      navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
  }

  func makeUIViewController(context _: Context) -> Controller {
    Controller()
  }

  func updateUIViewController(_: Controller, context _: Context) { }
}

// MARK: - PreviewWrapper

private struct PreviewWrapper: View {
  @State var path = NavigationPath()

  var body: some View {
    let viewModel: LiveRoomViewModel = PreviewRoomViewModel()
    return RoomsListView(
      building: Building(name: "AGSM", id: "K-B16", latitude: 0, longitude: 0, aliases: [], numberOfAvailableRooms: 1),
      path: $path, imageProvider: {
        RoomImage[$0] // This closure captures BuildingImage
      })
      .environment(viewModel)
      .defaultTheme()
  }
}

#Preview {
  PreviewWrapper()
}
