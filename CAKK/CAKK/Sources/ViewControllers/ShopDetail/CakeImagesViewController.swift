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
    case shopImage
  }
  
  typealias DataSource = UICollectionViewDiffableDataSource<Section, UIImage>
  
  
  // MARK: - Properties
  
  private let viewModel: ShopDetailViewModel
  
  private lazy var blogPostDataSource = makeShopImageDataSource()
  
  private var cancellables = Set<AnyCancellable>()
  
  
  // MARK: - UI Components
  
  // TODO: noData 뷰 구현 _ 이미지 없을 시 나타낼...
  
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
      .sink { shopDetail in
        print(shopDetail)
      }
      .store(in: &cancellables)
  }
  
}


// MARK: - UI & Layouts

extension CakeImagesViewController {
  
  private func setupLayout() {
    
  }
  
  private func setupCollectionView() {
    collectionView.registerCell(cellClass: BlogPostCell.self)
    collectionView.addBorder(to: .bottom, color: R.color.gray_5())
  }
}


// MARK: - DataSource & Snapshot

extension CakeImagesViewController {
  
  private func makeShopImageDataSource() -> DataSource {
    return DataSource(
      collectionView: collectionView,
      cellProvider: { collectionView, indexPath, item in
        let cell = collectionView.dequeueReusableCell(cellClass: BlogPostCell.self,
                                                      for: indexPath)
        cell.configure(with: item)
        return cell
      })
  }
  
  private func applySnapshot(with blogPosts: [BlogPost]) {
    let section: [Section] = [.blogPost]
    var snapshot = NSDiffableDataSourceSnapshot<Section, BlogPost>()
    snapshot.appendSections(section)
    snapshot.appendItems(blogPosts)
    
    blogPostDataSource.apply(snapshot)
  }
  
}
