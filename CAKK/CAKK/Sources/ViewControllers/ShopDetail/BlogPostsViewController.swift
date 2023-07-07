//
//  BlogPostsViewController.swift
//  CAKK
//
//  Created by Mason Kim on 2023/07/04.
//

import UIKit

import Combine
import CombineCocoa

import SnapKit
import Then


final class BlogPostsViewController: UICollectionViewController {
  
  
  // MARK: - Constants
  
  enum Metric {
    static let horizontalPadding = 14.f
  }
  
  
  // MARK: - Types
  
  enum Section {
    case blogPost
  }
  
  typealias BlogPostDataSource = UICollectionViewDiffableDataSource<Section, BlogPost>
  
  
  // MARK: - Properties
  
  private let viewModel: ShopDetailViewModel
  
  private lazy var blogPostDataSource = makeBlogPostDataSource()
  
  private var cancellables = Set<AnyCancellable>()
  
  
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
  
  // 아이패드 레이아웃 호환을 위해 bounds가 변경될 때 마다 새롭게 잡아주도록 함
  // (플로팅 패널의 사이즈가 전체를 덮지 않을 수 있기에)
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
    layout.minimumLineSpacing = 0
    layout.itemSize = CGSize(width: view.bounds.width - (Metric.horizontalPadding * 2), height: 150)
    layout.footerReferenceSize = CGSize(width: collectionView.bounds.width, height: 50)
  }
  
  
  // MARK: - Setups
  
  private func setup() {
    setupCollectionView()
  }
  
  
  // MARK: - Bind
  
  private func bind() {
    bindOutput()
  }
  
  private func bind(loadMoreBlogPostButton: UIButton) {
    loadMoreBlogPostButton.tapPublisher
      .throttle(for: 1, scheduler: DispatchQueue.main, latest: false)
      .sink { [weak self] in
        self?.viewModel.input.loadMoreBlogPosts.send()
      }
      .store(in: &cancellables)
  }
  
  private func bindOutput() {
    viewModel.output.blogPostsToShow
      .sink { [weak self] blogPosts in
        self?.applySnapshot(with: blogPosts)
      }
      .store(in: &cancellables)
  }
  
  // MARK: - Public Methods
  
  func blogPost(of indexPath: IndexPath) -> BlogPost? {
    return blogPostDataSource.itemIdentifier(for: indexPath)
  }

}


// MARK: - UI & Layouts

extension BlogPostsViewController {
  
  private func setupCollectionView() {
    collectionView.registerCell(cellClass: BlogPostCell.self)
    collectionView.registerFooterView(viewClass: LoadMoreBlogPostFooterView.self)
    collectionView.addBorder(to: .bottom, color: R.color.gray_5())
  }
}


// MARK: - DataSource & Snapshot

extension BlogPostsViewController {
  
  private func makeBlogPostDataSource() -> BlogPostDataSource {
    let dataSource = BlogPostDataSource(
      collectionView: collectionView,
      cellProvider: { collectionView, indexPath, item in
        let cell = collectionView.dequeueReusableCell(cellClass: BlogPostCell.self,
                                                      for: indexPath)
        cell.configure(with: item)
        return cell
      })
    
    dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
      guard kind == UICollectionView.elementKindSectionFooter else { return nil }
      let footerView = collectionView.dequeueReusableFooterView(ofType: LoadMoreBlogPostFooterView.self,
                                                                for: indexPath)
      self?.bind(loadMoreBlogPostButton: footerView.button)
      return footerView
    }
    
    return dataSource
  }
  
  private func applySnapshot(with blogPosts: [BlogPost]) {
    let section: [Section] = [.blogPost]
    var snapshot = NSDiffableDataSourceSnapshot<Section, BlogPost>()
    snapshot.appendSections(section)
    snapshot.appendItems(blogPosts)
    
    blogPostDataSource.apply(snapshot)
  }
}

//extension BlogPostsViewController {
//  override func collectionView(_ collectionView: UICollectionView,
//                               viewForSupplementaryElementOfKind kind: String,
//                               at indexPath: IndexPath) -> UICollectionReusableView {
//    guard kind == UICollectionView.elementKindSectionFooter else {
//      return UICollectionReusableView()
//    }
//
//    let footerView = collectionView.dequeueReusableFooterView(ofType: LoadMoreBlogPostFooterView.self,
//                                                              for: indexPath)
//    bind(loadMoreBlogPostButton: footerView.button)
//    return footerView
//  }
//}
