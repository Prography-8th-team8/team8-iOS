//
//  MyBookmark.swift
//  CAKK
//
//  Created by Mason Kim on 2023/07/30.
//

import UIKit

import Combine

import SnapKit
import Then


final class MyBookmarkViewController: UIViewController {
  
  // MARK: - Constants
  
  enum Metric {
    
  }
  
  
  // MARK: - Types
  
  typealias ViewModel = MyBookmarkViewModel
  typealias DataSource = UICollectionViewDiffableDataSource<Section, Bookmark>
  
  enum Section {
    case bookmarkedCakeshop
  }
  
  
  // MARK: - Properties
  
  private let viewModel: ViewModel
  private var cancellables = Set<AnyCancellable>()
  
  private lazy var dataSource: DataSource = makeDataSource()
  
  
  // MARK: - UI
  
  private lazy var collectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: collectionViewLayout).then {
      $0.registerCell(cellClass: MyBookmarkCakeShopCell.self)
      $0.backgroundColor = .clear
      $0.delaysContentTouches = false
    }
  
  private var collectionViewLayout: UICollectionViewCompositionalLayout = {
    let itemSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .estimated(208))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    
    let group = NSCollectionLayoutGroup.vertical(
      layoutSize: itemSize,
      subitems: [item])
    
    let section = NSCollectionLayoutSection(group: group)
    return UICollectionViewCompositionalLayout(section: section)
  }()
  
  private let titleLabel = PaddingLabel(top: 10, left: 20, bottom: 10).then {
    $0.text = "내가 찜한 케이크샵"
    $0.font = .pretendard(size: 20, weight: .bold)
    $0.textColor = .black
    $0.addBorder(to: .bottom, color: R.color.gray_5(), width: 1)
  }
  
  private lazy var headerStackView = UIStackView(arrangedSubviews: [titleLabel]).then {
    $0.axis = .vertical
  }
  
  private let loadingView = UIActivityIndicatorView()
  
  private var emptyStateView = EmptyStateView(
    title: "북마크한 케이크샵이 없어요"
  ).then {
    $0.isHidden = true
  }
  
  private lazy var refreshControl = UIRefreshControl().then {
    collectionView.refreshControl = $0
  }
  
  
  // MARK: - Initialization
  
  init(viewModel: ViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  // MARK: - LifeCycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
    bind(viewModel)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    viewModel.input.viewWillAppear.send()
  }
  
  
  // MARK: - Private
  
  private func bind(_ viewModel: ViewModel) {
    bindInput(viewModel)
    bindOutput(viewModel)
  }
  
  private func bindInput(_ viewModel: ViewModel) {
    collectionView.didSelectItemPublisher.sink { [weak self] indexPath in
      guard let self = self,
            let item = dataSource.itemIdentifier(for: indexPath) else { return }
      showCakeShopDetail(item.id)
    }
    .store(in: &cancellables)
    
    refreshControl.isRefreshingPublisher.sink { isRefreshed in
      guard isRefreshed else { return }
      DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
        viewModel.input.viewWillAppear.send()
        self.refreshControl.endRefreshing()
      }
    }
    .store(in: &cancellables)
  }
  
  private func bindOutput(_ viewModel: ViewModel) {
    viewModel.output.bookmarks.sink { [weak self] bookmarks in
      guard let self = self else { return }
      self.applySnapshot(with: bookmarks)
      self.emptyStateView.isHidden = !bookmarks.isEmpty
    }
    .store(in: &cancellables)
  }
  
  private func showCakeShopDetail(_ id: Int) {
    let viewController = DIContainer.shared.makeShopDetailViewController(with: id)
    viewController.isFullState = true
    viewController.modalPresentationStyle = .fullScreen
    present(viewController, animated: true)
  }
}


// MARK: - UI & Layout

extension MyBookmarkViewController {
  
  private func setup() {
    setupLayout()
    setupView()
  }
  
  // Setup Layouts
  private func setupLayout() {
    setupHeaderViewLayout()
    setupCollectionViewLayout()
    setupLoadingViewLayout()
    setupNoDataViewLayout()
  }
  
  private func setupHeaderViewLayout() {
    view.addSubview(headerStackView)
    headerStackView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(10)
      $0.horizontalEdges.equalToSuperview()
    }
  }
  
  private func setupCollectionViewLayout() {
    view.addSubview(collectionView)
    collectionView.snp.makeConstraints {
      $0.top.equalTo(headerStackView.snp.bottom)
      $0.horizontalEdges.bottom.equalToSuperview()
    }
  }
  
  private func setupLoadingViewLayout() {
    view.addSubview(loadingView)
    loadingView.snp.makeConstraints {
      $0.center.equalToSuperview()
    }
  }
  
  private func setupNoDataViewLayout() {
    view.addSubview(emptyStateView)
    emptyStateView.snp.makeConstraints {
      $0.center.equalToSuperview()
    }
  }
  
  // Setup Views
  private func setupView() {
    view.backgroundColor = .white
  }
}


// MARK: - DataSource & Snapshot

extension MyBookmarkViewController {
  
  private func makeDataSource() -> DataSource {
    DataSource(
      collectionView: collectionView,
      cellProvider: { [weak self] collectionView, indexPath, item in
        let cell = collectionView.dequeueReusableCell(
          cellClass: MyBookmarkCakeShopCell.self,
          for: indexPath)
        let viewModel = DIContainer.shared.makeMyBookmarkCellViewModel(bookmark: item)
        cell.configure(viewModel: viewModel)
        
        return cell
      })
  }
  
  private func applySnapshot(with bookmarks: [Bookmark]) {
    collectionView.scrollToTop(animated: false)
    
    let section: [Section] = [.bookmarkedCakeshop]
    var snapshot = NSDiffableDataSourceSnapshot<Section, Bookmark>()
    snapshot.appendSections(section)
    snapshot.appendItems(bookmarks)
    dataSource.apply(snapshot, animatingDifferences: false)
  }
}
