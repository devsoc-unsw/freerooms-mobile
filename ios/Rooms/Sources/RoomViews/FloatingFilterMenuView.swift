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
    VStack(alignment: .trailing, spacing: 10) {
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
        withAnimation(.spring(duration: 0.25)) {
          showingFilterMenu.toggle()
        }
      } label: {
        Image(systemName: showingFilterMenu ? "xmark" : "line.3.horizontal.decrease")
          .font(.system(size: 20, weight: .semibold))
          .foregroundStyle(theme.accent.primary)
          .frame(width: 56, height: 56)
          .background(.regularMaterial)
          .clipShape(Circle())
          .shadow(color: .black.opacity(0.15), radius: 8, y: 3)
      }
      .accessibilityLabel(showingFilterMenu ? "Close filters" : "Open filters")
      .accessibilityHint("Shows filter options near the tab bar")
    }
    .animation(.spring(duration: 0.25), value: showingFilterMenu)
  }

  // MARK: Private

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
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(.regularMaterial)
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.12), radius: 6, y: 2)
    }
    .buttonStyle(.plain)
  }

}

#Preview {
  FloatingFilterMenuView(
    activeFilterSheet: .constant(nil),
    showingFilterMenu: .constant(false))
}
