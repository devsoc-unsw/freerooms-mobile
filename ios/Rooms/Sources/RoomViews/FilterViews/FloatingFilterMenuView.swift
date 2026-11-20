//
//  SwiftUIView.swift
//  Rooms
//
//  Created by Yanlin Li  on 24/3/2026.
//

import CommonUI
import RoomViewModels
import SwiftUI
import UIKit

struct FloatingFilterMenuView: View {

  // MARK: Internal

  @Binding var activeFilterSheet: RoomFilterSheet?
  @Binding var showingFilterMenu: Bool

  /// Whether buildings can be ordered by distance yet (needs location permission and a fix).
  let canSortByDistance: Bool

  var body: some View {
    VStack(alignment: .trailing, spacing: Self.menuSpacing) {
      if showingFilterMenu {
        ForEach(FilterMenuItem.allCases) { item in
          let isOn = item == .distance && roomViewModel.sortsByDistance
          // Faded (but still tappable, to explain why) when there's no location to sort by.
          let isAvailable = item != .distance || canSortByDistance || isOn

          filterMenuAction(
            item.title,
            systemImage: isOn ? "checkmark" : item.systemImage,
            isDimmed: !isAvailable)
          {
            if let sheet = item.sheet {
              activeFilterSheet = sheet
            } else if !isAvailable {
              showingLocationAlert = true
            } else {
              roomViewModel.sortsByDistance.toggle()
              withAnimation(.spring(duration: Self.animationDuration)) {
                showingFilterMenu = false
              }
            }
          }
          .accessibilityAddTraits(isOn ? .isSelected : [])
          .accessibilityHint(isAvailable ? "" : "Needs your location")
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
          .background {
            Circle()
              .fill(theme.background.secondary)
              .overlay {
                Circle()
                  .stroke(theme.accent.primary.opacity(Self.toggleBorderOpacity), lineWidth: Self.toggleBorderWidth)
              }
              .shadow(
                color: .black.opacity(Self.toggleShadowOpacity),
                radius: Self.toggleShadowRadius,
                y: Self.toggleShadowYOffset)
          }
      }
      .accessibilityLabel(showingFilterMenu ? "Close filters" : "Open filters")
      .accessibilityHint("Shows filter options near the tab bar")
    }
    .animation(.spring(duration: Self.animationDuration), value: showingFilterMenu)
    // iOS never shows the permission prompt again after "Don't Allow", so point to Settings.
    .alert("Can't find your location", isPresented: $showingLocationAlert) {
      Button("Open Settings") {
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
          openURL(settingsURL)
        }
      }
      Button("Cancel", role: .cancel) { }
    } message: {
      Text("Check that location is on for Freerooms in Settings to sort buildings by distance.")
    }
  }

  // MARK: Private

  private static let menuSpacing: CGFloat = 10
  private static let actionHorizontalPadding: CGFloat = 12
  private static let actionBorderOpacity = 0.28
  private static let actionBorderWidth: CGFloat = 1
  private static let actionVerticalPadding: CGFloat = 10
  private static let actionShadowOpacity = 0.32
  private static let actionShadowRadius: CGFloat = 12
  private static let actionShadowYOffset: CGFloat = 4
  private static let animationDuration = 0.25
  private static let destructiveBorderOpacity = 0.36
  private static let toggleBorderOpacity = 0.24
  private static let toggleBorderWidth: CGFloat = 1
  private static let toggleButtonSize: CGFloat = 56
  private static let toggleIconSize: CGFloat = 20
  private static let toggleShadowOpacity = 0.34
  private static let toggleShadowRadius: CGFloat = 14
  private static let toggleShadowYOffset: CGFloat = 5
  private static let unavailableOpacity = 0.4

  @State private var showingLocationAlert = false

  @Environment(\.openURL) private var openURL
  @Environment(LiveRoomViewModel.self) private var roomViewModel
  @Environment(Theme.self) private var theme

  private var actionBorderColor: Color {
    theme.accent.primary.opacity(Self.actionBorderOpacity)
  }

  private func filterMenuAction(
    _ title: String,
    systemImage: String,
    role: ButtonRole? = nil,
    isDimmed: Bool = false,
    action: @escaping () -> Void)
    -> some View
  {
    Button {
      action()
    } label: {
      Label(title, systemImage: systemImage)
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(role == .destructive ? theme.list.red : theme.label.primary)
        // Fade only the text and icon: fading the whole pill made it see-through and let
        // taps fall through to the scrim behind it.
        .opacity(isDimmed ? Self.unavailableOpacity : 1)
        .padding(.horizontal, Self.actionHorizontalPadding)
        .padding(.vertical, Self.actionVerticalPadding)
        .background {
          Capsule()
            .fill(theme.background.secondary)
            .overlay {
              Capsule()
                .stroke(
                  role == .destructive ? theme.list.red.opacity(Self.destructiveBorderOpacity) : actionBorderColor,
                  lineWidth: Self.actionBorderWidth)
            }
            .shadow(
              color: .black.opacity(Self.actionShadowOpacity),
              radius: Self.actionShadowRadius,
              y: Self.actionShadowYOffset)
        }
    }
    .buttonStyle(.plain)
  }

}

#Preview {
  FloatingFilterMenuView(
    activeFilterSheet: .constant(nil),
    showingFilterMenu: .constant(false),
    canSortByDistance: true)
    .environment(PreviewRoomViewModel() as LiveRoomViewModel)
    .defaultTheme()
}
