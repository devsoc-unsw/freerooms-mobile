//
//  BuildingsTabView.swift
//  Buildings
//
//  Created by Yanlin Li  on 3/7/2025.
//

import BuildingModels
import BuildingViewModels
import CommonUI
import RoomModels
import SwiftUI

// MARK: - BuildingsTabView

public struct BuildingsTabView<BuildingDestination: View, RoomDestination: View>: View {

  // MARK: Lifecycle

  public init(
    path: Binding<NavigationPath>,
    viewModel: BuildingViewModel,
		selectedView: Binding<RoomOrientation>, // TODO: rename RoomOrientation?
    _ roomsDestinationBuilderView: @escaping (Building) -> BuildingDestination,
    _ roomDestinationBuilderView: @escaping (Room) -> RoomDestination)
  {
    _path = path
		_selectedView = selectedView
    self.viewModel = viewModel
    self.roomsDestinationBuilderView = roomsDestinationBuilderView
    self.roomDestinationBuilderView = roomDestinationBuilderView
  }

  // MARK: Public

  public var body: some View {
    NavigationStack(path: $path) {
      buildingsView
      .refreshable {
        Task {
          await viewModel.reloadBuildings()
        }
      }
      .toolbar {
        // Buttons on the right
        ToolbarItemGroup(placement: .navigationBarTrailing) {
          HStack {
            Button {
              // action
            } label: {
              Image(systemName: "line.3.horizontal.decrease")
                .resizable()
                .frame(width: 22, height: 15)
            }

            Button {
              viewModel.getBuildingsInOrder()
            } label: {
              Image(systemName: "arrow.up.arrow.down")
                .resizable()
                .frame(width: 25, height: 20)
            }
						
						Button {
							if selectedView == RoomOrientation.Card {
								selectedView = RoomOrientation.List
							} else {
								selectedView = RoomOrientation.Card
							}
						} label: {
							Image(systemName: selectedView == RoomOrientation.List ? "square.grid.2x2" : "list.bullet")
								.resizable()
								.frame(width: 22, height: 20)
						}
          }
          .padding(5)
          .foregroundStyle(theme.label.tertiary)
        }
      }
      .background(Color.gray.opacity(0.1))
      .listRowInsets(EdgeInsets()) // Removes the large default padding around a list
      .scrollContentBackground(.hidden) // Hides default grey background of the list to allow shadow to appear correctly under
      // section cards
      .shadow(
        color: theme.label.primary.opacity(0.2),
        radius: 5) // Adds a shadow to section cards (and also the section header but thankfully it's not noticeable)
      .navigationDestination(for: Building.self) { building in
        roomsDestinationBuilderView(building)
          .navigationTitle(building.name)
          .navigationBarTitleDisplayMode(.inline)
      }
      .navigationDestination(for: Room.self) { room in // Renders the view for displaying a room that has been clicked on
        roomDestinationBuilderView(room)
      }
      .opacity(
        viewModel.isLoading
          ? 0
          : 1) // This hides a glitch where the bottom border of top section row and vice versa flashes when changing order
        .overlay {
          if viewModel.isLoading {
            VStack {
              ProgressView()
                .scaleEffect(1.2)
              Text("Loading buildings...")
                .font(.caption)
                .foregroundColor(theme.label.secondary)
                .padding(.top, 8)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.gray.opacity(0.1))
          }
        }
        .onAppear {
          if !viewModel.hasLoaded {
            viewModel.onAppear()
          }
        }
        .navigationTitle("Buildings")
        .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search...")
    }
    .alert(item: $viewModel.loadBuildingErrorMessage) { error in
      Alert(
        title: Text(error.title),
        message: Text(error.message),
        dismissButton: .default(Text("OK")))
    }
    .tabItem {
      Label("Buildings", systemImage: "building")
    }
    .tag("Buildings")
  }

  // MARK: Internal

  @State var viewModel: BuildingViewModel
  @Binding var path: NavigationPath
  @State var rowHeight: CGFloat?
	@Binding var selectedView: RoomOrientation
	@State var cardWidth: CGFloat?

  let roomsDestinationBuilderView: (Building) -> BuildingDestination
  let roomDestinationBuilderView: (Room) -> RoomDestination
	
	@ViewBuilder
	private var buildingsView: some View {
		if selectedView == RoomOrientation.List {
			List {
				buildingsListSegment(for: "Upper campus", from: viewModel.filteredBuildings.upper)
				buildingsListSegment(for: "Middle campus", from: viewModel.filteredBuildings.middle)
				buildingsListSegment(for: "Lower campus", from: viewModel.filteredBuildings.lower)
			}
		} else {
			ScrollView {
				buildingsCardSegment(for: "Upper campus", from: viewModel.filteredBuildings.upper)
				buildingsCardSegment(for: "Middle campus", from: viewModel.filteredBuildings.middle)
				buildingsCardSegment(for: "Lower campus", from: viewModel.filteredBuildings.lower)
			}
			.padding(.horizontal, 16)
		}
	}
	
	@ViewBuilder
	func buildingsCardSegment(for campus: String, from buildings: [Building]) -> some View {
		Section {
			LazyVGrid(columns: columns, spacing: 24) {
				ForEach(buildings) { building in
					GenericCardView(
						path: $path,
						cardWidth: $cardWidth,
						building: building,
						buildings: buildings,
						imageProvider: { roomID in
							BuildingImage[roomID]
						})
				}
			}
		} header: {
			HStack {
				Text(campus)
					.foregroundStyle(theme.label.primary)
					.padding(.leading, 10)
				Spacer()
			}
			.padding(.top, 10)
		}
	}
	
	private let columns = [
		GridItem(.flexible()),
		GridItem(.flexible()),
	]

  @ViewBuilder
  func buildingsListSegment(for campus: String, from buildings: [Building]) -> some View {
    if buildings.isEmpty {
      EmptyView()
    } else {
      Section {
        ForEach(buildings) { building in
          GenericListRowView(
            path: $path,
            rowHeight: $rowHeight,
            building: building,
            buildings: buildings,
            imageProvider: { buildingID in
              BuildingImage[buildingID]
            })
            .padding(.vertical, 5)
        }
      } header: {
        Text(campus)
          .foregroundStyle(theme.label.primary)
      }
    }
  }

  // MARK: Private

  @Environment(Theme.self) private var theme
}

// MARK: - PreviewWrapper

struct PreviewWrapper: View {
  @State var path = NavigationPath()
	@State var selectedView = RoomOrientation.List

  var body: some View {
    BuildingsTabView(
      path: $path,
      viewModel: PreviewBuildingViewModel(),
			selectedView: $selectedView)
    { _ in
      EmptyView() // Buildings destination
    } _: { _ in
      EmptyView() // Rooms destination
    }
    .defaultTheme()
  }
}

#Preview {
  PreviewWrapper()
}
