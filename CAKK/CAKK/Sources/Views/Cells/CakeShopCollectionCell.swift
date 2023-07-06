//
//  CakeShopCollectionCell.swift
//  CAKK
//
//  Created by Mason Kim on 2023/04/03.
//

import UIKit

import Combine

import SnapKit
import Then

import Kingfisher

final class CakeShopCollectionCell: HighlightableCell {
  
  // MARK: - Constants
  
  static let identifier = String(describing: CakeShopCollectionCell.self)
  
  enum Metric {
    static let padding = 16.f
    static let cornerRadius = 24.f
    
    static let headerStackViewSpacing = 4.f
    static let headerStackViewRightPadding = 8.f
    static let stackViewDividerWidth = 1.f
    static let stackViewDividerHeight = 12.f
    
    static let borderWidth = 1.f
    
    static let shopNameFontSize = 16.f
    static let shopNameNumberOfLines = 2
    
    static let districtFontSize = 12.f
    
    static let locationLabelFontSize = 14.f
    static let locationLabelTopPadding = 12.f
    static let locationLabelNumberOfLines = 3
    
    static let cakeCategoryStackViewSpacing = 4.f
    
    static let thumbnailImageSize = 72.f
    static let thumbnailImageCornerRadius = 22.f
  }
  
  // MARK: - Properties
  
  private var cancellableBag = Set<AnyCancellable>()
  
  
  // MARK: - UI
  
  private let cakkView = CakkView()
  
  private let thumbnailImageView = UIImageView().then {
    $0.image = R.image.thumbnail_placeholder()
    $0.contentMode = .scaleAspectFill
    $0.clipsToBounds = true
    $0.layer.cornerRadius = Metric.thumbnailImageCornerRadius
  }
  
  private let headerStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = Metric.headerStackViewSpacing
    $0.alignment = .center
  }
  
  private let shopNameLabel = UILabel().then {
    $0.font = .pretendard(size: Metric.shopNameFontSize, weight: .bold)
    $0.textColor = .black
    $0.numberOfLines = Metric.shopNameNumberOfLines
  }
  
  private let stackViewDivider = UIView().then {
    $0.backgroundColor = .black.withAlphaComponent(0.4)
  }
  
  private let districtLocationLabel = UILabel().then {
    $0.font = .systemFont(ofSize: Metric.districtFontSize)
    $0.textColor = .black
  }

  private let locationLabel = UILabel().then {
    $0.font = .systemFont(ofSize: Metric.locationLabelFontSize)
    $0.textColor = .black.withAlphaComponent(0.6)
    $0.numberOfLines = Metric.locationLabelNumberOfLines
  }
  
  private let cakeCategoryStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = Metric.cakeCategoryStackViewSpacing
    $0.alignment = .leading
  }
  
  
  // MARK: - Initialization
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
    bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  // MARK: - Public
  
  public func configure(_ item: CakeShop) {
    shopNameLabel.text = item.name
    districtLocationLabel.text = item.district.koreanName
    locationLabel.text = item.location
    
    if let thumbnail = item.thumbnail {
      let url = URL(string: thumbnail)
      thumbnailImageView.kf.setImage(with: url)
    }
    
    configureCakeCategoryStackView(item.cakeCategories)
  }

  
  // MARK: - Private
  
  private func setup() {
    setupLayout()
    setupView()
  }
  
  // Setup Layout
  private func setupLayout() {
    setupCakkViewLayout()
    setupThumbnailImageViewLayout()
    setupHeaderStackViewLayout()
    setupShopNameLabelLayout()
    setupStackViewDividerLayout()
    setupDistrictLabelLayout()
    setupLocationLabelLayout()
    setupCakeCategoriesStackViewLayout()
  }
  
  private func setupCakkViewLayout() {
    addSubview(cakkView)
    cakkView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }
  
  private func setupThumbnailImageViewLayout() {
    addSubview(thumbnailImageView)
    thumbnailImageView.snp.makeConstraints {
      $0.top.leading.equalToSuperview().inset(Metric.padding)
      $0.size.equalTo(Metric.thumbnailImageSize)
    }
  }
  
  private func setupHeaderStackViewLayout() {
    cakkView.addSubview(headerStackView)
    headerStackView.snp.makeConstraints {
      $0.top.equalToSuperview().inset(Metric.padding + 6)
      $0.leading.equalTo(thumbnailImageView.snp.trailing).offset(Metric.padding)
      $0.trailing.equalToSuperview().inset(Metric.padding)
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
      $0.leading.equalTo(headerStackView)
      $0.trailing.equalToSuperview().inset(Metric.padding)
    }
  }
  
  private func setupCakeCategoriesStackViewLayout() {
    cakkView.addSubview(cakeCategoryStackView)
    cakeCategoryStackView.snp.makeConstraints {
      $0.leading.bottom.equalToSuperview().inset(Metric.padding)
    }
  }
  
  // Setup View
  private func setupView() {
    setupContentView()
  }
  
  private func setupContentView() {
    cakkView.backgroundColor = UIColor(hex: 0xF8F5E9)
    cakkView.borderColor = UIColor(hex: 0xE3E0D5)
    cakkView.cornerRadius = Metric.cornerRadius
  }
  
  private func configureCakeCategoryStackView(_ types: [CakeCategory]) {
    cakeCategoryStackView.subviews.forEach { $0.removeFromSuperview() }
    
    if types.isEmpty {
      let chip = LabelChip()
      chip.title = "등록된 카테고리가 없어요 😓"
      chip.isBackgroundSynced = false
      chip.titleColor = R.color.brown_100()
      chip.backgroundColor = R.color.brown_10()
      cakeCategoryStackView.addArrangedSubview(chip)
      return
    }
    
    for (index, type) in types.enumerated() {
      if index < 3 {
        let chip = CakeCategoryChipView(type)
        cakeCategoryStackView.addArrangedSubview(chip)
      } else {
        // at the end of the loop
        if index == types.count - 1 {
          let count = "+\((index + 2) - 3)"
          
          let supplementaryChip = LabelChip()
          supplementaryChip.title = count
          supplementaryChip.isBackgroundSynced = false
          supplementaryChip.titleColor = .white
          supplementaryChip.backgroundColor = .black
          
          cakeCategoryStackView.addArrangedSubview(supplementaryChip)
        }
      }
    }
  }
  
  private func bind() {
    bindInput()
    bindOutput()
  }
  
  private func bindInput() { }
  
  private func bindOutput() { }
}


// MARK: - Preview

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct CakeListCellPreview: PreviewProvider {
  static var previews: some View {
    UIViewPreview {
      let cell = CakeShopCollectionCell()
      cell.configure(SampleData.cakeShopList.first!)
      return cell
    }
    .frame(width: 328, height: 158)
    .previewLayout(.sizeThatFits)
  }
}
#endif
