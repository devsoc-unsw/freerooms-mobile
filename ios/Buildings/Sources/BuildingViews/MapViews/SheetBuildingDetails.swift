//
//  SheetBuildingDetails.swift
//  Buildings
//
//  Created by Dicko Evaldo on 23/10/2025.

import BuildingViewModels
import CommonUI
import SwiftUI

public struct SheetBuildingDetails: View {

  // MARK: Public

  public var body: some View {
    VStack(spacing: 12) {
      headerSection
      buildingImageSection
      directionsButton
    }
  }

  // MARK: Private

  @Environment(LiveMapViewModel.self) private var viewModel

  private var headerSection: some View {
    HStack(alignment: .top) {
      VStack(alignment: .leading, spacing: 4) {
        Text(viewModel.selectedBuildingName)
          .font(.title)
          .fontWeight(.regular)

        HStack {
          Text("\(viewModel.selectedBuildingAvailableRooms) rooms available")
            .font(.subheadline)
          Circle()
            .fill(viewModel.selectedBuildingAvailabilityColour)
            .frame(width: 12, height: 12)
        }
      }
      Spacer()
      XButton {
        viewModel.onClearBuildingSelection()
      }
    }
  }

  @ViewBuilder
  private var buildingImageSection: some View {
    if let buildingID = viewModel.selectedBuildingID {
      BuildingImage[buildingID]
        .resizable()
        .aspectRatio(contentMode: .fill)
        .frame(maxWidth: .infinity, maxHeight: 150)
        .clipShape(RoundedRectangle(cornerRadius: 5))
        .allowsHitTesting(false)
    }
  }

  private var directionsButton: some View {
    Button {
      Task {
        await viewModel.onGetDirection()
      }
    } label: {
      Label("Get Directions", systemImage: "figure.walk")
        .frame(maxWidth: .infinity, maxHeight: 8)
        .font(.footnote)
        .padding()
        .background(Theme.light.accent.primary)
        .foregroundStyle(.white)
        .cornerRadius(20)
    }
  }
}
