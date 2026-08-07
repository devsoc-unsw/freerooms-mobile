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

  public init(
    dateSelect: Date = Date(),
    room: Room,
    isFavourite: Binding<Bool>,
    onDismiss: (() -> Void)? = nil)
  {
    initialDate = dateSelect
    self.room = room
    _isFavourite = isFavourite
    self.onDismiss = onDismiss
  }

  // MARK: Public

  public var body: some View {
    VStack(alignment: .leading, spacing: Self.contentSpacing) {
      RoomBookingInformationView(room: room, currentRoomRating: roomViewModel.currentRoomRating, isFavourite: $isFavourite)

      VStack(alignment: .leading, spacing: Self.bookingSectionSpacing) {
        HStack {
          Text("Room Bookings")
            .font(.headline)
            .foregroundStyle(.primary)

          Spacer()

          DatePicker(
            "Please Select a Date",
            selection: Binding(
              get: { roomViewModel.dateSelect },
              set: { roomViewModel.dateSelect = $0 }),
            displayedComponents: .date)
            .labelsHidden()
            .tint(theme.accent.primary)
        }

        ScrollView(.vertical) {
          ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 0) {
              ForEach(0..<Self.maxScrollID, id: \.self) { index in
                RoomBookingsListView(
                  room: room,
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
          .stroke(Color.gray.secondary, lineWidth: Self.bookingSectionBorderWidth))
    }
    .padding()
    .background(theme.background.secondary)
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

  private static let maxScrollID = Self.middleIndex * 2
  private static let middleIndex = RoomBookingConstants.middleIndex
  private static let bookingSectionBorderWidth: CGFloat = 1
  private static let bookingSectionSpacing: CGFloat = 16
  private static let contentSpacing: CGFloat = 10

  @Environment(Theme.self) private var theme
  @Environment(LiveRoomViewModel.self) private var roomViewModel

  @Binding private var isFavourite: Bool

  private let onDismiss: (() -> Void)?
  private let initialDate: Date

}

#Preview {
  @Previewable @State var isFavourite = false
  let viewModel: LiveRoomViewModel = PreviewRoomViewModel()

  return RoomDetailsSheetView(room: Room.exampleOne, isFavourite: $isFavourite)
    .environment(viewModel)
    .defaultTheme()
}

extension Date {
  fileprivate static func +(lhs: Date, rhs: Double) -> Date {
    lhs.addingTimeInterval(rhs)
  }
}
