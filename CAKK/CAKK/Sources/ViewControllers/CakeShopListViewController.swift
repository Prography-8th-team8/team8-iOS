//
//  CakeShopListViewController.swift
//  CAKK
//
//  Created by Mason Kim on 2023/04/03.
//

import UIKit

import SnapKit
import Then

import Combine

final class CakeShopListViewController: UIViewController {
  
  // MARK: - Constants
  
  enum Metric {
    static let padding = 20.f
    static let cornerRadius = 16.f
    
    static let headerViewHeight = 100.f
    
    static let collectionViewCornerRadius = 24.f
    static let collectionViewItemEstimatedHeight = 158.f
    static let collectionViewItemSpacing = 12.f
    static let collectionViewHorizontalPadding = 16.f
    static let collectionViewBottomInset = 44.f
    
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
  
  typealias ViewModel = CakeShopListViewModel
  typealias DataSource = UICollectionViewDiffableDataSource<Section, CakeShop>
  
  enum Section {
    case cakeShop
  }
  
  // MARK: - Properties
  
  let viewModel: ViewModel
  private var cancellableBag = Set<AnyCancellable>()
  
  public var cakeShopItemSelectHandler: ((CakeShop) -> Void)?
  private var dataSource: DataSource!
  private var cakeShopCellRegistration = UICollectionView.CellRegistration<CakeShopCollectionCell, CakeShop> { _, _, _ in }
  
  
  // MARK: - UI
  
  lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout).then {
    $0.register(CakeShopCollectionCell.self, forCellWithReuseIdentifier: CakeShopCollectionCell.identifier)
    $0.backgroundColor = .clear
    $0.layer.cornerRadius = Metric.collectionViewCornerRadius
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
    section.interGroupSpacing = Metric.collectionViewItemSpacing
    return UICollectionViewCompositionalLayout(section: section)
  }()
  
  private let headerView = UIView()
  
  private let headerLabel = UILabel().then {
    $0.text = "이 근처 케이크샵"
    $0.font = .pretendard(size: Metric.locationLabelFontSize, weight: .bold)
    $0.textColor = .black
  }
  
  private let numberOfCakeShopLabel = UILabel().then {
    $0.font = .systemFont(ofSize: Metric.numberOfCakeShopFontSize)
    $0.textColor = .black.withAlphaComponent(0.8)
  }
  
  private lazy var labelsStack = UIStackView(
    arrangedSubviews: [headerLabel, numberOfCakeShopLabel]
  ).then {
    $0.alignment = .leading
    $0.axis = .vertical
    $0.spacing = Metric.labelsStackViewSpacing
  }
  
  private let changeDistrictButton = UIButton().then {
    $0.setTitle("지역 변경", for: .normal)
    $0.titleLabel?.font = .pretendard(size: Metric.changeDistrictFontSize, weight: .bold)
    $0.setTitleColor(R.color.pink_TBD(), for: .normal)
    $0.backgroundColor = R.color.pink_15()
    $0.layer.cornerRadius = Metric.changeDistrictCornerRadius
  }
  
  private let loadingView = UIActivityIndicatorView()
  
  private var noDataView = NoDataView(
    title: "표시할 데이터가 없어요!",
    subTitle: "빠른 시일내에 준비하겠습니다."
  )
  

  // MARK: - LifeCycle
  
  init(viewModel: ViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }

  
  // MARK: - Private
  
  private func setup() {
    setupLayout()
    setupView()
    bind()
  }

  // Setup Layouts
  private func setupLayout() {
    setupHeaderViewLayout()
    setupLabelStackLayout()
    setupChangeDistrictButtonLayout()
    setupCollectionViewLayout()
    setupLoadingViewLayout()
    setupNoDataViewLayout()
  }
  
  private func setupHeaderViewLayout() {
    view.addSubview(headerView)
    headerView.snp.makeConstraints {
      $0.top.leading.trailing.equalToSuperview()
      $0.height.equalTo(Metric.headerViewHeight)
    }
  }
  
  private func setupLabelStackLayout() {
    headerView.addSubview(labelsStack)
    labelsStack.snp.makeConstraints {
      $0.top.leading.equalToSuperview().inset(Metric.padding)
    }
  }
  
