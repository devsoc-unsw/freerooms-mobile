import Foundation

/// The base `protocol` for Freerooms errors
public protocol FreeroomsError: LocalizedError {
  /// The message to show to the client when this error occurs
  ///
  /// This makes sure an error description is provided,
  /// over ``LocalizedError``s optional `errorDescription`.
  var errorDescription: String { get }
}
