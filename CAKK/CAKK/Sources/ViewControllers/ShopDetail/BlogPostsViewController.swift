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
  
  
  // MARK: - Types
  
  enum Section {
    case blogPost
  }
  
  typealias BlogPostDataSource = UICollectionViewDiffableDataSource<Section, BlogPost>
  
  
  // MARK: - Properties
  
  private let viewModel: ShopDetailViewModel
  
  private lazy var blogPostDataSource = makeBlogPostDataSource()
  
  private var cancellables = Set<AnyCancellable>()
  
  
  // MARK: - UI Components
  
  // TODO: 컬렉션뷰의 푸터로 처리해야 할 듯
  private let loadMoreBlogPostsButton = UIButton().then {
    $0.titleLabel?.font = .pretendard(size: 14, weight: .bold)
    $0.layer.borderColor = R.color.gray_5()?.cgColor
    $0.layer.borderWidth = 2
    $0.layer.cornerRadius = 8
    $0.setTitle("블로그 리뷰 더 보기", for: .normal)
    $0.setTitleColor(.black, for: .normal)
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
    loadMoreBlogPostsButton.tapPublisher
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
  
  private func setupLayout() {
    
//    contentStackView.addArrangedSubview(loadMoreBlogPostsButton)
//    loadMoreBlogPostsButton.snp.makeConstraints {
//      $0.height.equalTo(48)
//      $0.horizontalEdges.equalTo(blogPostCollectionView).inset(Metric.horizontalPadding)
//    }
  }
  
  private func setupCollectionView() {
    collectionView.registerCell(cellClass: BlogPostCell.self)
    collectionView.addBorder(to: .bottom, color: R.color.gray_5())
  }
}


// MARK: - DataSource & Snapshot

extension BlogPostsViewController {
  
  private func makeBlogPostDataSource() -> BlogPostDataSource {
    return BlogPostDataSource(
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
