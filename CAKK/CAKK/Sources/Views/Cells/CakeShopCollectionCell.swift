//
//  CakeShopCollectionCell.swift
//  CAKK
//
//  Created by Mason Kim on 2023/04/03.
//

import UIKit

import Combine
import CombineCocoa

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
    
    static let bookmarkButtonSize = 24.f
    
    static let dividerHeight = 1.f
  }
  
  // MARK: - Types
  
  typealias DataSource = UICollectionViewDiffableDataSource<Section, String>
  
  enum Section {
    case cakeImages
  }
  
  
  // MARK: - Properties
  
  private var viewModel: CakeShopCollectionCellModel?
  private var cancellableBag = Set<AnyCancellable>()
  
  override var isHighlighted: Bool {
    didSet {
      if isHighlighted {
        highlight()
      } else {
        unhighlight()
      }
    }
  }
  
  
  // MARK: - UI
  
  private let bookmarkButton = HeartButton(isBookmarked: false)

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
    $0.alwaysBounceHorizontal = true
    $0.contentInset = .init(vertical: 0, horizontal: Metric.padding)
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
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    cancellableBag = .init()
  }
  
  
  // MARK: - Public
  
  public func configure(viewModel: CakeShopCollectionCellModel) {
    self.viewModel = viewModel
    bind()
    viewModel.input.configure.send(Void())
  }
  
  
  // MARK: - Binds
  
  private func bind() {
    bindInput()
    bindOutput()
  }
  
  private func bindInput() {
    guard let viewModel else { return }
    
    bookmarkButton
      .tapPublisher
      .sink { _ in
        viewModel.input.tapBookmarkButton.send(Void())
      }
      .store(in: &cancellableBag)
  }
  
  private func bindOutput() {
    guard let viewModel else { return }
    
    viewModel.output
      .shopName
      .sink { [weak self] shopName in
        self?.shopNameLabel.text = shopName
      }
      .store(in: &cancellableBag)
    
    viewModel.output
      .district
      .sink { [weak self] district in
        self?.districtLocationLabel.text = district.koreanName
      }
      .store(in: &cancellableBag)
    
    viewModel.output
      .location
      .sink { [weak self] location in
        self?.locationLabel.text = location
      }
      .store(in: &cancellableBag)
    
    viewModel.output
      .categories
      .sink { [weak self] categories in
        self?.configureCakeCategoryStackView(categories)
      }
      .store(in: &cancellableBag)
    
    viewModel.output
      .imageUrls
      .sink { [weak self] imageUrls in
        self?.configureCakeImages(imageUrls: imageUrls)
      }
      .store(in: &cancellableBag)
    
    viewModel.output
      .isBookmarked
      .sink { [weak self] isBookmarked in
        self?.bookmarkButton.setBookmark(isBookmarked)
      }
      .store(in: &cancellableBag)
  }
  
  
  // MARK: - Private

  private func configureCakeCategoryStackView(_ types: [CakeCategory]) {
    cakeCategoryStackView.subviews.forEach { $0.removeFromSuperview() }
    
    if types.isEmpty {
      let chip = LabelChip()
      chip.title = "등록된 카테고리가 없어요"
      chip.isBackgroundSynced = false
      chip.titleColor = R.color.gray_60()
      chip.backgroundColor = R.color.gray_10()
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
          let count = "+\(types.count - 3)"
          
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
    // ❌ 이미지 없는 경우 -> 가짜 이미지 하나 뿌려줌
    var imageUrls = imageUrls
    
    if imageUrls.isEmpty {
      imageUrls.append("")
    }
    
    // 이미지 추가
    cakeImageStackView.subviews.forEach { $0.removeFromSuperview() }
    
    imageUrls.map { imageUrl in
      let imageView = UIControlImageView()
      imageView.setupCornerRadius(Metric.cakeImageCornerRadius)
      imageView.setImage(urlString: imageUrl, placeholder: R.image.thumbnail_placeholder())
      
      // Image size
      imageView.snp.makeConstraints {
        $0.size.equalTo(Metric.cakeImageSize)
      }
      
      // tap gesture
      imageView
        .controlEventPublisher(for: .touchUpInside)
        .sink { [weak self] in
          self?.showImageViewer(imageUrl)
        }
        .store(in: &cancellableBag)
      
      return imageView
    }
    .forEach { imageView in
      cakeImageStackView.addArrangedSubview(imageView)
    }
  }
  
  private func showImageViewer(_ imageUrl: String) {
    if let viewController = findParentViewController() {
      let imageViewer = ImageViewerViewController(imageUrl: imageUrl)
      imageViewer.modalPresentationStyle = .overFullScreen
      viewController.present(imageViewer, animated: true)
    }
  }
  
  // UITableViewCell의 상위 UIViewController를 찾는 함수데스
  private func findParentViewController() -> UIViewController? {
    var responder: UIResponder? = self
    while responder != nil {
      responder = responder?.next
      if let viewController = responder as? UIViewController {
        return viewController
      }
    }
    return nil
  }
  
  private func highlight() {
    contentView.backgroundColor = R.color.gray_10()
  }
  
  private func unhighlight() {
    UIView.animate(withDuration: 0.3) {
      self.contentView.backgroundColor = .clear
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
    setBookmarkImageViewLayout()
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
  
  private func setBookmarkImageViewLayout() {
    contentView.addSubview(bookmarkButton)
    bookmarkButton.snp.makeConstraints {
      $0.top.trailing.equalToSuperview().inset(Metric.padding)
      $0.width.height.equalTo(Metric.bookmarkButtonSize)
      $0.size.equalTo(Metric.bookmarkButtonSize)
    }
    
    // FIXME: 차후 북마크 버튼 숨김 처리 해제
    bookmarkButton.isHidden = true
  }
  
  private func setupHeaderStackViewLayout() {
    contentView.addSubview(headerStackView)
    headerStackView.snp.makeConstraints {
      $0.top.leading.equalToSuperview().inset(Metric.padding)
      $0.trailing.equalTo(bookmarkButton.snp.leading)
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
    contentView.addSubview(locationLabel)
    locationLabel.snp.makeConstraints {
      $0.top.equalTo(headerStackView.snp.bottom).offset(Metric.locationLabelTopPadding)
      $0.leading.equalTo(headerStackView)
      $0.trailing.equalToSuperview().inset(Metric.padding)
    }
  }
  
  private func setupCakeCategoriesStackViewLayout() {
    contentView.addSubview(cakeCategoryStackView)
    cakeCategoryStackView.snp.makeConstraints {
      $0.top.equalTo(locationLabel.snp.bottom).offset(Metric.cakeShopCategoryStackViewTopMargin)
      $0.leading.equalToSuperview().inset(Metric.padding)
    }
  }
  
  private func setupCakeImageScrollView() {
    contentView.addSubview(cakeImageScrollView)
    cakeImageScrollView.snp.makeConstraints {
      $0.top.equalTo(cakeCategoryStackView.snp.bottom).offset(32)
      $0.leading.trailing.equalToSuperview()
      $0.bottom.equalToSuperview().inset(Metric.padding)
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
    contentView.addSubview(divider)
    divider.snp.makeConstraints {
      $0.top.leading.trailing.equalToSuperview()
      $0.height.equalTo(Metric.dividerHeight)
    }
  }
  
  // Setup View
  private func setupView() {
    setupBaseView()
    setupContentView()
  }
  
  private func setupBaseView() {
    hero.isEnabled = true
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
      cell.configure(viewModel: .init(
        cakeShop: SampleData.cakeShopList.first!,
        service: .init(),
        realmStorage: MockRealmStorage()))
      return cell
    }
    .frame(width: 328, height: 158)
    .previewLayout(.sizeThatFits)
  }
}
#endif
