//
//  MockModel.swift
//  Persistence
//
//  Created by Dicko Evaldo on 4/7/2025.
//

import PersistenceServices
import SwiftData

@Model
class GenericModel: IdentifiableModel, Equatable {

  // MARK: Lifecycle

  init(stringID: String) {
    self.stringID = stringID
  }

  // MARK: Internal

  var stringID: String

  static func ==(lhs: GenericModel, rhs: GenericModel) -> Bool {
    lhs.stringID == rhs.stringID
  }

}
