//
//  MapSearchBarList.swift
//  Buildings
//
//  Created by Dicko Evaldo on 12/10/2025.
//
import BuildingModels
import BuildingViewModels
import SwiftUI

public struct MapSearchBarList: View {

  // MARK: Public

  public var body: some View {
    List(viewModel.filteredBuildings, id: \.self) { building in
      Button {
        viewModel.onSelectBuilding(building.id)
        viewModel.focusBuildingOnMap()
        viewModel.clearSearch()
        hideKeyboard()
      } label: {
        HStack {
          Circle()
            .fill(building.availabilityColor)
            .frame(
              width: 16,
              height: 16)
            .overlay {
              Circle()
                .stroke(Color.white, lineWidth: 3)
            }
            .shadow(
              color: .black.opacity(0.3),
              radius: 2,
              x: 0,
              y: 1)
          Text(building.name)
            .foregroundStyle(.black)
        }
      }
    }
    .contentMargins(.top, 0)
    .frame(maxHeight: 300)
    .clipped()
    .scrollContentBackground(.hidden)
  }

  // MARK: Private

  @Environment(LiveMapViewModel.self) private var viewModel
}
