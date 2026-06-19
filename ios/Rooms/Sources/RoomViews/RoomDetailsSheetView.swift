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

// MARK: - RoomDetailsSheetView

public struct RoomDetailsSheetView: View {

  // MARK: Lifecycle

  public init(dateSelect: Date = Date(), room: Room, roomViewModel: RoomViewModel, onDismiss: (() -> Void)? = nil) {
    initialDate = dateSelect
    self.room = room
    self.roomViewModel = roomViewModel
    self.onDismiss = onDismiss
  }

  // MARK: Public

  public var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      // Booking informations
      RoomBookingInformationView(room: room, currentRoomRating: roomViewModel.currentRoomRating)

      // Booking interactive section
      VStack(alignment: .leading, spacing: 16) {
        HStack {
          Text("Room Bookings")
            .font(.headline)
            .foregroundStyle(.primary)

          Spacer()

          DatePicker("Please Select a Date", selection: Binding(
            get: { roomViewModel.dateSelect },
            set: { roomViewModel.dateSelect = $0 }), displayedComponents: .date)
            .labelsHidden()
            .tint(theme.accent.primary)
        }

        // Booking Grid
        // Vertical scrolling for time
        ScrollView(.vertical) {
          // Horizontal scrolling between days
          ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 0) {
              ForEach(0..<Self.maxScrollID, id: \.self) { index in
                RoomBookingsListView(
                  room: room,
                  roomViewModel: roomViewModel,
                  dateSelect: bindingFor(index: index))
                  .id(index)
                  .containerRelativeFrame(.horizontal)
              }
            }
            .scrollTargetLayout()
          }
          .scrollTargetBehavior(.paging)
          .scrollPosition(id: Binding(
            get: { roomViewModel.scrollID },
            set: { roomViewModel.scrollID = $0 }))
          .onChange(of: roomViewModel.scrollID) { oldValue, newValue in
            roomViewModel.handleScrollIDChange(oldValue: oldValue, newValue: newValue)
          }
          .onChange(of: roomViewModel.dateSelect) { oldValue, newValue in
            roomViewModel.handleDateSelectChange(oldValue: oldValue, newValue: newValue)
          }
        }
        .clipShape(RoundedRectangle(cornerRadius: RoomLayoutConstants.bookingSectionCornerRadius))
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
    .onAppear {
      roomViewModel.resetBookingScrollState(initialDate: initialDate)
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

  // MARK: Internal

  let room: Room

  func bindingFor(index: Int) -> Binding<Date> {
    Binding(
      get: { roomViewModel.baseDate + (Double(index - Self.middleIndex) * .day) },
      set: { newDate in
        roomViewModel.baseDate = newDate + (Double(Self.middleIndex - index) * .day)
      })
  }

  // MARK: Private

  // Paging is 0 <= page < middleindex * 2
  private static let maxScrollID = Self.middleIndex * 2
  private static let middleIndex = RoomBookingConstants.middleIndex

  @Environment(Theme.self) private var theme

  private let onDismiss: (() -> Void)?
  private let initialDate: Date

  private var roomViewModel: RoomViewModel

}

#Preview {
  RoomDetailsSheetView(room: Room.exampleOne, roomViewModel: PreviewRoomViewModel())
    .defaultTheme()
}

extension Date {
  fileprivate static func +(lhs: Date, rhs: Double) -> Date {
    lhs.addingTimeInterval(rhs)
  }
}
