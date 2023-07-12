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

final class CakeShopCollectionCell: UICollectionViewCell {
  
  // MARK: - Constants
  
  static let identifier = String(describing: CakeShopCollectionCell.self)
  
  enum Metric {
    static let padding = 20.f
    
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
    static let cakeShopCategoryStackViewTopMargin = 12.f
    
    static let cakeImageSize = 96.f
    static let cakeImageCornerRadius = 20.f
    static let cakeImageSpacing = 8.f
    
    static let dividerHeight = 1.f
  }
  
  // MARK: - Types
  
  typealias DataSource = UICollectionViewDiffableDataSource<Section, String>
  
  enum Section {
    case cakeImages
  }
  
  
  // MARK: - Properties
  
  private var cancellableBag = Set<AnyCancellable>()
  
  
  // MARK: - UI

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
  
  private let cakeImageScrollView = UIScrollView().then {
    $0.showsHorizontalScrollIndicator = false
    $0.layer.cornerRadius = Metric.cakeImageCornerRadius
  }
  
  private let cakeImageStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = Metric.cakeImageSpacing
  }
  
  private let divider = UIView().then {
    $0.backgroundColor = R.color.gray_10()
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
    
    configureCakeCategoryStackView(item.cakeCategories)
    configureCakeImages(imageUrls: item.imageUrls)
    
  }
  
  
  // MARK: - Private
  
  private func bind() {
    bindInput()
    bindOutput()
  }
  
  private func bindInput() { }
  
  private func bindOutput() { }

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
  
  private func configureCakeImages(imageUrls: [String]) {
    cakeImageStackView.subviews.forEach { subView in
      subView.removeFromSuperview()
    }
    
    imageUrls.map { imageUrl in
      let imageView = UIImageView()
      imageView.contentMode = .scaleAspectFill
      imageView.layer.cornerRadius = Metric.cakeImageCornerRadius
      imageView.clipsToBounds = true

      let url = URL(string: imageUrl)
      imageView.kf.setImage(with: url, placeholder: R.image.thumbnail_placeholder())
      
      imageView.snp.makeConstraints {
        $0.size.equalTo(Metric.cakeImageSize)
      }
      
      return imageView
    }
    .forEach { imageView in
      cakeImageStackView.addArrangedSubview(imageView)
    }
  }
}


// MARK: - UI & Layouts

extension CakeShopCollectionCell {

  private func setup() {
    setupLayout()
    setupView()
  }
  
  // Setup Layout
  private func setupLayout() {
    setupHeaderStackViewLayout()
    setupShopNameLabelLayout()
    setupStackViewDividerLayout()
    setupDistrictLabelLayout()
    setupLocationLabelLayout()
    setupCakeCategoriesStackViewLayout()
    setupCakeImageScrollView()
    setupCakeImageStackView()
    setupDividerLayout()
  }
  
  private func setupHeaderStackViewLayout() {
    addSubview(headerStackView)
    headerStackView.snp.makeConstraints {
      $0.top.equalToSuperview().inset(Metric.padding + 6)
      $0.leading.trailing.equalToSuperview().inset(Metric.padding)
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
    addSubview(locationLabel)
    locationLabel.snp.makeConstraints {
      $0.top.equalTo(headerStackView.snp.bottom).offset(Metric.locationLabelTopPadding)
      $0.leading.equalTo(headerStackView)
      $0.trailing.equalToSuperview().inset(Metric.padding)
    }
  }
  
  private func setupCakeCategoriesStackViewLayout() {
    addSubview(cakeCategoryStackView)
    cakeCategoryStackView.snp.makeConstraints {
      $0.top.equalTo(locationLabel.snp.bottom).offset(Metric.cakeShopCategoryStackViewTopMargin)
      $0.leading.equalToSuperview().inset(Metric.padding)
    }
  }
  
  private func setupCakeImageScrollView() {
    addSubview(cakeImageScrollView)
    cakeImageScrollView.snp.makeConstraints {
      $0.top.equalTo(cakeCategoryStackView.snp.bottom).offset(32)
      $0.leading.trailing.bottom.equalToSuperview().inset(Metric.padding)
      $0.height.equalTo(Metric.cakeImageSize)
    }
  }
  
  private func setupCakeImageStackView() {
    cakeImageScrollView.addSubview(cakeImageStackView)
    cakeImageStackView.snp.makeConstraints {
      $0.edges.height.equalToSuperview()
    }
  }
  
  private func setupDividerLayout() {
    addSubview(divider)
    divider.snp.makeConstraints {
      $0.top.leading.trailing.equalToSuperview()
      $0.height.equalTo(Metric.dividerHeight)
    }
  }
  
  // Setup View
  private func setupView() {
    setupContentView()
  }
  
  private func setupContentView() {
    backgroundColor = UIColor(hex: 0xF8F5E9)
  }
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
