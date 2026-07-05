//
//  SwiftUIView.swift
//  Rooms
//
//  Created by Yanlin Li  on 24/3/2026.
//

import CommonUI
import RoomViewModels
import SwiftUI

struct FloatingFilterMenuView: View {

  // MARK: Internal

  @Binding var activeFilterSheet: RoomFilterSheet?
  @Binding var showingFilterMenu: Bool

  var body: some View {
    VStack(alignment: .trailing, spacing: Self.menuSpacing) {
      if showingFilterMenu {
        filterMenuAction("Date", systemImage: "calendar") {
          activeFilterSheet = .date
        }
        filterMenuAction("Duration", systemImage: "clock") {
          activeFilterSheet = .duration
        }
        filterMenuAction("Room Type", systemImage: "square.grid.2x2") {
          activeFilterSheet = .roomType
        }
        filterMenuAction("Campus", systemImage: "building.2") {
          activeFilterSheet = .campusLocation
        }
        filterMenuAction("Capacity", systemImage: "person.2") {
          activeFilterSheet = .capacity
        }
        filterMenuAction("Reset all", systemImage: "arrow.counterclockwise", role: .destructive) {
          roomViewModel.clearAllFilters()
          Task { await roomViewModel.applyFilters() }
        }
      }

      Button {
        withAnimation(.spring(duration: Self.animationDuration)) {
          showingFilterMenu.toggle()
        }
      } label: {
        Image(systemName: showingFilterMenu ? "xmark" : "line.3.horizontal.decrease")
          .font(.system(size: Self.toggleIconSize, weight: .semibold))
          .foregroundStyle(theme.accent.primary)
          .frame(width: Self.toggleButtonSize, height: Self.toggleButtonSize)
          .background(.regularMaterial)
          .clipShape(Circle())
          .shadow(
            color: .black.opacity(Self.toggleShadowOpacity),
            radius: Self.toggleShadowRadius,
            y: Self.toggleShadowYOffset)
      }
      .accessibilityLabel(showingFilterMenu ? "Close filters" : "Open filters")
      .accessibilityHint("Shows filter options near the tab bar")
    }
    .animation(.spring(duration: Self.animationDuration), value: showingFilterMenu)
  }

  // MARK: Private

  private static let menuSpacing: CGFloat = 10
  private static let actionHorizontalPadding: CGFloat = 12
  private static let actionVerticalPadding: CGFloat = 10
  private static let actionShadowOpacity = 0.12
  private static let actionShadowRadius: CGFloat = 6
  private static let actionShadowYOffset: CGFloat = 2
  private static let animationDuration = 0.25
  private static let toggleButtonSize: CGFloat = 56
  private static let toggleIconSize: CGFloat = 20
  private static let toggleShadowOpacity = 0.15
  private static let toggleShadowRadius: CGFloat = 8
  private static let toggleShadowYOffset: CGFloat = 3

  @Environment(LiveRoomViewModel.self) private var roomViewModel
  @Environment(Theme.self) private var theme

  private func filterMenuAction(
    _ title: String,
    systemImage: String,
    role: ButtonRole? = nil,
    action: @escaping () -> Void)
    -> some View
  {
    Button {
      action()
    } label: {
      Label(title, systemImage: systemImage)
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(role == .destructive ? theme.list.red : theme.label.primary)
        .padding(.horizontal, Self.actionHorizontalPadding)
        .padding(.vertical, Self.actionVerticalPadding)
        .background(.regularMaterial)
        .clipShape(Capsule())
        .shadow(
          color: .black.opacity(Self.actionShadowOpacity),
          radius: Self.actionShadowRadius,
          y: Self.actionShadowYOffset)
    }
    .buttonStyle(.plain)
  }

}

#Preview {
  FloatingFilterMenuView(
    activeFilterSheet: .constant(nil),
    showingFilterMenu: .constant(false))
}
