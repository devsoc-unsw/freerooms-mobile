//
//  SortMenu.swift
//  CommonUI
//
//  Created by Eric Wong on 21/11/2026.
//

public import SwiftUI

// MARK: - SortMenuOption

/// A way to sort a list in a tab's menu. Each tab offers the ones that make sense for it.
public enum SortMenuOption: Hashable, Sendable {
  case alphabetical
  case availability
  case distance

  // MARK: Internal

  var title: String {
    switch self {
    case .alphabetical: "Alphabetical"
    case .availability: "Availability"
    case .distance: "Distance"
    }
  }

  var systemImage: String {
    switch self {
    case .alphabetical: "character"
    case .availability: "calendar"
    case .distance: "location.fill"
    }
  }
}

// MARK: - SortMenu

/// The ↑↓ sort menu shared by the Buildings and Rooms tabs: Reverse, a divider, then the sort
/// options, with ticks on the reverse state and the option in use. Distance is greyed out, with a
/// hint, when there's no location to sort by.
public struct SortMenu: View {

  // MARK: Lifecycle

  /// - Parameters:
  ///   - options: The options this tab offers, in menu order.
  ///   - selection: The option in use, or `nil` to tick none.
  ///   - isReversed: Whether Reverse is on.
  ///   - canSortByDistance: Whether Distance can be picked.
  ///   - onSelect: Called with the option the user picks.
  ///   - onReverse: Called when the user taps Reverse.
  public init(
    options: [SortMenuOption],
    selection: SortMenuOption?,
    isReversed: Bool,
    canSortByDistance: Bool,
    onSelect: @escaping (SortMenuOption) -> Void,
    onReverse: @escaping () -> Void)
  {
    self.options = options
    self.selection = selection
    self.isReversed = isReversed
    self.canSortByDistance = canSortByDistance
    self.onSelect = onSelect
    self.onReverse = onReverse
  }

  // MARK: Public

  public var body: some View {
    Menu {
      Toggle(isOn: Binding(get: { isReversed }, set: { _ in onReverse() })) {
        Label("Reverse", systemImage: "arrow.up.arrow.down")
      }
      // Toggles rather than a Picker, as menus ignore `.disabled` and subtitles on Picker rows.
      Section {
        ForEach(options, id: \.self) { option in
          optionRow(option)
        }
      }
    } label: {
      Image(systemName: "arrow.up.arrow.down")
        .resizable()
        .frame(width: SortMenuLayout.iconWidth, height: SortMenuLayout.iconHeight)
    }
    .accessibilityLabel("Sort")
  }

  // MARK: Private

  private let options: [SortMenuOption]
  private let selection: SortMenuOption?
  private let isReversed: Bool
  private let canSortByDistance: Bool
  private let onSelect: (SortMenuOption) -> Void
  private let onReverse: () -> Void

  private func optionRow(_ option: SortMenuOption) -> some View {
    Toggle(isOn: isSelected(option)) {
      optionLabel(option)
    }
    .disabled(option == .distance && !canSortByDistance)
  }

  @ViewBuilder
  private func optionLabel(_ option: SortMenuOption) -> some View {
    if option == .distance {
      DistanceSortLabel(canSortByDistance: canSortByDistance)
    } else {
      Label(option.title, systemImage: option.systemImage)
    }
  }

  private func isSelected(_ option: SortMenuOption) -> Binding<Bool> {
    Binding(
      get: { selection == option },
      set: { isOn in
        if isOn {
          onSelect(option)
        }
      })
  }

}

// MARK: - SortMenuLayout

private enum SortMenuLayout {
  static let iconHeight: CGFloat = 20
  static let iconWidth: CGFloat = 25
}

#Preview {
  SortMenu(
    options: [.alphabetical, .availability, .distance],
    selection: .alphabetical,
    isReversed: false,
    canSortByDistance: false,
    onSelect: { _ in },
    onReverse: { })
    .defaultTheme()
}
