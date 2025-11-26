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

  public init(dateSelect: Date = Date(), room: Room, roomViewModel: RoomViewModel, onDismiss: (() -> Void)? = nil) {
    self.dateSelect = dateSelect
    self.room = room
    self.roomViewModel = roomViewModel
    self.onDismiss = onDismiss
  }

  // MARK: Internal

  @State var dateSelect = Date()

  let room: Room

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      // List {
      // Booking informations
      RoomBookingInformationView(room: room)

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
        RoundedRectangle(cornerRadius: 12)
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
    .gesture(
      DragGesture(minimumDistance: 20, coordinateSpace: .local)
        .onEnded { value in
          if value.translation.width > 50 && value.translation.width > abs(value.translation.height)
          {
            onDismiss?()
          }
        }
    )
  }

  // MARK: Private

  private let onDismiss: (() -> Void)?

  @Environment(Theme.self) private var theme

  private var roomViewModel: RoomViewModel

}

#Preview {
  RoomDetailsSheetView(room: Room.exampleOne, roomViewModel: PreviewRoomViewModel())
    .defaultTheme()
}
