//
//  Room.swift
//  Persistence
//
//  Created by Chris Wong on 26/6/2025.
//

public struct Room: Equatable {
  public let name: String
  public let id: String
  public let abbreviation: String
  public let capacity: Int
  public let usage: String
  public let school: String

  public init(name: String, id: String, abbreviation: String, capacity: Int, usage: String, school: String) {
    self.name = name
    self.id = id
    self.abbreviation = abbreviation
    self.capacity = capacity
    self.usage = usage
    self.school = school
  }
}
