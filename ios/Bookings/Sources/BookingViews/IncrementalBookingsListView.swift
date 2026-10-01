//
//  IncrementalBookingsListView.swift
//  Bookings
//
//  Created by Matthew Yuen on 1/10/2026.
//

public import BookingModels
public import SwiftUI
public import UIKit

public final class IncrementalBookingsListViewController<CellView: View>: UIViewController {

  // MARK: Lifecycle

  public init(
    @ViewBuilder cellProvider: @escaping (_ booking: WeeklyBooking) -> CellView)
  {
    self.cellProvider = cellProvider
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable, message: "init(coder:) has not been implemented")
  required init?(coder _: NSCoder) {
    preconditionFailure("init(coder:) has not been implemented")
  }

  // MARK: Public

  public override func loadView() {
    view = UICollectionView(frame: .zero, collectionViewLayout: createCollectionViewLayout())
  }

  public override func viewDidLoad() {
    super.viewDidLoad()
    configure()
  }

  // MARK: Internal

  enum Section: Int {
    case main = 0
  }

  // MARK: Private

  private var dataSource: UICollectionViewDiffableDataSource<Section, WeeklyBooking>!
  private let cellProvider: (WeeklyBooking) -> CellView

  private var collectionView: UICollectionView { view as! UICollectionView }

  private func createCollectionViewLayout() -> UICollectionViewLayout {
    let itemHeight = NSCollectionLayoutDimension.estimated(44)
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: itemHeight)
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: itemHeight)
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
    let section = NSCollectionLayoutSection(group: group)
    return UICollectionViewCompositionalLayout(section: section)
  }

  private func configure() {
    configureCollectionView()
  }

  private func configureCollectionView() {
    let listCellConfiguration = UICollectionView.CellRegistration<UICollectionViewListCell, WeeklyBooking>
    { [cellProvider] cell, _, item in
      cell.contentConfiguration = UIHostingConfiguration {
        cellProvider(item)
      }
    }

    dataSource = .init(collectionView: collectionView) { collectionView, indexPath, item in
      guard let section = Section(rawValue: indexPath.section) else { return nil }
      switch section {
      case .main:
        return collectionView.dequeueConfiguredReusableCell(using: listCellConfiguration, for: indexPath, item: item)
      }
    }
  }

}

#Preview {
  let vc = IncrementalBookingsListViewController {
    Text($0.title)
  }
  return UINavigationController(rootViewController: vc)
}
