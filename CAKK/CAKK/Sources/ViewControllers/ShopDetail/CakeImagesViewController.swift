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


final class CakeImagesViewController: UICollectionViewController {
  
  
  // MARK: - Types
  
  enum Section {
    case cakeImage
  }
  
  typealias DataSource = UICollectionViewDiffableDataSource<Section, String>
  
  
  // MARK: - Properties
  
  private let viewModel: ShopDetailViewModel
  
  private lazy var blogPostDataSource = makeShopImageDataSource()
  
  private var cancellables = Set<AnyCancellable>()
  
  
  // MARK: - UI Components
  
  private let emptyStateView = EmptyStateView(
    title: "표시할 데이터가 없어요!",
    subTitle: "빠른 시일내에 준비하겠습니다."
  ).then {
    $0.isHidden = true
  }
  
  // MARK: - Initialization
  
  init(viewModel: ShopDetailViewModel, collectionViewLayout: UICollectionViewLayout) {
    self.viewModel = viewModel
    super.init(collectionViewLayout: collectionViewLayout)
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
    bindInput()
    bindOutput()
  }
  
  private func bindInput() {
    
  }
  
  private func bindOutput() {
    viewModel.output.cakeShopDetail
      .sink { [weak self] shopDetail in
        guard let imageUrls = shopDetail?.imageUrls else { return }
        self?.applySnapshot(with: imageUrls)
      }
      .store(in: &cancellables)
  }
  
}


// MARK: - UI & Layouts

extension CakeImagesViewController {
  
  private func setupLayout() {
    setupEmptyStateViewLayout()
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
    
    blogPostDataSource.apply(snapshot)
  }
  
}