  private func setupChangeDistrictButtonLayout() {
    headerView.addSubview(changeDistrictButton)
    changeDistrictButton.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.trailing.equalToSuperview().inset(Metric.padding)
      $0.width.equalTo(Metric.changeDistrictWidth)
      $0.height.equalTo(Metric.changeDistrictHeight)
    }
  }
  
  private func setupCollectionViewLayout() {
    view.addSubview(collectionView)
    collectionView.snp.makeConstraints {
      $0.top.equalTo(headerView.snp.bottom)
      $0.leading.trailing.equalToSuperview().inset(Metric.collectionViewHorizontalPadding)
      $0.bottom.equalToSuperview()
    }
  }
  
  private func setupLoadingViewLayout() {
    view.addSubview(loadingView)
    loadingView.snp.makeConstraints {
      $0.center.equalToSuperview()
    }
  }
  
  private func setupNoDataViewLayout() {
    view.addSubview(noDataView)
    noDataView.snp.makeConstraints {
      $0.center.equalToSuperview()
    }
  }
  
  // Setup Views
  private func setupView() {
    setupCollectionView()
  }
  
  private func setupBaseView() {
    view.backgroundColor = .white
  }
  
  private func setupCollectionView() {
    collectionView.register(CakeShopCollectionCell.self, forCellWithReuseIdentifier: CakeShopCollectionCell.identifier)
    
    dataSource = DataSource(
      collectionView: collectionView,
      cellProvider: { collectionView, indexPath, item in
        let cell = collectionView.dequeueConfiguredReusableCell(
          using: self.cakeShopCellRegistration,
          for: indexPath,
          item: item)
        cell.configure(item)
        cell.shareButtonTapHandler = { [weak self] in
          let items = [item.name, item.location, item.url]
          
          let activity = UIActivityViewController(activityItems: items, applicationActivities: nil)
          activity.modalPresentationStyle = .popover
          activity.popoverPresentationController?.sourceView = cell.shareButton
          self?.present(activity, animated: true)
        }
        return cell
      })
  }
  
  // Bind
  
  private func bind() {
    bindInput()
    bindOutput()
  }
  
  private func bindInput() {
    changeDistrictButton
      .tapPublisher
      .throttle(for: 1, scheduler: DispatchQueue.main, latest: false)
      .sink { [weak self] _ in
        self?.showChangeDistrictView()
      }
      .store(in: &cancellableBag)
    
    collectionView.didSelectItemPublisher
      .sink { [weak self] indexPath in
        self?.viewModel.input.selectCakeShop.send(indexPath)
        self?.collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
      }
      .store(in: &cancellableBag)
  }
  
  private func bindOutput() {
    viewModel.output
      .cakeShops
      .sink { [weak self] cakeShops in
        let section: [Section] = [.cakeShop]
        var snapshot = NSDiffableDataSourceSnapshot<Section, CakeShop>()
        snapshot.appendSections(section)
        snapshot.appendItems(cakeShops)
        self?.dataSource.apply(snapshot)
      }
      .store(in: &cancellableBag)
    
    viewModel.output
      .cakeShops
      .map { $0.count.description }
      .sink { [weak self] count in
        self?.numberOfCakeShopLabel.text = "\(count)개의 케이크샵"
      }
      .store(in: &cancellableBag)
    
    viewModel.output
      .hasNoData
      .sink { [weak self] hasNoData in
        if hasNoData {
          self?.noDataView.isHidden = false
        } else {
          self?.noDataView.isHidden = true
        }
      }
      .store(in: &cancellableBag)
    
    viewModel.output
      .presentCakeShopDetail
      .sink { [weak self] cakeShop in
        self?.cakeShopItemSelectHandler?(cakeShop)
      }
      .store(in: &cancellableBag)
    
    viewModel.output
      .isLoading
      .sink { [weak self] isLoading in
        if isLoading {
          self?.collectionView.isHidden = true
          self?.loadingView.isHidden = false
          self?.loadingView.startAnimating()
        } else {
          self?.collectionView.isHidden = false
          self?.loadingView.isHidden = true
          self?.loadingView.stopAnimating()
        }
      }
      .store(in: &cancellableBag)
  }
  
  private func showChangeDistrictView() {
    let viewController = DIContainer.shared.makeDistrictSelectionController()
    viewController.modalPresentationStyle = .popover
    viewController.preferredContentSize = .init(width: 335, height: 520)
    viewController.popoverPresentationController?.sourceView = changeDistrictButton
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      self.present(viewController, animated: true)
    }
  }
}

// MARK: - Preview

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct CakeListViewControllerPreview: PreviewProvider {
  static var previews: some View {
    let viewModel = CakeShopListViewModel(
      initialCakeShops: [],
      service: .init(type: .stub)
    )
    
    CakeShopListViewController(viewModel: viewModel)
      .toPreview()
      .ignoresSafeArea()
  }
}
#endif
