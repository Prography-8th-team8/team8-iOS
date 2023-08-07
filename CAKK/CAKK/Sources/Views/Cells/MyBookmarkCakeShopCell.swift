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
    static let horizontalPadding = 16.f
    static let cakeImageSize = 110.f
  }
  
  // MARK: - Types
  
  typealias DataSource = UICollectionViewDiffableDataSource<Section, Bookmark>
  
  enum Section {
    case cakeImages
  }
  
  
  // MARK: - Properties
  
  private var viewModel: CakeShopCollectionCellModel?
  private var cancellableBag = Set<AnyCancellable>()
  
  
  // MARK: - UI
  
  private let bookmarkButton = HeartButton(isBookmarked: false)
  
  private let shopNameLabel = UILabel().then {
    $0.font = .pretendard(size: 16, weight: .bold)
    $0.textColor = .black
  }
  
  private let locationLabel = UILabel().then {
    $0.font = .pretendard()
    $0.textColor = .black.withAlphaComponent(0.6)
  }
  
  private lazy var headerStackView = UIStackView(arrangedSubviews: [
    shopNameLabel, locationLabel
  ]).then {
    $0.axis = .vertical
    $0.spacing = 8
  }
  
  private let cakeImageScrollView = UIScrollView().then {
    $0.showsHorizontalScrollIndicator = false
    $0.alwaysBounceHorizontal = true
    $0.contentInset = .init(vertical: 0, horizontal: Metric.horizontalPadding)
  }
  
  private let cakeImageStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 6
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
  
  public func configure(_ bookmark: Bookmark) {
    shopNameLabel.text = bookmark.name
    locationLabel.text = bookmark.location
    configureCakeShopImage(bookmark)
  }
  
  
  // MARK: - Private
  
  private func configureCakeShopImage(_ bookmark: Bookmark) {
    cakeImageStackView.subviews.forEach { $0.removeFromSuperview() }
    
    bookmark.imageUrls.compactMap { [weak self] imageUrl in
      guard let self = self else { return nil }
      
      let imageView = UIControlImageView()
      imageView.setupCornerRadius(10)
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
  
}


// MARK: - UI & Layouts

extension MyBookmarkCakeShopCell {
  
  private func setup() {
    setupLayout()
    setupView()
  }
  
  // Setup Layout
  private func setupLayout() {
    setupHeader()
    setupCakeImageScrollView()
    setupCakeImageStackView()
  }
  
  private func setupHeader() {
    contentView.addSubview(headerStackView)
    headerStackView.snp.makeConstraints {
      $0.horizontalEdges.equalToSuperview().inset(Metric.horizontalPadding)
      $0.top.equalToSuperview().inset(16)
    }
  }
  
  private func setupCakeImageScrollView() {
    contentView.addSubview(cakeImageScrollView)
    cakeImageScrollView.snp.makeConstraints {
      $0.top.equalTo(headerStackView.snp.bottom).offset(10)
      $0.leading.trailing.equalToSuperview()
      $0.bottom.equalToSuperview().inset(10)
      $0.height.equalTo(Metric.cakeImageSize)
    }
  }
  
  private func setupCakeImageStackView() {
    cakeImageScrollView.addSubview(cakeImageStackView)
    cakeImageStackView.snp.makeConstraints {
      $0.edges.height.equalToSuperview()
    }
  }
  
  private func setupView() {
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
