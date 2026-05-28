extension Error {
  
  /// Checks if 2 errors are 'similar'
  ///
  /// This method first checks if the errors are the same type.
  /// If an equatable conformance is available, that is used as well.
  public func isSimilar(to other: any Error) -> Bool {
    // Check if the types are the same
    guard let other = other as? Self else { return false }
    
    // If the error is Equatable, use that
    if let eqSelf = _EquatableWrapper(self), let eqOther = _EquatableWrapper(other) {
      return eqSelf.wrapped.isEqual(to: eqOther.wrapped)
    }
    
    return true
  }
  
}

// FIXME: Use downcast to Equatable when https://github.com/swiftlang/swift/issues/70114 is fixed
private struct _EquatableWrapper {
  var wrapped: any Equatable
  
  init?(_ base: Any) {
    guard let base = base as? any Equatable else { return nil }
    self.wrapped = base
  }
  
}

private extension Equatable {
  
  func isEqual(to other: any Equatable) -> Bool {
    guard let other = other as? Self else { return false }
    return self == other
  }
  
}
