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
    fallbackName: String? = nil,
    fallbackBundle: Bundle? = nil)
  {
    self.name = name
    self.bundle = bundle
    self.size = size
    self.fallbackName = fallbackName
    self.fallbackBundle = fallbackBundle ?? bundle
  }

  // MARK: Public

  public var body: some View {
    let resolved = ImageCache.shared.image(named: name, in: bundle, size: size)
      ?? fallbackName.flatMap { ImageCache.shared.image(named: $0, in: fallbackBundle, size: size) }

    if let resolved {
      Image(uiImage: resolved)
        .resizable()
    } else {
      Rectangle()
        .fill(.gray.opacity(0.15))
    }
  }

  // MARK: Private

  private let name: String
  private let bundle: Bundle
  private let size: ImageSize
  private let fallbackName: String?
  private let fallbackBundle: Bundle
}
