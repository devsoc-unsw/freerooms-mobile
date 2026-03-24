//
//  CacheConfig.swift
//  CommonUI
//

public struct CacheConfig {

  public let countLimit: Int
  public let totalCostLimit: Int

  public init(countLimit: Int = 50, totalCostLimit: Int = 50 * 1024 * 1024) {
    self.countLimit = countLimit
    self.totalCostLimit = totalCostLimit
  }

  public static let `default` = CacheConfig()
}
