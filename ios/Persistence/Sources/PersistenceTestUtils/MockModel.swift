//
//  MockModel.swift
//  Persistence
//
//  Created by Dicko Evaldo on 4/7/2025.
//
import SwiftData
@testable import Persistence

@Model
nonisolated
class GenericModel: IdentifiableModel, Equatable {

  // MARK: Lifecycle

  nonisolated
  init(stringID: String) {
    self.stringID = stringID
  }

  // MARK: Internal

  nonisolated
  var stringID: String

  nonisolated
  static func ==(lhs: GenericModel, rhs: GenericModel) -> Bool {
    lhs.stringID == rhs.stringID
  }

}
