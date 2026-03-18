//
//  RoomBookingInformationView.swift
//  Rooms
//
//  Created by Yanlin Li  on 26/9/2025.
//

import CommonUI
import RoomModels
import SwiftUI

struct RoomBookingInformationView: View {

  // MARK: Lifecycle

  public init(room: Room, currentRoomRating: RoomRating?) {
    self.room = room
    self.currentRoomRating = currentRoomRating
  }

  // MARK: Internal

  var room: Room
  let currentRoomRating: RoomRating?

  var body: some View {
    VStack(spacing: 0) {
      HStack {
        Text(room.name)
          .font(.title)
          .bold()
          .foregroundStyle(.primary)

        Spacer()

        ZStack {
          RoundedRectangle(cornerRadius: 10)
            .fill(theme.accent.primary)
            .stroke(.gray.opacity(0.2), lineWidth: 1)

          HStack(spacing: 5) {
            Text("\(currentRoomRating?.overallRating ?? 0, specifier: "%.1f")")
              .foregroundStyle(.white)
              .font(.headline)

            Image(systemName: "star.fill")
              .foregroundStyle(.white)
              .padding(0)
          }
        }
        .onTapGesture {
          isShowingSheet.toggle()
        }
        .sheet(isPresented: $isShowingSheet) {
          RoomRatingSheet(currentRoomRating: currentRoomRating)
            .presentationDetents([.medium])
            .presentationCornerRadius(24)
        }
        .frame(width: 65, height: 35)
        .padding(.horizontal, 6)
      }

      VStack(alignment: .leading, spacing: 10) {
        if room.school.trimmingCharacters(in: .whitespaces) == "" {
          EmptyView()
        } else {
          Text("School of \(room.school)")
            .font(.title3)
            .bold()
            .foregroundStyle(.primary)
        }
        Text("\(room.abbreviation)")
          .font(.callout)
          .foregroundStyle(.primary)
          .bold()
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.vertical, 12)
    }
  }

  // MARK: Private

  @State private var isShowingSheet: Bool = false

  @Environment(Theme.self) private var theme
}

#Preview {
  RoomBookingInformationView(
    room: Room.exampleOne,
    currentRoomRating: RoomRating(
      roomId: "K-17",
      overallRating: 5.0,
      averageRating: AverageRating(cleanliness: 5.0, location: 5.0, quietness: 5.0)))
    .defaultTheme()
}
