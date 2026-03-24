//
//  CacheConfig.swift
//  CommonUI
//

public struct CacheConfig {

  // MARK: Lifecycle

  public init(
    nsCacheCountLimit: Int = defaultNSCacheCountLimit,
    nsCacheTotalCostLimit: Int = defaultNSCacheTotalCostLimit)
  {
    self.nsCacheCountLimit = nsCacheCountLimit
    self.nsCacheTotalCostLimit = nsCacheTotalCostLimit
  }

  // MARK: Public

  public static let `default` = CacheConfig()

  public let nsCacheCountLimit: Int
  public let nsCacheTotalCostLimit: Int

  // MARK: Private

  private static let defaultNSCacheCountLimit = 50
  private static let defaultNSCacheTotalCostLimit = 50 * 1024 * 1024 // 50 MB
}
