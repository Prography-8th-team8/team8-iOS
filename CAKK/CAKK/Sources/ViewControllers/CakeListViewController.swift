//
//  CakeListViewController.swift
//  CAKK
//
//  Created by Mason Kim on 2023/04/03.
//

import UIKit
import SnapKit
import Then

final class CakeListViewController: UIViewController {
  
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
  
  // MARK: - Properties
  
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
  public var cakeShopItemSelectAction: () -> Void = { }
  
  // MARK: - UI
  
  let collectionView = UICollectionView(frame: .zero, collectionViewLayout: CakeListViewController.layout).then {
    $0.register(CakeShopCollectionCell.self, forCellWithReuseIdentifier: CakeShopCollectionCell.identifier)
    $0.backgroundColor = .clear
    $0.layer.cornerRadius = Metric.collectionViewCornerRadius
  }
  
  private let headerView = UIView()
  
  private let locationsLabel = UILabel().then {
    $0.text = "은평, 마포, 서대문"
    $0.font = .pretendard(size: Metric.locationLabelFontSize, weight: .bold)
    $0.textColor = .black
  }
  
  private let numberOfCakeshopsLabel = UILabel().then {
    $0.text = "0개의 케이크샵"
    $0.font = .systemFont(ofSize: Metric.numberOfCakeShopFontSize)
    $0.textColor = .black.withAlphaComponent(0.8)
  }
  
  private lazy var labelsStack = UIStackView(
    arrangedSubviews: [locationsLabel, numberOfCakeshopsLabel]
  ).then {
    $0.alignment = .leading
    $0.axis = .vertical
    $0.spacing = Metric.labelsStackViewSpacing
  }
  

  // MARK: - LifeCycle

  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }

  
  // MARK: - Private
  
  private func setup() {
    setupLayout()
    setupView()
  }

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
  
  private func setupView() {
    setupCollectionView()
  }
  
  private func setupBaseView() {
    view.backgroundColor = .white
  }
  
  private func setupCollectionView() {
    collectionView.register(CakeShopCollectionCell.self, forCellWithReuseIdentifier: CakeShopCollectionCell.identifier)
    collectionView.dataSource = self
    collectionView.delegate = self
  }
}

// MARK: - UICollectionView

extension CakeListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 20
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CakeShopCollectionCell.identifier, for: indexPath) as? CakeShopCollectionCell else { return .init()}
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    cakeShopItemSelectAction()
  }
}


// MARK: - Preview

import SwiftUI

struct CakeListViewControllerPreview: PreviewProvider {
  static var previews: some View {
    CakeListViewController().toPreview()
  }
}
