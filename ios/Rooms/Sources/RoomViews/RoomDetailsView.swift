//
//  RoomDetailsView.swift
//  Rooms
//
//  Created by Yanlin Li  on 18/9/2025.
//

import CommonUI
import RoomModels
import RoomViewModels
import SwiftUI

// MARK: - RoomDetailsView

public struct RoomDetailsView: View {

  // MARK: Lifecycle

  public init(room: Room) {
    self.room = room
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
      RoomDetailsSheetView(room: room)
        .environment(roomViewModel)
        .presentationDetents([.fraction(0.65), .fraction(0.75), .large], selection: $detent)
        .presentationBackgroundInteraction(.enabled(upThrough: .large))
        .presentationCornerRadius(30)
        .interactiveDismissDisabled(true)
    }
    .navigationBarBackButtonHidden(true)
    .gesture(
      DragGesture(minimumDistance: 20, coordinateSpace: .local)
        .onEnded { value in
          if value.translation.width > 50, value.translation.width > abs(value.translation.height) {
            showDetails = false
            dismiss()
          }
        })
    .toolbar {
      ToolbarItem(placement: .topBarLeading) {
        Button("Back", systemImage: "chevron.left") {
          showDetails = false
          // TODO:
          // clear room bookings here instead of on appear
          dismiss()
        }
        .padding(.vertical, 4)
        .font(.title2)
        .buttonBorderShape(.circle)
        .liquidGlass(
          if: {
            $0
          },
          else: {
            $0
              .buttonStyle(.borderedProminent)
              .tint(.white)
              .foregroundStyle(theme.accent.primary)
          })
      }

      ToolbarItem(placement: .topBarTrailing) {
        Section {
          RoomLabel(leftLabel: "Capacity", rightLabel: String(room.capacity))
        }
        .controlSize(.large)
        .padding(.horizontal)
        .padding(.vertical, 8)
        .liquidGlass(
          if: {
            $0
          },
          else: {
            $0
              .background(Color.white)
              .cornerRadius(12)
          })
      }
    }
  }

  // MARK: Internal

  // MARK: Private

  @Environment(\.dismiss) private var dismiss
  @Environment(Theme.self) private var theme
  @Environment(LiveRoomViewModel.self) private var roomViewModel

  @State private var detent = PresentationDetent.fraction(0.75)
  @State private var showDetails = true

  private let screenHeight = UIScreen.main.bounds.height
  private let room: Room
}

#Preview {
  NavigationStack {
    RoomDetailsView(room: Room.exampleOne)
      .defaultTheme()
  }
}

extension View {
  @ViewBuilder
  func liquidGlass(
    if transform1: (Self) -> some View,
    else transform2: (Self) -> some View)
    -> some View
  {
    if #available(iOS 26.0, *) {
      transform1(self)
    } else {
      transform2(self)
    }
  }
}
