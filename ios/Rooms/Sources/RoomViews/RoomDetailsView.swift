//
//  RoomView.swift
//  Rooms
//
//  Created by Yanlin Li  on 18/9/2025.
//

import CommonUI
import RoomModels
import RoomViewModels
import SwiftUI

public struct RoomDetailsView: View {

  // MARK: Lifecycle

  public init(room: Room, roomBookings: [RoomBooking]) {
    self.room = room
    self.roomBookings = roomBookings
  }

  // MARK: Public

  public var body: some View {
    ZStack(alignment: .topLeading) {
      RoomImage[room.id]
        .resizable()
        .scaledToFill()
        .frame(height: screenHeight * 0.4)
        .clipped()
        .ignoresSafeArea()

      // Back button overlay
      VStack {
        HStack {
          Button(action: { showDetails = false }) {
            Image(systemName: "chevron.left")
              .padding()
              .background(.ultraThinMaterial, in: Circle())
          }
          Spacer()

          Circle()
            .fill(.yellow)
            .frame(width: 60, height: 60)
        }
        .padding()

        Spacer()
      }
    }
    .sheet(isPresented: $showDetails) {
      RoomDetailsSheetView(room: room)
        .presentationDetents([.fraction(0.67), .large])
        .presentationBackgroundInteraction(.enabled(upThrough: .large))
        .presentationCornerRadius(30)
        .interactiveDismissDisabled(true)
    }
  }

  // MARK: Private

  @State private var showDetails = true

  private let screenHeight = UIScreen.main.bounds.height
  private let room: Room
  private let roomBookings: [RoomBooking]
}

#Preview {
  RoomDetailsView(room: Room.exampleOne, roomBookings: [])
    .defaultTheme()
}
