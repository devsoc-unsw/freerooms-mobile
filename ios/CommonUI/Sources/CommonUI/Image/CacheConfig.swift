//
//  CacheConfig.swift
//  CommonUI
//

public struct CacheConfig {

  // MARK: Lifecycle

  public init(
    maxItemCount: Int = defaultMaxItemCount,
    maxByteCount: Int = defaultMaxByteCount)
  {
    self.maxItemCount = maxItemCount
    self.maxByteCount = maxByteCount
  }

  // MARK: Public

  public static let `default` = CacheConfig()

  public static let defaultMaxItemCount = 50
  public static let defaultMaxByteCount = 50 * 1024 * 1024 // 50 MB

  public let maxItemCount: Int
  public let maxByteCount: Int

}
