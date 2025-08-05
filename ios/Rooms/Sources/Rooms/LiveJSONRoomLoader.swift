//
//  LiveJSONRoomLoader.swift
//  Rooms
//
//  Created by Chris Wong on 5/8/2025.
//

public enum JSONRoomLoaderError: Error {
  case malformedJSON, invalidURL
}

public struct LiveJSONRoomLoader {

  private let loader: any JSONLoader<[DecodableRoom]>
  
  public init(using loader: any JSONLoader<[DecodableRoom]>) {
    self.loader = loader
  }

  
  public typealias Result = Swift.Result<[Room], JSONRoomLoaderError>
  
  public func load(from filename: String) -> Result {
    fatalError("Not implemented yet")
  }
  
  public func fetch() -> Result {
    fatalError("Not implemented yet")
  }
  
}
