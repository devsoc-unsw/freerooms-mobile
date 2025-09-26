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

  // MARK: Internal

  var room: Room

  var body: some View {
    // Title
    HStack {
      Text(room.name)
        .font(.title)
        .bold()
        .foregroundStyle(theme.label.primary)

      Spacer()

      HStack(alignment: .center, spacing: 2) {
        Image(systemName: "star.fill")
          .foregroundStyle(.yellow)
          .padding(0)

        Text("\(String(describing: room.overallRating ?? 0))")
          .foregroundStyle(theme.label.primary)
      }
      .padding(.horizontal, 6)
      .padding(.vertical, 4)
      .overlay(
        Capsule()
          .stroke(.gray.opacity(0.2), lineWidth: 1)
          .backgroundStyle(.gray))
      .background(.white.quinary, in: Capsule())
    }

    VStack(alignment: .leading, spacing: 12) {
      if room.school.trimmingCharacters(in: .whitespaces) == "" {
        EmptyView()
      } else {
        Text("School of \(room.school)")
          .fontWeight(.bold)
          .font(.title3)
          .foregroundStyle(theme.label.primary)
      }
      // Info
      HStack {
        RoomLabel(leftLabel: "ID", rightLabel: room.id)
        Spacer()
        RoomLabel(leftLabel: "Abbreviation", rightLabel: room.abbreviation)
      }
    }
    .padding(.vertical, 12)
  }

  // MARK: Private

  @Environment(Theme.self) private var theme
}

#Preview {
  RoomBookingInformationView(room: Room.exampleOne)
    .defaultTheme()
}
