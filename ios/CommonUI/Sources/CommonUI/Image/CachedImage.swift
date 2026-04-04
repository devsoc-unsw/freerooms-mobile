//
//  CachedImage.swift
//  CommonUI
//

import SwiftUI

public struct CachedImage: View {

  // MARK: Lifecycle

  public init(
    name: String,
    bundle: Bundle,
    size: ImageSize = .medium,
    cache: ImageCache = .shared,
    fallbackName: String? = nil,
    fallbackBundle: Bundle? = nil)
  {
    self.name = name
    self.bundle = bundle
    self.size = size
    self.cache = cache
    self.fallbackName = fallbackName
    self.fallbackBundle = fallbackBundle ?? bundle
  }

  // MARK: Public

  public var body: some View {
    Group {
      if let resolved {
        Image(uiImage: resolved)
          .resizable()
      } else {
        Rectangle()
          .fill(.gray.opacity(0.15))
      }
    }
    .task {
      resolved = await cache.getImage(named: name, in: bundle, size: size)
      if resolved == nil, let fallbackName {
        resolved = await cache.getImage(named: fallbackName, in: fallbackBundle, size: size)
      }
    }
  }

  // MARK: Private

  @State private var resolved: UIImage?

  private let name: String
  private let bundle: Bundle
  private let size: ImageSize
  private let cache: ImageCache
  private let fallbackName: String?
  private let fallbackBundle: Bundle
}
