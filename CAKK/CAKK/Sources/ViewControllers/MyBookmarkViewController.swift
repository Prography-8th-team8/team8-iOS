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
  
  private lazy var collectionView = UICollectionView(frame: .zero,
                                                     collectionViewLayout: collectionViewLayout).then {
    $0.registerCell(cellClass: MyBookmarkCakeShopCell.self)
    $0.backgroundColor = .clear
    $0.delaysContentTouches = false
  }
  
  private var collectionViewLayout: UICollectionViewCompositionalLayout = {
    let itemSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .estimated(160))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    
    let group = NSCollectionLayoutGroup.vertical(
      layoutSize: itemSize,
      subitems: [item])
    
    let section = NSCollectionLayoutSection(group: group)
    return UICollectionViewCompositionalLayout(section: section)
  }()
  
  private let headerLabel = UILabel().then {
    $0.text = "북마크한 케이크샵"
    $0.font = .pretendard(size: 16, weight: .bold)
    $0.textColor = .black
  }
  
  private let editButton = UIButton().then {
    $0.setTitle("편집", for: .normal)
    $0.titleLabel?.font = .pretendard(size: 12)
  }
  
  private lazy var headerStackView = UIStackView(arrangedSubviews: [
    headerLabel, editButton
  ]).then {
    $0.axis = .horizontal
  }
  
  private let headerView = UIView()
  
  private let loadingView = UIActivityIndicatorView()
  
  private var emptyStateView = EmptyStateView(
    title: "북마크한 케이크샵이 없어요"
  ).then {
    $0.isHidden = true
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
  }
  
  private func bindOutput(_ viewModel: ViewModel) {
    viewModel.output.bookmarks.sink { [weak self] bookmarks in
      self?.applySnapshot(with: bookmarks)
    }
    .store(in: &cancellables)
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
    view.addSubview(headerView)
    headerView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(10)
      $0.horizontalEdges.equalToSuperview()
    }
    headerView.addBorder(to: .bottom, color: R.color.gray_5(), width: 2)
    
    headerView.addSubview(headerStackView)
    headerStackView.snp.makeConstraints {
      $0.edges.equalToSuperview().inset(16)
    }
  }
  
  private func setupCollectionViewLayout() {
    view.addSubview(collectionView)
    collectionView.snp.makeConstraints {
      $0.top.equalTo(headerView.snp.bottom)
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
      cellProvider: { collectionView, indexPath, item in
        let cell = collectionView.dequeueReusableCell(
          cellClass: MyBookmarkCakeShopCell.self,
          for: indexPath)
        
        cell.configure(item)
        
        return cell
      })
  }
  
  private func applySnapshot(with bookmarks: [Bookmark]) {
    collectionView.scrollToTop(animated: false)
    
    let section: [Section] = [.bookmarkedCakeshop]
    var snapshot = NSDiffableDataSourceSnapshot<Section, Bookmark>()
    snapshot.appendSections(section)
    snapshot.appendItems(bookmarks)
    dataSource.apply(snapshot)
  }
}
