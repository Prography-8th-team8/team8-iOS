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
    static let cornerRadius = 16.f
    
    static let headerViewHeight = 100.f
    static let cakelistTableViewHeight = (140 + 16).f
    
    static let locationLabelFontSize = 16.f
    static let numberOfCakeshopsLabelFontSize = 14.f
    
    static let labelsStackViewSpacing = 8.f
    static let labelsStackViewLeadingInset = 16.f
    static let labelsStackViewTopInset = 24.f
    
    static let changeLocationButtonCornerRadius = 24.f
    static let changeLocationButtonSize = CGSize(width: 48.f, height: 48.f)
    static let changeLocationButtonTrailingInset = 16.f
    static let changeLocationButtonFontSize = 12.f
    
    static let cakeTableViewItemSpacing = 10.f
  }
  
  // MARK: - Properties
  
  static var layout: UICollectionViewCompositionalLayout {
    let itemSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .estimated(158))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    
    let group = NSCollectionLayoutGroup.vertical(
      layoutSize: itemSize,
      subitems: [item])
    group.contentInsets = .init(top: 0, leading: 16, bottom: 0, trailing: 16)
    
    let section = NSCollectionLayoutSection(group: group)
    section.interGroupSpacing = 12
    return UICollectionViewCompositionalLayout(section: section)
  }
  
  // MARK: - UI
  
  let collectionView = UICollectionView(frame: .zero, collectionViewLayout: CakeListViewController.layout).then {
    $0.register(CakeListCell.self, forCellWithReuseIdentifier: CakeListCell.identifier)
    $0.backgroundColor = .clear
  }
  
  private let headerView = UIView()
  
  private let locationsLabel = UILabel().then {
    $0.text = "은평, 마포, 서대문"
    $0.font = .systemFont(ofSize: Metric.locationLabelFontSize, weight: .bold)
  }
  
  private let numberOfCakeshopsLabel = UILabel().then {
    $0.text = "0개의 케이크샵"
    $0.font = .systemFont(ofSize: Metric.numberOfCakeshopsLabelFontSize)
  }
  
  private lazy var labelsStack = UIStackView(
    arrangedSubviews: [locationsLabel, numberOfCakeshopsLabel]
  ).then {
    $0.alignment = .leading
    $0.axis = .vertical
    $0.spacing = Metric.labelsStackViewSpacing
  }
  
  private let changeLocationButton = UIButton().then {
    let attributedTitle = NSAttributedString(
      string: "지역\n변경",
      attributes: [.font: UIFont.systemFont(ofSize: Metric.changeLocationButtonFontSize, weight: .medium)]
    )
    $0.titleLabel?.numberOfLines = 0
    $0.setAttributedTitle(attributedTitle, for: .normal)
    $0.setTitleColor(.white, for: .normal)
    $0.backgroundColor = .black
    $0.layer.cornerRadius = Metric.changeLocationButtonCornerRadius
  }
  
  private let lineView = UIView().then {
    $0.backgroundColor = .lightGray
  }

  // MARK: - LifeCycle

  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }

  
  // MARK: - Private
  
  private func setup() {
    setupLayout()
    setupViewStyle()
    setupCollectionView()
  }
  
  private func setupViewStyle() {
    view.backgroundColor = .white
    view.layer.cornerRadius = Metric.cornerRadius
  }

  private func setupCollectionView() {
    collectionView.register(CakeListCell.self, forCellWithReuseIdentifier: CakeListCell.identifier)
    collectionView.dataSource = self
    collectionView.delegate = self
  }
  
  private func setupLayout() {
    view.addSubview(headerView)
    headerView.snp.makeConstraints {
      $0.top.leading.trailing.equalToSuperview()
      $0.height.equalTo(Metric.headerViewHeight)
    }

    headerView.addSubview(labelsStack)
    labelsStack.snp.makeConstraints {
      $0.leading.equalToSuperview().inset(Metric.labelsStackViewLeadingInset)
      $0.top.equalToSuperview().inset(Metric.labelsStackViewTopInset)
    }
    
    headerView.addSubview(changeLocationButton)
    changeLocationButton.snp.makeConstraints {
      $0.size.equalTo(Metric.changeLocationButtonSize)
      $0.centerY.equalTo(labelsStack.snp.centerY)
      $0.trailing.equalToSuperview().inset(Metric.changeLocationButtonTrailingInset)
    }
    
    view.addSubview(collectionView)
    collectionView.snp.makeConstraints {
      $0.top.equalTo(headerView.snp.bottom)
      $0.leading.trailing.equalToSuperview()
      $0.bottom.equalToSuperview()
    }

    view.addSubview(lineView)
    lineView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.height.equalTo(1)
      $0.bottom.equalTo(collectionView.snp.top)
    }
  }
}

// MARK: - UITableViewDataSource

extension CakeListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 20
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CakeListCell.identifier, for: indexPath) as? CakeListCell else { return .init()}
    return cell
  }
}


// MARK: - UITableViewDelegate

extension CakeListViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return Metric.cakelistTableViewHeight
  }
}


// MARK: - Preview

import SwiftUI

struct CakeListViewControllerPreview: PreviewProvider {
  static var previews: some View {
    CakeListViewController().toPreview()
      .ignoresSafeArea()
  }
}
