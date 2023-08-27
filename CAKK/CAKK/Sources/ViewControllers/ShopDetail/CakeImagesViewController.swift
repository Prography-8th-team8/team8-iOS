//
//  CakeImagesViewController.swift
//  CAKK
//
//  Created by Mason Kim on 2023/07/04.
//


import UIKit

import Combine
import CombineCocoa

import SnapKit
import Then


final class CakeImagesViewController: UIViewController {
  
  
  // MARK: - Types
  
  enum Section {
    case cakeImage
  }
  
  typealias DataSource = UICollectionViewDiffableDataSource<Section, String>
  
  
  // MARK: - Properties
  
  private let viewModel: ShopDetailViewModel
  
  private lazy var dataSource = makeShopImageDataSource()
  
  private var cancellables = Set<AnyCancellable>()
  
  lazy var collectionView = UICollectionView(frame: .zero,
                                             collectionViewLayout: layout)
  
  private var layout: UICollectionViewCompositionalLayout {
    let itemSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1),
      heightDimension: .fractionalHeight(1))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    
    let groupSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1),
      heightDimension: .fractionalWidth(1 / 3))
    let group = NSCollectionLayoutGroup.horizontal(
      layoutSize: groupSize,
      subitem: item,
      count: 3)
    group.interItemSpacing = .fixed(3)
    
    let section = NSCollectionLayoutSection(group: group)
    section.interGroupSpacing = 3
    return UICollectionViewCompositionalLayout(section: section)
  }
  
  
  // MARK: - UI Components
  
  private let emptyStateView = EmptyStateView(
    title: "표시할 데이터가 없어요!",
    subTitle: "빠른 시일내에 준비하겠습니다."
  ).then {
    $0.isHidden = true
  }
  
  // MARK: - Initialization
  
  init(viewModel: ShopDetailViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
    bind()
  }
  
  
  // MARK: - Setups
  
  private func setup() {
    setupLayout()
    setupCollectionView()
  }
  
  
  // MARK: - Bind
  
  private func bind() {
    bindOutput()
  }
  
  private func bindOutput() {
    viewModel.output.cakeShopDetail
      .sink { [weak self] shopDetail in
        guard let imageUrls = shopDetail?.imageUrls else { return }
        guard imageUrls.isEmpty == false else {
          self?.emptyStateView.isHidden = false
          return
        }

        self?.applySnapshot(with: imageUrls)
      }
      .store(in: &cancellables)
  }
  
  
  // MARK: - Public Methods
  
  func cakeImageURL(of indexPath: IndexPath) -> String? {
    return dataSource.itemIdentifier(for: indexPath)
  }
}


// MARK: - UI & Layouts

extension CakeImagesViewController {
  
  private func setupLayout() {
    setupCollectionViewLayout()
    setupEmptyStateViewLayout()
  }
  
  private func setupCollectionViewLayout() {
    view.addSubview(collectionView)
    collectionView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  
  private func setupEmptyStateViewLayout() {
    view.addSubview(emptyStateView)
    emptyStateView.snp.makeConstraints {
      $0.center.equalToSuperview()
    }
  }
  
  private func setupCollectionView() {
    collectionView.registerCell(cellClass: CakeImageCell.self)
    collectionView.addBorder(to: .bottom, color: R.color.gray_5())
  }
}


// MARK: - DataSource & Snapshot

extension CakeImagesViewController {
  
  private func makeShopImageDataSource() -> DataSource {
    return DataSource(
      collectionView: collectionView,
      cellProvider: { collectionView, indexPath, item in
        let cell = collectionView.dequeueReusableCell(cellClass: CakeImageCell.self,
                                                      for: indexPath)
        cell.configure(imageURL: item)
        return cell
      })
  }
  
  private func applySnapshot(with imageURLs: [String]) {
    let section: [Section] = [.cakeImage]
    var snapshot = NSDiffableDataSourceSnapshot<Section, String>()
    snapshot.appendSections(section)
    snapshot.appendItems(imageURLs)
    
    dataSource.apply(snapshot)
  }
  
}
