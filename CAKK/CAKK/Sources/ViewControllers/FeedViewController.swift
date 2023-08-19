//
//  FeedViewController.swift
//  CAKK
//
//  Created by 이승기 on 2023/07/30.
//

import UIKit

import Combine
import CombineCocoa

final class FeedViewController: UIViewController {
  
  // MARK: - Constants
  
  enum Metric {
    static let collectionViewSpacing = 3.f
  }
  
  
  // MARK: - Types
  
  enum Section {
    case feed
  }
  
  typealias DataSource = UICollectionViewDiffableDataSource<Section, Feed>
  
  
  // MARK: - Properties
  
  public var coordinator: FeedCoordinator?
  
  private let viewModel: FeedViewModel
  private var cancellableBag = Set<AnyCancellable>()
  
  private lazy var dataSource: DataSource = makeDatasource()
  private let cellRegistration = UICollectionView.CellRegistration<FeedCell, Feed> { _, _, _ in }
  
  private var oldLayout: CGRect = .zero
  
  
  // MARK: - UI
  
  private let titleLabel = PaddingLabel(top: 10, left: 20, bottom: 10).then {
    $0.text = "Feed"
    $0.font = .pretendard(size: 20, weight: .bold)
    $0.textColor = .black
    $0.addBorder(to: .bottom, color: R.color.gray_5(), width: 1)
  }
  private lazy var navigationView = UIStackView(arrangedSubviews: [titleLabel]).then {
    $0.axis = .vertical
    $0.backgroundColor = .white
  }
  
  lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
  private var collectionViewLayout: UICollectionViewCompositionalLayout = {
    let screenWidth = UIScreen.main.bounds.size.width
    let spacing = Metric.collectionViewSpacing

    var itemWidth: CGFloat = 0
    var itemCount: CGFloat = 3 // default itemCount, adjust as per requirement

    if screenWidth < 500 {
        itemCount = 3
    } else if screenWidth >= 500 && screenWidth < 700 {
        itemCount = 4
    } else if screenWidth >= 700 {
        itemCount = 5
    }

    itemWidth = (screenWidth - (itemCount - 1) * spacing) / itemCount
    
    let itemSize = NSCollectionLayoutSize(
      widthDimension: .absolute(itemWidth),
      heightDimension: .absolute(itemWidth))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    
    let groupSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1),
      heightDimension: .absolute(itemWidth))
    let group = NSCollectionLayoutGroup.horizontal(
      layoutSize: groupSize,
      subitem: item,
      count: Int(itemCount))
    group.interItemSpacing = .fixed(spacing)
    
    let section = NSCollectionLayoutSection(group: group)
    section.interGroupSpacing = spacing
    return UICollectionViewCompositionalLayout(section: section)
  }()
  
  
  // MARK: - Initializers
  
  init(viewModel: FeedViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not ben implemented")
  }
  
  
  // MARK: - LifeCycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
    bind()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    navigationController?.setNavigationBarHidden(true, animated: false)
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    if oldLayout != view.frame {
      updateCollectionViewLayout()
      
      oldLayout = view.frame
    }
  }
  
  
  // MARK: - Binds

  private func bind() {
    bindInput()
    bindOutput()
  }
  
  private func bindInput() {
    collectionView
      .reachedBottomPublisher()
      .sink { [weak self] in
        self?.viewModel.fetchFeedData()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
      }
      .store(in: &cancellableBag)
    
    collectionView
      .didSelectItemPublisher
      .sink { [weak self] indexPath in
        self?.viewModel.input.didSelectItem.send(indexPath)
      }
      .store(in: &cancellableBag)
  }
  
  private func bindOutput() {
    viewModel.output
      .feedData
      .sink { [weak self] feeds in
        self?.applySnapshot(with: feeds)
      }
      .store(in: &cancellableBag)
    
    viewModel.output
      .showFeedDetail
      .sink { [weak self] feed in
        self?.coordinator?.eventOccurred(event: .tapFeed(feed))
      }
      .store(in: &cancellableBag)
  }
  
  
  // MARK: - Private
  
  private func updateCollectionViewLayout() {
    collectionView.collectionViewLayout.invalidateLayout()
    collectionView.setCollectionViewLayout(collectionViewLayout, animated: true)
  }
}


// MARK: - UI & Layout

extension FeedViewController {
  
  private func setup() {
    setupLayout()
    setupBaseView()
    setupData()
  }
  
  // Layout
  
  private func setupLayout() {
    setupNavigationViewLayout()
    setupCollectionViewLayout()
  }
  
  private func setupNavigationViewLayout() {
    view.addSubview(navigationView)
    navigationView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(10)
      $0.horizontalEdges.equalToSuperview()
    }
  }
  
  private func setupCollectionViewLayout() {
    view.addSubview(collectionView)
    collectionView.snp.makeConstraints {
      $0.top.equalTo(navigationView.snp.bottom)
      $0.leading.trailing.bottom.equalToSuperview()
    }
  }
  
  // View
  
  private func setupView() {
    setupBaseView()
  }
  
  private func setupBaseView() {
    view.backgroundColor = .white
  }
  
  // Data
  
  private func setupData() {
    setupFeedData()
  }
  
  private func setupFeedData() {
    viewModel.fetchFeedData()
  }
}


// MARK: - DataSource & Snapshot

extension FeedViewController {
  
  private func makeDatasource() -> DataSource {
    DataSource(collectionView: collectionView) { [weak self] collectionView, indexPath, item in
      guard let self else { return UICollectionViewCell() }
      
      let cell = collectionView.dequeueConfiguredReusableCell(
        using: self.cellRegistration,
        for: indexPath,
        item: item)
      cell.configure(feed: item)
      
      return cell
    }
  }
  
  private func applySnapshot(with feeds: [Feed]) {
    let section: [Section] = [.feed]
    var snapshot = NSDiffableDataSourceSnapshot<Section, Feed>()
    snapshot.appendSections(section)
    snapshot.appendItems(feeds)
    dataSource.apply(snapshot)
  }
}
