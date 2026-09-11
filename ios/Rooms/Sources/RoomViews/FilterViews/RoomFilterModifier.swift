//
//  RoomFilterModifier.swift
//  Rooms
//
//  Created by Nicole Xie on 2026/9/11.
//

import CommonUI
import RoomModels
import RoomViewModels
import SwiftUI

// MARK: - RoomFilterModifier

struct RoomFilterModifier: ViewModifier {

  // MARK: Internal

  @Binding var activeFilterSheet: RoomFilterSheet?

  func body(content: Content) -> some View {
    content
      .sheet(item: $activeFilterSheet) { sheet in
        switch sheet {
        case .date:
          DateFilterView(selectedDate: selectedDateBinding) {
            activeFilterSheet = nil

            Task {
              await roomViewModel.applyFilters()
            }

            // Date changes also require fresh bookings to calculate availability.
            let vm = roomViewModel

            Task {
              await vm.loadBookingsForFilteredRooms()
            }
          }
          .environment(roomViewModel)
          .presentationDetents([FilterSheetLayout.dateDetent])
          .presentationDragIndicator(.visible)
          .presentationBackground(Color(.systemBackground))

        case .roomType:
          RoomTypeFilterView(
            selectedRoomTypes: selectedRoomTypesBinding)
          {
            activeFilterSheet = nil

            Task {
              await roomViewModel.applyFilters()
            }
          }
          .environment(roomViewModel)
          .presentationDetents([FilterSheetLayout.roomTypeDetent])
          .presentationDragIndicator(.visible)
          .presentationBackground(Color(.systemBackground))

        case .duration:
          DurationFilterView(onSelect: {
            activeFilterSheet = nil

            Task {
              await roomViewModel.applyFilters()
            }
          })
          .environment(roomViewModel)
          .presentationDetents([FilterSheetLayout.durationDetent])
          .presentationDragIndicator(.visible)
          .presentationBackground(Color(.systemBackground))

        case .campusLocation:
          CampusLocationFilterView(
            selectedCampusLocation: selectedCampusLocationBinding)
          {
            activeFilterSheet = nil

            Task {
              await roomViewModel.applyFilters()
            }
          }
          .environment(roomViewModel)
          .presentationDetents([FilterSheetLayout.campusLocationDetent])
          .presentationDragIndicator(.visible)
          .presentationBackground(Color(.systemBackground))

        case .capacity:
          CapacityFilterView(
            selectedCapacity: selectedCapacityBinding)
          {
            activeFilterSheet = nil

            Task {
              await roomViewModel.applyFilters()
            }
          }
          .environment(roomViewModel)
          .presentationDetents([FilterSheetLayout.capacityDetent])
          .presentationDragIndicator(.visible)
          .presentationBackground(Color(.systemBackground))
        }
      }
  }

  // MARK: Private

  @Environment(LiveRoomViewModel.self) private var roomViewModel

  private var selectedDateBinding: Binding<Date> {
    Binding(
      get: { roomViewModel.selectedDate },
      set: { roomViewModel.selectedDate = $0 })
  }

  private var selectedRoomTypesBinding: Binding<Set<RoomType>> {
    Binding(
      get: { roomViewModel.selectedRoomTypes },
      set: { roomViewModel.selectedRoomTypes = $0 })
  }

  private var selectedCampusLocationBinding: Binding<CampusLocation?> {
    Binding(
      get: { roomViewModel.selectedCampusLocation },
      set: { roomViewModel.selectedCampusLocation = $0 })
  }

  private var selectedCapacityBinding: Binding<Int?> {
    Binding(
      get: { roomViewModel.selectedCapacity },
      set: { roomViewModel.selectedCapacity = $0 })
  }

}

extension View {
  func roomFilterSheets(
    activeFilterSheet: Binding<RoomFilterSheet?>)
    -> some View
  {
    modifier(
      RoomFilterModifier(
        activeFilterSheet: activeFilterSheet))
  }
}
