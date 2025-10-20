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

  public init(room: Room, roomViewModel: RoomViewModel) {
    self.room = room
    self.roomViewModel = roomViewModel
  }

  // MARK: Public

  public var body: some View {
    VStack(spacing: 0) {
      RoomImage[room.id]
        .resizable()
        .ignoresSafeArea()
        .frame(height: screenHeight * 0.3)
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal, 5)
        .offset(y: -60)

      Spacer()
    }
    .sheet(isPresented: $showDetails) {
      RoomDetailsSheetView(room: room, roomViewModel: roomViewModel)
        .presentationDetents([.fraction(0.65), .fraction(0.75), .large], selection: $detent)
        .presentationBackgroundInteraction(.enabled(upThrough: .large))
        .presentationCornerRadius(30)
        .interactiveDismissDisabled(true)
    }
    .navigationBarBackButtonHidden()
    .toolbar {
      ToolbarItem(placement: .topBarLeading) {
        Button("Back", systemImage: "multiply") {
          showDetails = false
          // TODO:
          // clear room bookings here instead of on appear
          dismiss()
        }
        .padding(.vertical, 4)
        .font(.title2)
        .buttonBorderShape(.circle)
        .tint(theme.accent.primary)
        .shadow(radius: 2)
      }

      ToolbarItem(placement: .topBarTrailing) {
        Section {
          RoomLabel(leftLabel: "Capacity", rightLabel: String(room.capacity))
        }
        .controlSize(.large)
        .padding(.horizontal)
        .padding(.vertical, 8)
        .shadow(radius: 2)
      }
    }
  }

  // MARK: Internal

  @Environment(\.dismiss) var dismiss

  // MARK: Private

  @Environment(Theme.self) private var theme

  @State private var detent = PresentationDetent.fraction(0.75)
  @State private var showDetails = true

  private let screenHeight = UIScreen.main.bounds.height
  private let room: Room
  private var roomViewModel: RoomViewModel
}

#Preview {
  NavigationStack {
    RoomDetailsView(room: Room.exampleOne, roomViewModel: PreviewRoomViewModel())
      .defaultTheme()
  }
}
