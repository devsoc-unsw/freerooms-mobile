//
//  ImageCache.swift
//  CommonUI
//

import UIKit

// MARK: - ImageCache

/// A shared image cache that stores downsampled thumbnails in an `NSCache`.
///
/// ## Why this exists
///
/// `UIImage(named:)` loads the full-resolution image and caches it in a
/// system cache that doesn't release easily. A 2000x1500 photo decompresses
/// into ~12 MB of bitmap memory. With ~270 bundled photos, scrolling through
/// lists can balloon memory quickly.
///
/// `ImageCache` solves this by:
/// 1. Downsampling to the display size via `preparingThumbnail(of:)` (~480 KB at `.medium`)
/// 2. Storing the small thumbnail in an `NSCache` with configurable limits
///
/// ## Architecture
///
///     View layer (CachedImage)
///         |
///         +-- body: sync lookup via image(named:in:size:)
///                   -> cache hit: instant return from NSCache
///                   -> cache miss: UIImage(named:) + preparingThumbnail(of:)
///                      -> store in NSCache with byte cost
///                      -> return thumbnail
///
/// ## Cache key format
///
/// Keys are `"<imageName>-<pixelSize>"` (e.g. `"K-J17-201-400"`), so the same
/// image at different sizes gets separate cache entries without collisions.
///
/// ## Memory budget
///
/// Default limits via `CacheConfig.default`: 50 items / 50 MB.
/// Approximate per-thumbnail costs (uncompressed bitmap: width × height × 4 bytes/pixel,
/// independent of source format — JPEG, HEIC, etc. decompress to the same bitmap size):
/// - `.small` (200px):  ~120 KB
/// - `.medium` (400px): ~480 KB
/// - `.large` (1000px): ~3 MB
///
/// 50 MB holds ~100 medium thumbnails — enough to scroll through the full
/// buildings list AND a building's room list without evictions. `NSCache`
/// also purges automatically under system memory pressure.
public final class ImageCache {

  // MARK: Lifecycle

  /// Creates a cache with the given configuration.
  ///
  /// - Parameter config: Cache limits. Defaults to `CacheConfig.default`.
  init(config: CacheConfig = .default) {
    cache.countLimit = config.nsCacheCountLimit
    cache.totalCostLimit = config.nsCacheTotalCostLimit
  }

  // MARK: Public

  /// Shared singleton using `CacheConfig.default` limits (50 items / 50 MB).
  public static let shared = ImageCache()

  /// Loads an image from the asset catalog, downsamples it, and caches the result.
  ///
  /// On cache hit, returns the cached thumbnail immediately.
  /// On cache miss, loads via `UIImage(named:)`, downsamples with
  /// `preparingThumbnail(of:)`, stores the result, and returns it.
  /// Falls back to the original image if thumbnail creation fails.
  ///
  /// - Parameters:
  ///   - name: The asset name in the catalog (e.g. `"K-J17-201"`).
  ///   - bundle: The resource bundle containing the asset catalog (e.g. `.module`).
  ///   - size: The target `ImageSize`. Defaults to `.medium` (400px).
  /// - Returns: A downsampled `UIImage`, or `nil` if the asset wasn't found.
  public func image(
    named name: String,
    in bundle: Bundle,
    size: ImageSize = .medium)
    -> UIImage?
  {
    let maxPixelSize = size.rawValue
    let key = "\(name)-\(Int(maxPixelSize))" as NSString

    if let cached = cache.object(forKey: key) {
      return cached
    }

    guard let original = UIImage(named: name, in: bundle, with: nil) else {
      return nil
    }

    let aspectRatio = original.size.width / original.size.height
    let thumbnailSize: CGSize =
      if aspectRatio > 1 {
        CGSize(width: maxPixelSize, height: maxPixelSize / aspectRatio)
      } else {
        CGSize(width: maxPixelSize * aspectRatio, height: maxPixelSize)
      }

    guard let thumbnail = original.preparingThumbnail(of: thumbnailSize) else {
      return original
    }

    let cost = thumbnail.cgImage.map { $0.bytesPerRow * $0.height } ?? 0
    cache.setObject(thumbnail, forKey: key, cost: cost)

    return thumbnail
  }

  /// Removes all cached thumbnails.
  ///
  /// Useful for debugging or a "clear cache" setting. Under normal operation,
  /// `NSCache` handles eviction automatically under memory pressure.
  public func clearCache() {
    cache.removeAllObjects()
  }

  // MARK: Private

  private let cache = NSCache<NSString, UIImage>()

}
