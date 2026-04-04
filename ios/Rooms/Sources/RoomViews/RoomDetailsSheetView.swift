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

struct RoomDetailsSheetView: View {

  // MARK: Lifecycle

  public init(dateSelect: Date = Date(), room: Room, roomViewModel: RoomViewModel, onDismiss: (() -> Void)? = nil) {
    self.dateSelect = dateSelect
    self.room = room
    self.roomViewModel = roomViewModel
    self.onDismiss = onDismiss
  }

  // MARK: Internal

  let room: Room

  var body: some View {
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

          DatePicker("Please Select a Date", selection: $dateSelect, displayedComponents: .date)
            .labelsHidden()
            .tint(theme.accent.primary)
        }

        // Booking Grid
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
        .scrollPosition(id: $scrollID)
        .onChange(of: scrollID) { _, newValue in
          if let newValue {
            dateSelect = baseDate + (Double(newValue - Self.middleIndex) * .day)
          }
        }
        .onChange(of: dateSelect) { _, newValue in
          if var scrollID {
            let expectedDate = baseDate + (Double((scrollID - Self.middleIndex) - Self.middleIndex) * .day)
            if abs(newValue.timeIntervalSince(expectedDate)) > 1 {
              baseDate = newValue
              scrollID = Self.middleIndex
            }
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

  func bindingFor(index: Int) -> Binding<Date> {
    Binding(
      get: { baseDate + (Double(index - Self.middleIndex) * .day) },
      set: { newDate in
        baseDate = newDate + (Double(Self.middleIndex - index) * .day)
      })
  }

  // MARK: Private

  // Paging is 0 <= page < middleindex * 2
  private static let maxScrollID = Self.middleIndex * 2
  private static let middleIndex = 500

  @State private var scrollID: Int? = middleIndex
  @State private var baseDate = Date()
  @State private var dateSelect = Date()

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

extension Date {
  static func +(lhs: Date, rhs: Double) -> Date {
    lhs.addingTimeInterval(rhs)
  }
}
