//
//  CakeShopListViewController.swift
//  CAKK
//
//  Created by Mason Kim on 2023/04/03.
//

import UIKit

import CoreLocation

import Combine

import SnapKit
import Then

import EasyTipView
import FloatingPanel
import SkeletonView

final class CakeShopListViewController: UIViewController {
  
  // MARK: - Constants
  
  enum Metric {
    static let padding = 20.f
    static let cornerRadius = 16.f
    
    static let headerViewHeight = 100.f
    
    static let collectionViewItemEstimatedHeight = 250.f
    static let collectionViewHorizontalPadding = 16.f
    static let collectionViewBottomInset = 88.f
    
    static let locationLabelFontSize = 18.f
    static let numberOfCakeShopFontSize = 14.f
    
    static let changeDistrictWidth = 75.f
    static let changeDistrictHeight = 36.f
    static let changeDistrictCornerRadius = 12.f
    static let changeDistrictFontSize = 12.f
    
    static let labelsStackViewSpacing = 12.f
    
    static let cakeTableViewItemSpacing = 10.f
  }

  
  // MARK: - Types
  
  typealias ViewModel = MainViewModel
  typealias DataSource = UICollectionViewDiffableDataSource<Section, CakeShop>
  
  enum Section {
    case cakeShop
  }
  
  // MARK: - Properties
  
  weak var viewModel: ViewModel?
  private var cancellableBag = Set<AnyCancellable>()
  
  public var cakeShopItemSelectHandler: ((CakeShop) -> Void)?
  private lazy var dataSource: DataSource = makeDataSource()
  private var cakeShopCellRegistration = UICollectionView.CellRegistration<CakeShopCollectionCell, CakeShop> { _, _, _ in }
  
  @UserDefault(key: "app.isfirstopen", defaultValue: true)
  private var isFirstOpen: Bool
  
  public var filterButtonTapHandler: (() -> Void)?
  
  
  // MARK: - UI
  
  lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout).then {
    $0.registerCell(cellClass: CakeShopCollectionCell.self)
    $0.backgroundColor = .clear
    $0.delaysContentTouches = false
    $0.contentInset = .init(top: 0, left: 0, bottom: Metric.collectionViewBottomInset, right: 0)
  }
  
  private var collectionViewLayout: UICollectionViewCompositionalLayout = {
    let itemSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .estimated(Metric.collectionViewItemEstimatedHeight))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    
    let group = NSCollectionLayoutGroup.vertical(
      layoutSize: itemSize,
      subitems: [item])
    
    let section = NSCollectionLayoutSection(group: group)
    return UICollectionViewCompositionalLayout(section: section)
  }()
  
  private let headerView = UIView()
  
  private let headerLabel = UILabel().then {
    $0.text = "이 근처 케이크샵"
    $0.font = .pretendard(size: Metric.locationLabelFontSize, weight: .bold)
    $0.textColor = .black
    
    // Skeleton
    $0.isSkeletonable = true
    $0.linesCornerRadius = 6
    $0.skeletonTextLineHeight = .fixed(22)
  }
  
  private let numberOfCakeShopLabel = UILabel().then {
    $0.font = .systemFont(ofSize: Metric.numberOfCakeShopFontSize)
    $0.textColor = .black.withAlphaComponent(0.8)
    
    // Skeleton
    $0.isSkeletonable = true
    $0.linesCornerRadius = 4
  }
  
  private lazy var labelsStack = UIStackView(
    arrangedSubviews: [headerLabel, numberOfCakeShopLabel]
  ).then {
    $0.alignment = .leading
    $0.axis = .vertical
    $0.spacing = Metric.labelsStackViewSpacing
  }
  
  private let changeDistrictButton = UIButton().then {
    $0.setTitle("지역 이동", for: .normal)
    $0.titleLabel?.font = .pretendard(size: Metric.changeDistrictFontSize, weight: .bold)
    $0.setTitleColor(R.color.black(), for: .normal)
    $0.setTitleColor(R.color.gray_20(), for: .highlighted)
    $0.backgroundColor = R.color.gray_5()
    $0.layer.cornerRadius = Metric.changeDistrictCornerRadius
    
    // Skeleton
    $0.isSkeletonable = true
    $0.skeletonCornerRadius = Float(Metric.changeDistrictCornerRadius)
  }
  
  private let loadingView = UIActivityIndicatorView()
  
  private var emptyStateView = EmptyStateView(
    title: "근처 케이크샵이 없네요..",
    subTitle: "다른 곳으로 이동 후 새로고침을 눌러보세요!"
  )
  
  private let filterButton = FilterButton(initialBadgeCount: 0).then {
    // Skeleton
    $0.isSkeletonable = true
    $0.skeletonCornerRadius = 14
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
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    showToolTip()
  }

  
  // MARK: - Private
  
  // Bind
  
  private func bind(_ viewModel: ViewModel?) {
    bindInput(viewModel)
    bindOutput(viewModel)
  }
  
  private func bindInput(_ viewModel: ViewModel?) {
    guard let viewModel else { return }
    
    changeDistrictButton
      .tapPublisher
      .throttle(for: 1, scheduler: DispatchQueue.main, latest: false)
      .sink { [weak self] _ in
        self?.showChangeDistrictView()
      }
      .store(in: &cancellableBag)
    
    collectionView
      .didSelectItemPublisher
      .sink { indexPath in
        viewModel.input.selectCakeShop.send(indexPath)
      }
      .store(in: &cancellableBag)
    
    filterButton
      .tapPublisher
      .sink { [weak self] _ in
        self?.filterButtonTapHandler?()
      }
      .store(in: &cancellableBag)
  }
  
  private func bindOutput(_ viewModel: ViewModel?) {
    guard let viewModel else { return }
    
    viewModel.output
      .cakeShops
      .sink { [weak self] cakeShops in
        self?.applySnapshot(with: cakeShops)
      }
      .store(in: &cancellableBag)

    viewModel.output
      .cakeShops
      .receive(on: DispatchQueue.main)
      .map { $0.count.description }
      .sink { [weak self] count in
        self?.numberOfCakeShopLabel.text = "\(count)개의 케이크샵"
      }
      .store(in: &cancellableBag)

    viewModel.output
      .cakeShops
      .sink { [weak self] cakeShops in
        if cakeShops.isEmpty {
          self?.emptyStateView.isHidden = false
        } else {
          self?.emptyStateView.isHidden = true
        }
      }
      .store(in: &cancellableBag)

    viewModel.output
      .loadingCakeShops
      .sink { [weak self] isLoading in
        if isLoading {
          self?.collectionView.isHidden = true
          self?.loadingView.isHidden = false
          self?.loadingView.startAnimating()
          self?.showSkeletons()
        } else {
          self?.collectionView.isHidden = false
          self?.loadingView.isHidden = true
          self?.loadingView.stopAnimating()
          self?.hideSkeletons()
        }
      }
      .store(in: &cancellableBag)
    
    viewModel.output
      .filteredCategory
      .sink { [weak self] categories in
        if CakeCategory.allCases.count - categories.count == 0 {
          self?.filterButton.setBadge(count: CakeCategory.allCases.count - categories.count)
        } else {
          self?.filterButton.setBadge(count: categories.count)
        }
      }
      .store(in: &cancellableBag)
  }
  
  private func showChangeDistrictView() {
    let viewController = DIContainer.shared.makeDistrictSelectionController()
    viewController.modalPresentationStyle = .popover
    viewController.preferredContentSize = .init(width: 335, height: 520)
    viewController.popoverPresentationController?.sourceView = changeDistrictButton
    present(viewController, animated: true)
  }
  
  private func showToolTip() {
    let locationAuthorized = {
      let locationManager = CLLocationManager()
      switch locationManager.authorizationStatus {
      case .authorizedAlways, .authorizedWhenInUse:
        return true
      default:
        return false
      }
    }()
    
    if isFirstOpen && locationAuthorized {
      var preferences = EasyTipView.Preferences()
      preferences.drawing.font = .systemFont(ofSize: 13, weight: .semibold)
      preferences.drawing.foregroundColor = .white
      preferences.drawing.backgroundColor = .black
      preferences.drawing.arrowPosition = .top
      preferences.drawing.cornerRadius = 14
      
      EasyTipView.show(
        forView: self.changeDistrictButton,
        withinSuperview: self.view,
        text: "지역별로 케이크샵을 모아봤어요!",
        preferences: preferences,
        delegate: nil)
    }
    
    isFirstOpen = false
  }
  
  private func showSkeletons() {
    headerLabel.showCustomSkeleton()
    numberOfCakeShopLabel.showCustomSkeleton()
    changeDistrictButton.showCustomSkeleton()
    filterButton.showCustomSkeleton()
    filterButton.clipsToBounds = true
  }
  
  private func hideSkeletons() {
    headerLabel.hideSkeleton()
    numberOfCakeShopLabel.hideSkeleton()
    changeDistrictButton.hideSkeleton()
    filterButton.hideSkeleton()
    filterButton.clipsToBounds = false
  }
}


