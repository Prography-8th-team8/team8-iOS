//
//  CakeShopPopUpView.swift
//  CAKK
//
//  Created by 이승기 on 2023/06/01.
//

import UIKit

import Combine

class CakeShopPopUpView: UIControl {
  
  // MARK: - Constants
  
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
    
    static let cakeCategoryStackViewSpacing = 4.f
    
    static let shareButtonSize = 28.f
    static let shareButtonImagePadding = 5.f
  }
  
  
  // MARK: - Properties
  
  private let cakeShop: CakeShop
  private var cancellableBag = Set<AnyCancellable>()
  public var shareButtonTapHandler: (() -> Void)?
  
  
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
  
  public let shareButton = UIButton().then {
    $0.tintColor = R.color.white()
    $0.backgroundColor = R.color.black()
    $0.setImage(R.image.arrow_right_square(), for: .normal)
    $0.imageEdgeInsets = .init(common: Metric.shareButtonImagePadding)
    $0.layer.cornerRadius = Metric.shareButtonSize / 2
  }
  
  
  // MARK: - Initialization
  
  init(cakeShop: CakeShop) {
    self.cakeShop = cakeShop
    super.init(frame: .zero)
    
    setup()
    bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Private
  
  private func setup() {
    setupLayout()
    setupView()
  }
  
  private func setupLayout() {
    setupShareButtonLayout()
    setupHeaderStackViewLayout()
    setupShopNameLabelLayout()
    setupStackViewDividerLayout()
    setupDistrictLabelLayout()
    setupLocationLabelLayout()
    setupCakeCategoryStackViewLayout()
  }
  
  private func setupShareButtonLayout() {
    addSubview(shareButton)
    shareButton.snp.makeConstraints {
      $0.top.trailing.equalToSuperview().inset(Metric.padding)
      $0.width.height.equalTo(Metric.shareButtonSize)
    }
  }
  
  private func setupHeaderStackViewLayout() {
    addSubview(headerStackView)
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
    addSubview(locationLabel)
    locationLabel.snp.makeConstraints {
      $0.top.equalTo(headerStackView.snp.bottom).offset(Metric.locationLabelTopPadding)
      $0.leading.trailing.equalToSuperview().inset(Metric.padding)
    }
  }
  
  private func setupCakeCategoryStackViewLayout() {
    addSubview(cakeCategoryStackView)
    cakeCategoryStackView.snp.makeConstraints {
      $0.leading.bottom.equalToSuperview().inset(Metric.padding)
    }
  }
  
  private func setupView() {
    setupBaseView()
    setupShopNameLabel()
    setupDistrictLabel()
    setupLocationLabel()
    setupCakeCategoryStackView()
  }
  
  private func setupBaseView() {
    backgroundColor = R.color.white()
    layer.cornerRadius = Metric.cornerRadius
    layer.borderWidth = 1
    layer.borderColor = R.color.gray_20()?.cgColor
  }
  
  private func setupShopNameLabel() {
    shopNameLabel.text = cakeShop.name
  }
  
  private func setupDistrictLabel() {
    districtLocationLabel.text = cakeShop.district.koreanName
  }
  
  private func setupLocationLabel() {
    locationLabel.text = cakeShop.location
  }
  
  private func setupCakeCategoryStackView() {
    cakeCategoryStackView.subviews.forEach { $0.removeFromSuperview() }
    let types = cakeShop.cakeCategories
    
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
    shareButton.tapPublisher
      .throttle(for: 1, scheduler: DispatchQueue.main, latest: false)
      .sink { [weak self] in
        self?.shareButtonTapHandler?()
      }
      .store(in: &cancellableBag)
  }
}


#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct CakeShopPopUpView_Preview: PreviewProvider {
  static var previews: some View {
    UIViewPreview {
      CakeShopPopUpView(cakeShop: .init(
        id: 0,
        createdAt: "",
        modifiedAt: "",
        name: "이름이름이름",
        shareLink: "",
        city: "도봉구",
        district: .dobong,
        location: "주소주소주소",
        latitude: 0,
        longitude: 0,
        thumbnail: "",
        imageUrls: [],
        cakeCategories: [.character, .figure, .flower]))
    }
    .frame(height: 158)
    .previewLayout(.sizeThatFits)
  }
}
#endif
