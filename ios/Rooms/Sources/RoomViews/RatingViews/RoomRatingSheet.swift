//
//  RoomRatingSheet.swift
//  Rooms
//

import CommonUI
import RoomModels
import SwiftUI

struct RoomRatingSheet: View {

  // MARK: Internal

  let currentRoomRating: RoomRating?

  var body: some View {
    VStack(spacing: Self.sectionSpacing) {
      VStack(spacing: Self.headerSpacing) {
        Text("Room Rating")
          .font(.title2)
          .bold()

        HStack(spacing: Self.headerIconSpacing) {
          Text("\(currentRoomRating?.overallRating ?? 0, specifier: "%.1f")")
            .font(.system(size: Self.overallRatingFontSize, weight: .bold, design: .rounded))

          Image(systemName: "star.fill")
            .font(.title)
            .foregroundStyle(theme.yellow)
        }
      }
      .frame(maxWidth: .infinity)

      Divider()

      VStack(spacing: Self.breakdownSpacing) {
        Text("Rating Breakdown")
          .font(.headline)
          .frame(maxWidth: .infinity, alignment: .leading)

        RatingBar(
          label: "Cleanliness",
          icon: "sparkles",
          value: currentRoomRating?.averageRating.cleanliness ?? 0)

        RatingBar(
          label: "Location",
          icon: "mappin.and.ellipse",
          value: currentRoomRating?.averageRating.location ?? 0)

        RatingBar(
          label: "Quietness",
          icon: "speaker.slash.fill",
          value: currentRoomRating?.averageRating.quietness ?? 0)
      }

      Spacer()
    }
    .padding(Self.sheetPadding)
  }

  // MARK: Private

  private static let breakdownSpacing: CGFloat = 16
  private static let headerIconSpacing: CGFloat = 4
  private static let headerSpacing: CGFloat = 8
  private static let overallRatingFontSize: CGFloat = 48
  private static let sectionSpacing: CGFloat = 24
  private static let sheetPadding: CGFloat = 24

  @Environment(Theme.self) private var theme

}

#Preview {
  RoomRatingSheet(
    currentRoomRating: RoomRating(
      roomId: "K-17",
      overallRating: 4.3,
      averageRating: AverageRating(cleanliness: 4.5, location: 3.8, quietness: 4.7)))
    .defaultTheme()
}
