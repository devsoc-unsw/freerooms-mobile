//
//  BuildingService.swift
//  Buildings
//
//  Created by Anh Nguyen on 22/4/2025.
//

import Foundation

// MARK: - BuildingServiceProtocol

public protocol BuildingServiceProtocol {
  func getBuildings() -> [Building]
}

// MARK: - BuildingService

public final class BuildingService: BuildingServiceProtocol {

  // MARK: Lifecycle

  public init() { }

  // MARK: Public

  public func getBuildings() -> [Building] {
    fatalError("TODO: Implement")
  }
}
