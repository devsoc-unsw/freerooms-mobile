//
//  BuildingService.swift
//  Buildings
//
//  Created by Anh Nguyen on 22/4/2025.
//

import Foundation

// MARK: - BuildingService

public protocol BuildingService {
  func getBuildings() -> [Building]
}

// MARK: - LiveBuildingService

public final class LiveBuildingService: BuildingService {

  // MARK: Lifecycle

  public init() { }

  // MARK: Public

  public func getBuildings() -> [Building] {
    fatalError("TODO: Implement")
  }
}
