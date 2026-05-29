//
//  RoomDetailsSheetView.swift
//  Rooms
//
//  Created by Yanlin Li  on 18/9/2025.
//

import CommonUI
import RoomModels
import RoomViewModels
import SwiftUI

struct RoomDetailsSheetView: View {

  // MARK: Lifecycle

  public init(dateSelect: Date = Date(), room: Room, roomViewModel: RoomViewModel, isFavourite: Binding<Bool>, onDismiss: (() -> Void)? = nil) {
    self.dateSelect = dateSelect
    self.room = room
    self.roomViewModel = roomViewModel
    _isFavourite = isFavourite
    self.onDismiss = onDismiss
  }

  // MARK: Internal

  @State var dateSelect = Date()

  let room: Room

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      // List {
      // Booking informations
      RoomBookingInformationView(room: room, currentRoomRating: roomViewModel.currentRoomRating, isFavourite: $isFavourite)

      // Booking interactive section
      VStack(alignment: .leading, spacing: 16) {
        HStack {
          Text("Room Bookings")
            .font(.headline)
            .foregroundStyle(.primary)

          Spacer()

          DatePicker("Please Select a Date", selection: $dateSelect, displayedComponents: .date)
            .labelsHidden()
            .tint(theme.accent.primary)
        }

        // Booking Grid
        ScrollView {
          RoomBookingsListView(
            room: room,
            roomViewModel: roomViewModel,
            dateSelect: $dateSelect)
        }
      }
      .padding()
      .overlay(
        RoundedRectangle(cornerRadius: RoomLayoutConstants.bookingSectionCornerRadius)
          .strokeBorder(LinearGradient(
            colors: [
              theme.accent.secondary,
              theme.accent.primary,
            ],
            startPoint: .top,
            endPoint: .bottom))
          .stroke(Color.gray.secondary, lineWidth: 1))
    }
    .padding()
    .task {
      await roomViewModel.fetchRoomRating(roomID: room.id)
    }
    .gesture(
      DragGesture(minimumDistance: RoomLayoutConstants.dismissDragMinimumDistance, coordinateSpace: .local)
        .onEnded { value in
          if
            value.translation.width > RoomLayoutConstants.dismissDragMinimumWidth,
            value.translation.width > abs(value.translation.height)
          {
            onDismiss?()
          }
        })
  }

  // MARK: Private

  @Environment(Theme.self) private var theme

  @Binding private var isFavourite: Bool
  private let onDismiss: (() -> Void)?

  private var roomViewModel: RoomViewModel

}

#Preview {
  @Previewable @State var isFavourite = false
  
  RoomDetailsSheetView(room: Room.exampleOne, roomViewModel: PreviewRoomViewModel(), isFavourite: $isFavourite)
    .defaultTheme()
}
