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
    
    static let locationLabelFontSize = 18.f
    static let numberOfCakeShopFontSize = 14.f
    
    static let labelsStackViewSpacing = 12.f
    
    static let cakeTableViewItemSpacing = 10.f
  }
  
  // MARK: - Types
  
  typealias ViewModel = CakeShopListViewModel
  typealias DataSource = UICollectionViewDiffableDataSource<Section, CakeShop>
  
  
  // MARK: - Properties
  
  private var viewModel: ViewModel
  private var cancellableBag = Set<AnyCancellable>()
  
  static var layout: UICollectionViewCompositionalLayout {
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
  }
  
  enum Section {
    case cakeShop
  }
  
  public var cakeShopItemSelectAction: () -> Void = { }
  private var dataSource: DataSource!
  private var cakeShopCellRegistration = UICollectionView.CellRegistration<CakeShopCollectionCell, CakeShop> { _, _, _ in }
  
  
  // MARK: - UI
  
  let collectionView = UICollectionView(frame: .zero, collectionViewLayout: CakeShopListViewController.layout).then {
    $0.register(CakeShopCollectionCell.self, forCellWithReuseIdentifier: CakeShopCollectionCell.identifier)
    $0.backgroundColor = .clear
    $0.layer.cornerRadius = Metric.collectionViewCornerRadius
    $0.delaysContentTouches = false
  }
  
  private let headerView = UIView()
  
  private let locationsLabel = UILabel().then {
    $0.text = "은평, 마포, 서대문"
    $0.font = .pretendard(size: Metric.locationLabelFontSize, weight: .bold)
    $0.textColor = .black
  }
  
  private let numberOfCakeShopLabel = UILabel().then {
    $0.text = "0개의 케이크샵"
    $0.font = .systemFont(ofSize: Metric.numberOfCakeShopFontSize)
    $0.textColor = .black.withAlphaComponent(0.8)
  }
  
  private lazy var labelsStack = UIStackView(
    arrangedSubviews: [locationsLabel, numberOfCakeShopLabel]
  ).then {
    $0.alignment = .leading
    $0.axis = .vertical
    $0.spacing = Metric.labelsStackViewSpacing
  }
  

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
    setupCollectionViewLayout()
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
      $0.top.leading.trailing.equalToSuperview().inset(Metric.padding)
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
  
  // Setup Views
  private func setupView() {
    setupCollectionView()
  }
  
  private func setupBaseView() {
    view.backgroundColor = .white
  }
  
  private func setupCollectionView() {
    collectionView.register(CakeShopCollectionCell.self, forCellWithReuseIdentifier: CakeShopCollectionCell.identifier)
    collectionView.delegate = self
    
    dataSource = DataSource(
      collectionView: collectionView,
      cellProvider: { collectionView, indexPath, item in
        let cell = collectionView.dequeueConfiguredReusableCell(
          using: self.cakeShopCellRegistration,
          for: indexPath,
          item: item)
        cell.configure(item)
        return cell
      })
  }
  
  // Bind
  
  private func bind() {
    bindInput()
    bindOutput()
  }
  
  private func bindInput() { }
  
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
      .presentCakeShopDetail
      .sink { [weak self] cakeShop in
        // 여기서 뷰모델 넘겨주면 댐
        self?.cakeShopItemSelectAction()
      }
      .store(in: &cancellableBag)
  }
}

// MARK: - UICollectionView

extension CakeShopListViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    UIImpactFeedbackGenerator(style: .light).impactOccurred()
    viewModel.input
      .selectCakeShop
      .send(indexPath)
  }
}


// MARK: - Preview

import SwiftUI

struct CakeListViewControllerPreview: PreviewProvider {
  static var previews: some View {
    let viewModel = CakeShopListViewModel(
      districtSection: .items().first!,
      service: .init(type: .stub)
    )
    
    CakeShopListViewController(viewModel: viewModel)
      .toPreview()
      .ignoresSafeArea()
  }
}
