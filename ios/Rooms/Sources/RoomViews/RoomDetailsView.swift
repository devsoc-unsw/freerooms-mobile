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
    VStack(spacing: 0) {
      RoomImage[room.id]
        .resizable()
        .scaledToFill()
        .frame(height: screenHeight * 0.4)
        .clipped()
        .ignoresSafeArea()

      Spacer()
    }
    .sheet(isPresented: $showDetails) {
      RoomDetailsSheetView(room: room, roomBookings: roomBookings)
        .presentationDetents([.fraction(0.65), .fraction(0.75), .large], selection: $detent)
        .presentationBackgroundInteraction(.enabled(upThrough: .large))
        .presentationCornerRadius(30)
        .interactiveDismissDisabled(true)
        .onTapGesture {
          // swiftlint:disable:next no_direct_standard_out_logs
          print("\(detent)")
        }
    }
    .navigationBarBackButtonHidden()
    .toolbar {
      ToolbarItem(placement: .topBarLeading) {
        Button("Back", systemImage: "chevron.left") {
          //
          showDetails = false
          dismiss()
        }
        .padding(.vertical, 4)
        .font(.title2)
        .buttonBorderShape(.circle)
        .buttonStyle(.borderedProminent)
        .foregroundStyle(theme.accent.primary)
        .tint(.white)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
      }

      ToolbarItem(placement: .topBarTrailing) {
        Section {
          RoomLabel(leftLabel: "Capacity", rightLabel: String(room.capacity))
        }
        .controlSize(.large)
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 100))
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
      }
    }
  }

  // MARK: Internal

  @Environment(\.dismiss) var dismiss

  // MARK: Private

  @State private var detent = PresentationDetent.fraction(0.75)

  @Environment(Theme.self) private var theme

  @State private var showDetails = true

  private let screenHeight = UIScreen.main.bounds.height
  private let room: Room
  private let roomBookings: [RoomBooking]
}

#Preview {
  NavigationStack {
    RoomDetailsView(room: Room.exampleOne, roomBookings: [])
      .defaultTheme()
  }
}
