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
    VStack(spacing: 0) {
      HStack {
        // Title
        Text(room.name)
          .font(.title)
          .bold()
          .foregroundStyle(.primary)

        Spacer()

        // Rating
        ZStack {
          RoundedRectangle(cornerRadius: 10)
            .fill(theme.accent.primary)
            .stroke(.gray.opacity(0.2), lineWidth: 1)

          HStack(spacing: 5) {
            Text("\(String(describing: room.overallRating ?? 0))")
              .foregroundStyle(.white)
              .font(.headline)

            Image(systemName: "star.fill")
              .foregroundStyle(.white)
              .padding(0)
          }
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
        // Info
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

  @Environment(Theme.self) private var theme
}

#Preview {
  RoomBookingInformationView(room: Room.exampleOne)
    .defaultTheme()
}
