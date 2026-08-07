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
        Task {
          await viewModel.onSelectBuilding(building.id)
        }
        viewModel.focusBuildingOnMap()
        viewModel.clearSearch()
        hideKeyboard()
      } label: {
        HStack {
          Circle()
            .fill(building.availabilityColor)
            .frame(
              width: MapLayoutConstants.defaultAnnotationSize,
              height: MapLayoutConstants.defaultAnnotationSize)
            .overlay {
              Circle()
                .stroke(Color.white, lineWidth: MapLayoutConstants.defaultAnnotationBorderWidth)
            }
            .shadow(
              color: .black.opacity(MapLayoutConstants.annotationShadowOpacity),
              radius: MapLayoutConstants.unselectedAnnotationShadowRadius,
              x: MapLayoutConstants.sheetShadowXOffset,
              y: MapLayoutConstants.annotationShadowYOffset)
          Text(building.name)
            .foregroundStyle(.black)
        }
      }
    }
    .contentMargins(.top, 0)
    .frame(maxHeight: MapLayoutConstants.searchResultListMaxHeight)
    .clipped()
    .scrollContentBackground(.hidden)
  }

  // MARK: Private

  @Environment(LiveMapViewModel.self) private var viewModel
}
