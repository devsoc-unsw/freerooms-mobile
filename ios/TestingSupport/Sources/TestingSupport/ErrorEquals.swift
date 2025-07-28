//
//  ErrorEquals.swift
//  TestingSupport
//
//  Created by Chris Wong on 29/7/2025.
//

public func checkErrorEquals<T: Error & Equatable>(
  _ given: Error,
  equals expected: Error,
  as _: T.Type)
  -> Bool
{
  guard let actual = given as? T, let expected = expected as? T else {
    return false
  }
  return actual == expected
}
