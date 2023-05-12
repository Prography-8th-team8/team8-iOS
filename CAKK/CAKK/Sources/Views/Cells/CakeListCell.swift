//
//  CakeShopCollectionCell.swift
//  CAKK
//
//  Created by Mason Kim on 2023/04/03.
//

import UIKit

import SnapKit
import Then

final class CakeShopCollectionCell: UICollectionViewCell {
  
  // MARK: - Constants
  
  static let identifier = String(describing: CakeShopCollectionCell.self)
  
  enum Metric {
    static let padding = 20.f
    static let cornerRadius = 24.f
    
    static let headerStackViewSpacing = 4.f
    static let stackViewDividerWidth = 1.f
    static let stackViewDividerHeight = 12.f
    
    static let borderWidth = 1.f
    
    static let shopNameFontSize = 16.f
    static let shopNameNumberOfLines = 2
    
    static let districtFontSize = 12.f
    
    static let locationLabelFontSize = 14.f
    static let locationLabelTopPadding = 12.f
    static let locationLabelNumberOfLines = 3
    
    static let cakeShopTypeStackViewSpacing = 4.f
  }
  
  // MARK: - Properties
  
  // MARK: - UI
  
  private let cakkView = CakkView()
  
  private let headerStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = Metric.headerStackViewSpacing
    $0.alignment = .center
  }
  
  private let shopNameLabel = UILabel().then {
    $0.text = "케이크를 부탁해 연신내역점"
    $0.font = .pretendard(size: Metric.shopNameFontSize, weight: .bold)
    $0.textColor = .black
    $0.numberOfLines = Metric.shopNameNumberOfLines
  }
  
  private let stackViewDivider = UIView().then {
    $0.backgroundColor = .black.withAlphaComponent(0.4)
  }
  
  private let districtLocationLabel = UILabel().then {
    $0.text = "은평구"
    $0.font = .systemFont(ofSize: Metric.districtFontSize)
    $0.textColor = .black
  }

  private let locationLabel = UILabel().then {
    $0.text = "서울 은평구 갈현로 36길 6-4 101호 동그리케이크"
    $0.font = .systemFont(ofSize: Metric.locationLabelFontSize)
    $0.textColor = .black.withAlphaComponent(0.6)
    $0.numberOfLines = Metric.locationLabelNumberOfLines
  }
  
  private let cakeShopTypeStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = Metric.cakeShopTypeStackViewSpacing
    $0.alignment = .leading
  }
  
  private let cakeShopTypeSupplementaryChip = LabelChip().then {
    $0.title = "+3"
    $0.isBackgroundSynced = false
    $0.titleColor = .white
    $0.backgroundColor = .black
  }
  
  
  
  // MARK: - LifeCycle
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  // MARK: - Public

  
  // MARK: - Private
  
  private func setup() {
    setupLayout()
    setupView()
  }
  
  private func setupLayout() {
    setupCakkViewLayout()
    setupHeaderStackViewLayout()
    setupShopNameLabelLayout()
    setupStackViewDividerLayout()
    setupDistrictLabelLayout()
    setupLocationLabelLayout()
    setupCakeShopTypeStackViewLayout()
  }
  
  private func setupCakkViewLayout() {
    addSubview(cakkView)
    cakkView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }
  
  private func setupHeaderStackViewLayout() {
    cakkView.addSubview(headerStackView)
    headerStackView.snp.makeConstraints {
      $0.top.leading.trailing.equalToSuperview().inset(Metric.padding)
    }
  }
  
  private func setupShopNameLabelLayout() {
    headerStackView.addArrangedSubview(shopNameLabel)
  }
  
  private func setupStackViewDividerLayout() {
    headerStackView.addArrangedSubview(stackViewDivider)
    stackViewDivider.snp.makeConstraints {
      $0.width.equalTo(Metric.borderWidth)
      $0.height.equalTo(Metric.stackViewDividerHeight)
    }
  }
  
  private func setupDistrictLabelLayout() {
    headerStackView.addArrangedSubview(districtLocationLabel)
  }
  
  private func setupLocationLabelLayout() {
    cakkView.addSubview(locationLabel)
    locationLabel.snp.makeConstraints {
      $0.top.equalTo(headerStackView.snp.bottom).offset(Metric.locationLabelTopPadding)
      $0.leading.trailing.equalToSuperview().inset(Metric.padding)
    }
  }
  
  private func setupCakeShopTypeStackViewLayout() {
    cakkView.addSubview(cakeShopTypeStackView)
    cakeShopTypeStackView.snp.makeConstraints {
      $0.leading.bottom.equalToSuperview().inset(Metric.padding)
    }
  }
  
  private func setupView() {
    setupContentView()
    setupCakeShopTypeStackView()
  }
  
  private func setupContentView() {
    cakkView.backgroundColor = UIColor(hex: 0xF8F5E9)
    cakkView.borderColor = UIColor(hex: 0xE3E0D5)
    cakkView.cornerRadius = Metric.cornerRadius
  }
  
  private func setupCakeShopTypeStackView() {
    let sampleTypes: [CakeShopType] = [.character, .figure, .flower]
    sampleTypes.forEach { shopType in
      let chip = CakeShopTypeChip(shopType)
      cakeShopTypeStackView.addArrangedSubview(chip)
    }
    
    cakeShopTypeStackView.addArrangedSubview(cakeShopTypeSupplementaryChip)
  }
}


// MARK: - Preview

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct CakeListCellPreview: PreviewProvider {
  static var previews: some View {
    UIViewPreview {
      CakeShopCollectionCell()
    }
    .frame(width: 328, height: 158)
    .previewLayout(.sizeThatFits)
  }
}
#endif
