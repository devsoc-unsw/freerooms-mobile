//
//  RoomDetailsSheet.swift
//  Rooms
//
//  Created by Yanlin Li  on 18/9/2025.
//

import CommonUI
import RoomModels
import SwiftUI

struct RoomDetailsSheetView: View {

  // MARK: Internal

  @State var dateSelect = Date()
  let room: Room

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
//    List {
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
            roomBookings: roomBookings,
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
  }

  // MARK: Private

  @Environment(Theme.self) private var theme

  let roomBookings: [RoomBooking]

}

#Preview {
  RoomDetailsSheetView(room: Room.exampleOne, roomBookings: [])
    .defaultTheme()
}
