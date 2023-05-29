//
//  ShopDetailViewController.swift
//  CAKK
//
//  Created by Mason Kim on 2023/05/10.
//

import UIKit

import SnapKit
import Then

import Combine

final class ShopDetailViewController: UIViewController {
  
  // MARK: - Constants
  
  enum Constants {
    static let skeletonText = "-"
  }
  
  // MARK: - Properties
  
  private let viewModel: ShopDetailViewModel
  
  private var cancellableBag = Set<AnyCancellable>()
  
  // MARK: - UI
  
  private let mainScrollView = UIScrollView().then {
    $0.contentInsetAdjustmentBehavior = .always
  }
  private let contentStackView = UIStackView().then {
    $0.axis = .vertical
  }
  
  private let shopImageView = UIImageView().then {
    $0.image = R.image.noimage()
    $0.backgroundColor = R.color.stroke()
  }
  
  private let nameLabel = UILabel().then {
    $0.font = .pretendard(size: 20, weight: .bold)
    $0.text = Constants.skeletonText
    $0.textAlignment = .center
  }
  
  private let addressLabel = UILabel().then {
    $0.font = .pretendard(size: 16)
    $0.text = Constants.skeletonText
    $0.textAlignment = .center
  }
  
  private let callMenuButton = DetailMenuButton(image: R.image.call(), title: "전화하기")
  private let bookmarkMenuButton = DetailMenuButton(image: R.image.bookmark(), title: "북마크")
  private let naviMenuButton = DetailMenuButton(image: R.image.navi(), title: "길 안내")
  private let shareMenuButton = DetailMenuButton(image: R.image.share(), title: "공유하기")
  
  private lazy var menuButtonStackView = UIStackView(
    arrangedSubviews: [callMenuButton,
                       bookmarkMenuButton,
                       naviMenuButton,
                       shareMenuButton]
  ).then {
    $0.axis = .horizontal
    $0.distribution = .fillEqually
    $0.addSeparators(color: R.color.stroke()?.withAlphaComponent(0.5))
//    $0.isHidden = true // TODO: - MVP에서 메뉴 버튼 숨기기?
  }
  
  private lazy var headerStackView = UIStackView(
    arrangedSubviews: [nameLabel,
                       addressLabel,
                       menuButtonStackView]
  ).then {
    $0.axis = .vertical
    $0.spacing = 12
    $0.setCustomSpacing(32, after: addressLabel)
  }
  
  private let keywordTitleView = DetailSectionTitleView(title: "키워드")
  
  private let keywordScrollView = UIScrollView().then {
    $0.showsHorizontalScrollIndicator = false
    $0.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
  }
  private let keywordContentStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 4
  }
  
  private var separatorView: UIView {
    UIView().then {
      $0.snp.makeConstraints { view in
        view.height.equalTo(10)
      }
      $0.backgroundColor = R.color.stroke()?.withAlphaComponent(0.2)
    }
  }
  
  private let detailInfoView = DetailInfoView()
  
  private lazy var indicatorContainerView = UIView(frame: view.bounds).then {
    $0.backgroundColor = .systemBackground
  }
  
  private lazy var indicatorView = UIActivityIndicatorView().then {
    $0.center = indicatorContainerView.center
    $0.color = .gray
    $0.style = .medium
  }
    
  // MARK: - LifeCycle
  
  init(viewModel: ShopDetailViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
    bind()
  }
  
  // MARK: - Public
  
  func notifyViewWillShow() {
    viewModel.input.viewWillShow.send()
  }
  
  // MARK: - Private
  
  private func setup() {
    setupLayout()
    setupView()
  }
  
  private func setupLayout() {
    setupScrollViewLayout()
    setupShopImageViewLayout()
    setupHeaderStackViewLayout()
    setupKeywordTitleLabelLayout()
    setupKeywordScrollViewLayout()
    setupDetailInfoView()
    setupActivityIndicator()
  }
  
  private func setupScrollViewLayout() {
    view.addSubview(mainScrollView)
    mainScrollView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    
    mainScrollView.addSubview(contentStackView)
    contentStackView.snp.makeConstraints {
      $0.edges.equalToSuperview()
      $0.width.equalToSuperview()
    }
  }
  
  private func setupShopImageViewLayout() {
    contentStackView.addArrangedSubview(shopImageView)
    shopImageView.snp.makeConstraints {
      $0.height.equalTo(view.frame.width * 0.5)
    }
    contentStackView.setCustomSpacing(40, after: shopImageView)
  }
  
  private func setupHeaderStackViewLayout() {
    contentStackView.addArrangedSubview(headerStackView)
    contentStackView.setCustomSpacing(40, after: headerStackView)
    addSeperatorLineView()
  }
  
  private func setupKeywordTitleLabelLayout() {
    contentStackView.addArrangedSubview(keywordTitleView)
  }
  
  private func setupKeywordScrollViewLayout() {
    contentStackView.addArrangedSubview(keywordScrollView)
    keywordScrollView.addSubview(keywordContentStackView)
    keywordContentStackView.snp.makeConstraints {
      $0.edges.equalToSuperview()
      $0.height.equalToSuperview()
    }
    contentStackView.setCustomSpacing(20, after: keywordScrollView)
  }
  
  private func setupDetailInfoView() {
    contentStackView.addArrangedSubview(separatorView)
    contentStackView.addArrangedSubview(detailInfoView)
  }
  
  private func addSeperatorLineView(withBottomSpacing spacing: CGFloat = 0) {
    let seperatorView = UIView().then {
      $0.backgroundColor = R.color.stroke()?.withAlphaComponent(0.5)
      $0.snp.makeConstraints { view in
        view.height.equalTo(1)
      }
    }
    contentStackView.addArrangedSubview(seperatorView)
    contentStackView.setCustomSpacing(spacing, after: seperatorView)
  }
  
  private func setupActivityIndicator() {
    view.addSubview(indicatorContainerView)
    indicatorContainerView.addSubview(indicatorView)
    setActivityIndicator(toAnimate: true)
  }
  
  private func setupView() {
    view.backgroundColor = .white
    title = "상세정보"
  }
  
  private func setupCakeShopTypeChips(with cakeShopDetail: CakeShopDetailResponse) {
    let chipViews = cakeShopDetail.cakeShopTypes.map {
      CakeShopTypeChip($0)
    }
    
    chipViews.forEach {
      keywordContentStackView.addArrangedSubview($0)
    }
  }
  
  private func setActivityIndicator(toAnimate isAnimate: Bool) {
    guard isAnimate != indicatorView.isAnimating else { return }
    
    let alpha: CGFloat = isAnimate ? 1.0 : 0.0
    UIView.animate(withDuration: 0.5) {
      self.indicatorContainerView.alpha = alpha
    }
    
    if isAnimate {
      indicatorView.startAnimating()
    } else {
      indicatorView.stopAnimating()
    }
  }
  
  // MARK: - Bind
  
  private func bind() {
    viewModel.output.cakeShopDetail
      .sink { [weak self] in
        guard let self else { return }

        self.nameLabel.text = $0.name
//        self.addressLabel.text = $0.location
        self.setupCakeShopTypeChips(with: $0)
        self.setActivityIndicator(toAnimate: false)
      }
      .store(in: &cancellableBag)
  }
}

// MARK: - Preview

import SwiftUI

struct ShopDetailViewControllerPreView: PreviewProvider {
  static var previews: some View {
    UINavigationController(
      rootViewController:
        ShopDetailViewController(
          viewModel: ShopDetailViewModel(
            cakeShop: SampleData.cakeShopList.first!,
            service: NetworkService<CakeAPI>()))
    ).toPreview()
  }
}
