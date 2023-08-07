//
//  MyBookmarkCakeShopCell.swift
//  CAKK
//
//  Created by Mason Kim on 2023/07/30.
//

import UIKit

import Combine
import CombineCocoa

import SnapKit
import Then

import Kingfisher

final class MyBookmarkCakeShopCell: UICollectionViewCell {
  
  // MARK: - Constants
  
  enum Metric {
    static let padding = 20.f
    
    static let cakeImageSize = 96.f
    static let cakeImageCornerRadius = 20.f
    static let cakeImageSpacing = 8.f
    
    static let stackViewDividerWidth = 1.f
    static let stackViewDividerHeight = 12.f
    
    static let bookmarkButtonSize = 24.f
  }
  
  // MARK: - Types
  
  typealias DataSource = UICollectionViewDiffableDataSource<Section, Bookmark>
  
  enum Section {
    case cakeImages
  }
  
  
  // MARK: - Properties
  
  private var viewModel: MyBookmarkCellViewModel?
  
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
  
  private let bookmarkButton = HeartButton(isBookmarked: true)
  
  private let shopNameLabel = UILabel().then {
    $0.font = .pretendard(size: 16, weight: .bold)
    $0.textColor = .black
  }
  
  private let districtLocationLabel = UILabel().then {
    $0.font = .pretendard(size: 12)
  }
  
  private let stackViewDivider = UIView().then {
    $0.backgroundColor = R.color.gray_40()
  }
  
  private lazy var shopNameDistrictLocationStackView = UIStackView(arrangedSubviews: [
    shopNameLabel, stackViewDivider, districtLocationLabel
  ]).then {
    $0.alignment = .center
    $0.axis = .horizontal
    $0.spacing = 4
  }
  
  private let locationLabel = UILabel().then {
    $0.font = .pretendard()
    $0.textColor = R.color.gray_60()
  }
  
  
  private lazy var headerStackView = UIStackView(arrangedSubviews: [
    shopNameDistrictLocationStackView, locationLabel
  ]).then {
    $0.alignment = .leading
    $0.axis = .vertical
    $0.spacing = 8
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
  
  public func configure(viewModel: MyBookmarkCellViewModel) {
    self.viewModel = viewModel
    bind()
    configure(viewModel.bookmark)
  }
  
  
  // MARK: - Private
  
  private func bind() {
    bookmarkButton.tapPublisher
      .throttle(for: 1, scheduler: DispatchQueue.main, latest: false)
      .sink { [weak self] _ in
        print("tap!")
        self?.viewModel?.input.tapBookmarkButton.send()
      }
      .store(in: &cancellableBag)
    
    viewModel?.output.isBookmarked.sink { [weak self] isBookmarked in
      self?.bookmarkButton.setBookmark(isBookmarked)
    }
    .store(in: &cancellableBag)
  }
  
  private func configure(_ bookmark: Bookmark) {
    shopNameLabel.text = bookmark.name
    locationLabel.text = bookmark.location
    districtLocationLabel.text = bookmark.district.koreanName
    configureCakeShopImage(bookmark)
  }
  
  private func configureCakeShopImage(_ bookmark: Bookmark) {
    cakeImageStackView.subviews.forEach { $0.removeFromSuperview() }
    
    bookmark.imageUrls.compactMap { [weak self] imageUrl in
      guard let self = self else { return nil }
      
      let imageView = UIControlImageView()
      imageView.setupCornerRadius(Metric.cakeImageCornerRadius)
      imageView.setImage(urlString: imageUrl,
                         placeholder: R.image.thumbnail_placeholder())
      
      imageView.snp.makeConstraints {
        $0.size.equalTo(Metric.cakeImageSize)
      }
      
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

extension MyBookmarkCakeShopCell {
  
  private func setup() {
    setupLayout()
    setupView()
  }
  
  // Setup Layout
  private func setupLayout() {
    setBookmarkButtonLayout()
    setupHeader()
    setupCakeImageScrollView()
    setupCakeImageStackView()
    setupDividerLayout()
  }
  
  private func setupHeader() {
    contentView.addSubview(headerStackView)
    headerStackView.snp.makeConstraints {
      $0.leading.equalToSuperview().inset(Metric.padding)
      $0.top.equalToSuperview().inset(20)
      $0.trailing.equalTo(bookmarkButton.snp.leading)
    }
    
    stackViewDivider.snp.makeConstraints {
      $0.width.equalTo(Metric.stackViewDividerWidth)
      $0.height.equalTo(Metric.stackViewDividerHeight)
    }
  }
  
  private func setBookmarkButtonLayout() {
    contentView.addSubview(bookmarkButton)
    bookmarkButton.snp.makeConstraints {
      $0.top.trailing.equalToSuperview().inset(Metric.padding)
      $0.size.equalTo(Metric.bookmarkButtonSize)
    }
  }
  
  private func setupCakeImageScrollView() {
    contentView.addSubview(cakeImageScrollView)
    cakeImageScrollView.snp.makeConstraints {
      $0.top.equalTo(headerStackView.snp.bottom).offset(32)
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
      $0.bottom.leading.trailing.equalToSuperview()
      $0.height.equalTo(1)
    }
  }
  
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

struct BookmarkedCakeShopCellPreview: PreviewProvider {
  static var previews: some View {
    UIViewPreview {
      let cell = MyBookmarkCakeShopCell()
      
      return cell
    }
    .frame(width: 328, height: 158)
    .previewLayout(.sizeThatFits)
  }
}
#endif
