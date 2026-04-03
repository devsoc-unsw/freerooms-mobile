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
  @State private var scrollID: Int? = 1
  
  public init(dateSelect: Date = Date(), room: Room, roomViewModel: RoomViewModel, onDismiss: (() -> Void)? = nil) {
    self.dateSelect = dateSelect
    self.room = room
    self.roomViewModel = roomViewModel
    self.onDismiss = onDismiss
  }
  
  var previousDateBinding: Binding<Date> {
      Binding(
          get: {
            dateSelect - .day
          },
          set: { newPreviousDate in
            dateSelect = newPreviousDate + .day
          }
      )
  }
  
  var nextDateBinding: Binding<Date> {
      Binding(
          get: {
            dateSelect + .day
          },
          set: { newPreviousDate in
            dateSelect = newPreviousDate - .day
          }
      )
  }

  // MARK: Internal

  @State var dateSelect = Date()

  let room: Room

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      // List {
      // Booking informations
      RoomBookingInformationView(room: room, currentRoomRating: roomViewModel.currentRoomRating)

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
        if #available(iOS 18.0, *) {
          ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 0) {
                RoomBookingsListView(
                  room: room,
                  roomViewModel: roomViewModel,
                  dateSelect: previousDateBinding
                )
                .containerRelativeFrame(.horizontal)
                .id(0)

                RoomBookingsListView(
                  room: room,
                  roomViewModel: roomViewModel,
                  dateSelect: $dateSelect
                )
                .containerRelativeFrame(.horizontal)
                .id(1)

                RoomBookingsListView(
                  room: room,
                  roomViewModel: roomViewModel,
                  dateSelect: nextDateBinding
                )
                .containerRelativeFrame(.horizontal)
                .id(2)
              }
            .scrollTargetLayout()
          }
          .scrollTargetBehavior(.viewAligned)
          .scrollPosition(id: $scrollID)
          .onScrollPhaseChange { oldPhase, newPhase in
              if newPhase == .idle && (scrollID == 2 || scrollID == 0) {
                if scrollID == 2 {
                  dateSelect += .day
                } else if scrollID == 0 {
                  dateSelect -= .day
                }
                  scrollID = 1
              }
          }
        } else {
          ScrollView {
            RoomBookingsListView(
              room: room,
              roomViewModel: roomViewModel,
              dateSelect: $dateSelect)
          }
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
    .task {
      await roomViewModel.fetchRoomRating(roomID: room.id)
    }
    .gesture(
      DragGesture(minimumDistance: 20, coordinateSpace: .local)
        .onEnded { value in
          if value.translation.width > 50, value.translation.width > abs(value.translation.height) {
            onDismiss?()
          }
        })
  }

  // MARK: Private

  @Environment(Theme.self) private var theme

  private let onDismiss: (() -> Void)?

  private var roomViewModel: RoomViewModel

}

#Preview {
  RoomDetailsSheetView(room: Room.exampleOne, roomViewModel: PreviewRoomViewModel())
    .defaultTheme()
}

extension Double {
  static let day: Double = 86_400
}
