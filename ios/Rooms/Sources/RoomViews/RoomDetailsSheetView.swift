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

  public init(room: Room) {
    self.room = room
  }

  // MARK: Internal

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      // Booking informations
      RoomBookingInformationView(room: room)

      // Booking interactive section
      VStack(alignment: .leading, spacing: 16) {
        HStack {
          Text("Room Bookings")
            .font(.headline)
            .foregroundStyle(.primary)

          Spacer()

          DatePicker("Please Select a Date", selection: selectedDateBinding, displayedComponents: .date)
            .labelsHidden()
            .tint(theme.accent.primary)
        }

        // Booking Grid
        ScrollView {
          RoomBookingsListView(
            room: room,
            dateSelect: selectedDateBinding)
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
  }

  // MARK: Private

  @Environment(Theme.self) private var theme
  @Environment(LiveRoomViewModel.self) private var roomViewModel

  private let room: Room

  private var selectedDateBinding: Binding<Date> {
    Binding<Date>(
      get: { roomViewModel.selectedDate },
      set: { newValue in
        roomViewModel.selectedDate = newValue
      })
  }
}

#Preview {
  let viewModel: LiveRoomViewModel = PreviewRoomViewModel()
  return RoomDetailsSheetView(room: Room.exampleOne)
    .environment(viewModel)
    .defaultTheme()
}