// MARK: - UI & Layout

extension CakeShopListViewController {
  
  private func setup() {
    setupLayout()
    setupView()
  }
  
  // Setup Layouts
  private func setupLayout() {
    setupHeaderViewLayout()
    setupLabelStackLayout()
    setupFilterButtonLayout()
    setupChangeDistrictButtonLayout()
    setupCollectionViewLayout()
    setupLoadingViewLayout()
    setupNoDataViewLayout()
  }
  
  private func setupHeaderViewLayout() {
    view.addSubview(headerView)
    headerView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(Metric.padding)
      $0.leading.trailing.equalToSuperview()
      $0.height.equalTo(Metric.headerViewHeight)
    }
  }
  
  private func setupLabelStackLayout() {
    headerView.addSubview(labelsStack)
    labelsStack.snp.makeConstraints {
      $0.centerY.leading.equalToSuperview().inset(Metric.padding)
    }
  }
  
  private func setupFilterButtonLayout() {
    headerView.addSubview(filterButton)
    filterButton.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.trailing.equalToSuperview().inset(Metric.padding)
      $0.width.height.equalTo(36)
    }
  }
  
  private func setupChangeDistrictButtonLayout() {
    headerView.addSubview(changeDistrictButton)
    changeDistrictButton.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.trailing.equalTo(filterButton.snp.leading).inset(-8)
      $0.width.equalTo(Metric.changeDistrictWidth)
      $0.height.equalTo(Metric.changeDistrictHeight)
    }
  }
  
  private func setupCollectionViewLayout() {
    view.addSubview(collectionView)
    collectionView.snp.makeConstraints {
      $0.top.equalTo(headerView.snp.bottom)
      $0.leading.trailing.bottom.equalToSuperview()
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
    setupBaseView()
  }
  
  private func setupBaseView() {
    view.backgroundColor = .white
  }
}


// MARK: - DataSource & Snapshot

extension CakeShopListViewController {
  
  private func makeDataSource() -> DataSource {
    DataSource(
      collectionView: collectionView,
      cellProvider: { [weak self] collectionView, indexPath, item in
        guard let self else { return UICollectionViewCell() }
        
        let cell = collectionView.dequeueConfiguredReusableCell(
          using: self.cakeShopCellRegistration,
          for: indexPath,
          item: item)
        let viewModel = DIContainer.shared.makeCakeShopCollectionCellModel(cakeShop: item)
        cell.configure(viewModel: viewModel)
        return cell
      })
  }
  
  private func applySnapshot(with cakeShops: [CakeShop]) {
    collectionView.scrollToTop(animated: false)
    
    let section: [Section] = [.cakeShop]
    var snapshot = NSDiffableDataSourceSnapshot<Section, CakeShop>()
    snapshot.appendSections(section)
    snapshot.appendItems(cakeShops)
    dataSource.apply(snapshot)
  }
}

// MARK: - Preview

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct CakeListViewControllerPreview: PreviewProvider {
  static var previews: some View {
    let viewModel = MainViewModel(districts: [], service: .init(), storage: RealmStorage())
    
    CakeShopListViewController(viewModel: viewModel)
      .toPreview()
      .ignoresSafeArea()
  }
}
#endif
