//
//  DirectionDetailsView.swift
//  Buildings
//
//  Created by Dicko Evaldo on 23/10/2025.
//
import BuildingViewModels
import CommonUI
import MapKit
import SwiftUI

public struct SheetDirectionDetails: View {

  // MARK: Public

  public var body: some View {
    HStack {
      directionLabel
      Spacer()
      XButton {
        viewModel.clearDirection()
      }
    }
    .redacted(reason: viewModel.isLoadingCurrentRoute ? .placeholder : [])
  }

  // MARK: Private

  @Environment(LiveMapViewModel.self) private var viewModel

  @ViewBuilder
  private var directionLabel: some View {
    if let errorMessage = viewModel.currentRouteErrorMessage {
      Label(errorMessage, systemImage: "exclamationmark.triangle.fill")
        .font(.headline)
        .fontWeight(.semibold)
        .foregroundColor(.red)
    } else if viewModel.isLoadingCurrentRoute {
      Text("15 min walk (450m)")
        .font(.title)
        .fontWeight(.semibold)
    } else {
      Text("\(viewModel.currentRouteETA.detailedWalkingTime) (\(formattedDistance))")
        .font(.title)
        .fontWeight(.semibold)
    }
  }

  private var formattedDistance: String {
    String(format: "%.0f", floor(viewModel.currentRoute?.distance ?? 0)) + "m"
  }
}
