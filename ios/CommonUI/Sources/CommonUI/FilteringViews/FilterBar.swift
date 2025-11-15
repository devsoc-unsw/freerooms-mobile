//
//  FilterBar.swift
//  CommonUI
//
//  Created by Yanlin Li  on 8/11/2025.
//

import RoomViewModels
import SwiftUI

public struct FilterBar: View {

  // MARK: Lifecycle

  public init(
    showingDateFilter: Binding<Bool>,
    showingRoomTypeFilter: Binding<Bool>,
    showingDurationFilter: Binding<Bool>,
    showingCampusLocationFilter: Binding<Bool>)
  {
    _showingDateFilter = showingDateFilter
    _showingRoomTypeFilter = showingRoomTypeFilter
    _showingDurationFilter = showingDurationFilter
    _showingCampusLocationFilter = showingCampusLocationFilter
  }

  // MARK: Public

  public var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 8) {
        FilterButton(
          filterType: .duration,
          showingFilter: $showingDurationFilter)

        FilterButton(
          filterType: .date,
          showingFilter: $showingDateFilter)

        FilterButton(
          filterType: .roomType,
          showingFilter: $showingRoomTypeFilter)

        FilterButton(
          filterType: .campusLocation,
          showingFilter: $showingCampusLocationFilter)

        FilterResetButton()
      }
      .padding(.horizontal, 16)
    }
    .padding(.vertical, 8)
    .background(Color.white)
  }

  // MARK: Internal

  @Environment(LiveRoomViewModel.self) var roomViewModel

  // MARK: Private

  // Filter sheet states
  @Binding private var showingDateFilter: Bool
  @Binding private var showingRoomTypeFilter: Bool
  @Binding private var showingDurationFilter: Bool
  @Binding private var showingCampusLocationFilter: Bool

}

#Preview {
  @Previewable @State var showingDateFilter = false
  @Previewable @State var showingRoomTypeFilter = false
  @Previewable @State var showingDurationFilter = false
  @Previewable @State var showingCampusLocationFilter = false

  let viewModel: LiveRoomViewModel = PreviewRoomViewModel()
  return FilterBar(
    showingDateFilter: $showingDateFilter,
    showingRoomTypeFilter: $showingRoomTypeFilter,
    showingDurationFilter: $showingDurationFilter,
    showingCampusLocationFilter: $showingCampusLocationFilter)
    .environment(viewModel)
    .defaultTheme()
}
