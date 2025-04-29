//
//  BuildingLoader.swift
//  Buildings
//
//  Created by Chris Wong on 29/4/2025.
//

import Networking

public protocol BuildingLoader: CodableLoader {
  func fetch() async -> Result<[RemoteBuilding], Error>
}
