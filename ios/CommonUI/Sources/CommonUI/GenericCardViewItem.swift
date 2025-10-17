//
//  GenericCardViewItem.swift
//  CommonUI
//
//  Created by Gabriella Lianti on 15/10/25.
//

import BuildingModels
import RoomModels
import SwiftUI

public struct GenericCardViewItem<T: Equatable & Hashable & Identifiable & HasName & HasRating>: View {

  public init(cardWidth: Binding<CGFloat?>, item: T) {
    _cardWidth = cardWidth
    self.item = item
  }

  public var body: some View {
      VStack {
          HStack(alignment: .center, spacing: 0) {
              Text(item.name)
                .bold()
                .foregroundStyle(theme.label.primary)
                .lineLimit(1)
                .truncationMode(.tail)
              
              Spacer()
              // TODO: ratings
              if let overallRating = item.overallRating {
                Text(overallRating.formatted())
                Image(systemName: "star.fill")
                  .foregroundStyle(theme.yellow)
                  .padding(.trailing)
              }
          }
          
          HStack(alignment: .center, spacing: 0) {
              if let room = item as? Room {
                Text("\(room.status == "free" ? "Available" : room.status == "" ? "status not available" : "Unavailable")")
                  .foregroundStyle(room.status == "free" ? .green : room.status == "" ? .gray : .red)
              } else if let building = item as? Building {
                Text("^[\(building.numberOfAvailableRooms ?? 0) room](inflect: true) available")
              }
              
              Spacer()
              Image(systemName: "chevron.right") // TODO: find the arrow
          }
      }
    .background(GeometryReader { geometry in
      // In a background the GeometryReader expands to the bounds of the foreground view
      Color.clear.preference(
        key: HeightPreferenceKey.self, // This saves the height into the HeightPreferenceKey
        value: geometry.size.height)
    })
  }

  @Environment(Theme.self) private var theme

  @Binding private var cardWidth: CGFloat?

  private let item: T

}
