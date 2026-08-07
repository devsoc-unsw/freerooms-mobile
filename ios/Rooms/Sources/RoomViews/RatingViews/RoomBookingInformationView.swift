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

  public init(room: Room, currentRoomRating: RoomRating?, isFavourite: Binding<Bool>) {
    self.room = room
    self.currentRoomRating = currentRoomRating
    _isFavourite = isFavourite
  }

  // MARK: Internal

  var room: Room
  let currentRoomRating: RoomRating?

  var body: some View {
    VStack(spacing: 0) {
      HStack(alignment: .top) {
        Text(room.name)
          .font(.title)
          .bold()
          .foregroundStyle(.primary)

        Spacer()

        ZStack {
          RoundedRectangle(cornerRadius: Self.ratingBadgeCornerRadius)
            .fill(theme.accent.primary)
            .stroke(.gray.opacity(Self.ratingBadgeBorderOpacity), lineWidth: Self.borderWidth)

          HStack(spacing: Self.ratingBadgeContentSpacing) {
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
            .presentationCornerRadius(Self.ratingSheetCornerRadius)
        }
        .frame(width: Self.ratingBadgeWidth, height: Self.ratingBadgeHeight)

        Button {
          isFavourite.toggle()
        } label: {
          Image(systemName: "heart")
            .foregroundStyle(theme.accent.primary)
            .font(.system(size: Self.favoriteIconSize))
            .symbolVariant(isFavourite ? .fill : .none)
        }
        .buttonStyle(.bordered)
        .buttonBorderShape(.circle)
      }

      VStack(alignment: .leading, spacing: Self.statusContentSpacing) {
        HStack {
          Text("\(room.abbreviation)")
            .font(.title3)
            .bold()
            .foregroundStyle(.primary)
          Spacer()
          Text("\(room.statusText)")
            .font(.system(size: Self.statusFontSize, weight: .light))
            .foregroundStyle(room.statusTextColour)
            .padding(.vertical, Self.statusVerticalPadding)
            .padding(.horizontal, Self.statusHorizontalPadding)
            .background(
              RoundedRectangle(cornerRadius: Self.statusCornerRadius)
                .fill(room.statusBackgroundColor))
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.vertical, Self.statusSectionVerticalPadding)
    }
  }

  // MARK: Private

  private static let borderWidth: CGFloat = 1
  private static let favoriteIconSize: CGFloat = 22
  private static let ratingBadgeBorderOpacity = 0.2
  private static let ratingBadgeContentSpacing: CGFloat = 5
  private static let ratingBadgeCornerRadius: CGFloat = 10
  private static let ratingBadgeHeight: CGFloat = 35
  private static let ratingBadgeWidth: CGFloat = 65
  private static let ratingSheetCornerRadius: CGFloat = 24
  private static let statusContentSpacing: CGFloat = 10
  private static let statusCornerRadius: CGFloat = 5
  private static let statusFontSize: CGFloat = 20
  private static let statusHorizontalPadding: CGFloat = 8
  private static let statusSectionVerticalPadding: CGFloat = 12
  private static let statusVerticalPadding: CGFloat = 4

  @State private var isShowingSheet: Bool = false

  @Binding private var isFavourite: Bool

  @Environment(Theme.self) private var theme

}

#Preview {
  @Previewable @State var isFavourite = false

  RoomBookingInformationView(
    room: Room.exampleOne,
    currentRoomRating: RoomRating(
      roomId: "K-17",
      overallRating: 5.0,
      averageRating: AverageRating(cleanliness: 5.0, location: 5.0, quietness: 5.0)),
    isFavourite: $isFavourite)
    .defaultTheme()
}
