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

final class CakeShopCollectionCell: HighlightableCell {
  
  // MARK: - Constants
  
  static let identifier = String(describing: CakeShopCollectionCell.self)
  
  enum Metric {
    static let padding = 20.f
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
    
    static let cakeShopTypeStackViewSpacing = 4.f
    
    static let shareButtonSize = 28.f
    static let shareButtonImagePadding = 7.f
  }
  
  // MARK: - Properties
  
  private var cancellableBag = Set<AnyCancellable>()
  public var shareButtonTapHandler: (() -> Void)?
  
  
  // MARK: - UI
  
  private let cakkView = CakkView()
  
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
  
  private let cakeShopTypeStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = Metric.cakeShopTypeStackViewSpacing
    $0.alignment = .leading
  }
  
  public let shareButton = UIButton().then {
    $0.tintColor = R.color.white()
    $0.backgroundColor = R.color.black()
    $0.setImage(R.image.share_thick(), for: .normal)
    $0.imageEdgeInsets = .init(common: Metric.shareButtonImagePadding)
    $0.layer.cornerRadius = Metric.shareButtonSize / 2
  }
  
  
  // MARK: - LifeCycle
  
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
    
    configureCakeShopTypeStackView(item.cakeShopTypes)
  }

  
  // MARK: - Private
  
  private func setup() {
    setupLayout()
    setupView()
  }
  
  // Setup Layout
  private func setupLayout() {
    setupCakkViewLayout()
    setupShareButtonLayout()
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
  
  private func setupShareButtonLayout() {
    cakkView.addSubview(shareButton)
    shareButton.snp.makeConstraints {
      $0.top.trailing.equalToSuperview().inset(Metric.padding)
      $0.width.height.equalTo(Metric.shareButtonSize)
    }
  }
  
  private func setupHeaderStackViewLayout() {
    cakkView.addSubview(headerStackView)
    headerStackView.snp.makeConstraints {
      $0.top.leading.equalToSuperview().inset(Metric.padding)
      $0.trailing.equalTo(shareButton.snp.leading).inset(Metric.headerStackViewRightPadding)
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
  
  // Setup View
  private func setupView() {
    setupContentView()
  }
  
  private func setupContentView() {
    cakkView.backgroundColor = UIColor(hex: 0xF8F5E9)
    cakkView.borderColor = UIColor(hex: 0xE3E0D5)
    cakkView.cornerRadius = Metric.cornerRadius
  }
  
  private func configureCakeShopTypeStackView(_ types: [CakeShopType]) {
    cakeShopTypeStackView.subviews.forEach { $0.removeFromSuperview() }
    
    if types.isEmpty {
      let chip = LabelChip()
      chip.title = "등록된 카테고리가 없어요 😓"
      chip.isBackgroundSynced = false
      chip.titleColor = R.color.brown_100()
      chip.backgroundColor = R.color.brown_10()
      cakeShopTypeStackView.addArrangedSubview(chip)
      return
    }
    
    for (index, type) in types.enumerated() {
      if index < 3 {
        let chip = CakeShopTypeChip(type)
        cakeShopTypeStackView.addArrangedSubview(chip)
      } else {
        // at the end of the loop
        if index == types.count - 1 {
          let count = "+\((index + 2) - 3)"
          
          let supplementaryChip = LabelChip()
          supplementaryChip.title = count
          supplementaryChip.isBackgroundSynced = false
          supplementaryChip.titleColor = .white
          supplementaryChip.backgroundColor = .black
          
          cakeShopTypeStackView.addArrangedSubview(supplementaryChip)
        }
      }
    }
  }
  
  private func bind() {
    bindInput()
    bindOutput()
  }
  
  private func bindInput() {
    shareButton.tapPublisher
      .throttle(for: 1, scheduler: DispatchQueue.main, latest: false)
      .sink { [weak self] in
        self?.shareButtonTapHandler?()
      }
      .store(in: &cancellableBag)
  }
  
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
