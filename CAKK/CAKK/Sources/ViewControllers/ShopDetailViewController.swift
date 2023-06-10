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
  
  // 주소
  private let addressLabel = UILabel().then {
    $0.font = .pretendard(size: 16)
    $0.text = Constants.skeletonText
    $0.textAlignment = .right
  }
  
  private var dotLabel: UILabel {
    return UILabel().then {
      $0.textColor = R.color.stroke()
      $0.text = "·"
    }
  }
  
  private let copyAddressButton = UIButton().then {
    $0.setAttributedTitle(
      NSAttributedString(
        string: "주소 복사",
        attributes: [.font: UIFont.pretendard(weight: .bold)]), for: .normal
    )
  }
  
  private lazy var addressStackView = UIStackView(arrangedSubviews: [
    addressLabel,
    dotLabel,
    copyAddressButton
  ]).then {
    $0.alignment = .center
    $0.axis = .horizontal
    $0.spacing = 4
  }
  
  private let addressContainerView = UIView()
  
  // 메뉴 버튼
  private let callMenuButton = DetailMenuButton(image: R.image.call(), title: "전화하기")
  private let bookmarkMenuButton = DetailMenuButton(image: R.image.bookmark(), title: "북마크")
  private let naviMenuButton = DetailMenuButton(image: R.image.navi(), title: "길 안내")
  private let shareMenuButton = DetailMenuButton(image: R.image.share(), title: "공유하기")
  
  private lazy var menuButtonStackView = UIStackView(
    arrangedSubviews: [callMenuButton,
                       //                       naviMenuButton,
                       shareMenuButton]
  ).then {
    $0.axis = .horizontal
    $0.distribution = .fillEqually
    $0.addSeparators(color: R.color.stroke()?.withAlphaComponent(0.5))
  }
  
  private lazy var headerStackView = UIStackView(
    arrangedSubviews: [nameLabel,
                       addressContainerView,
                       menuButtonStackView]
  ).then {
    $0.axis = .vertical
    $0.spacing = 12
    $0.setCustomSpacing(32, after: addressContainerView)
  }
  
  // 키워드
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
  
  private let blogReviewTitleView = DetailSectionTitleView(title: "블로그 리뷰")
  
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
    
    // TODO: - 일단 상세정보 없으니까 가림.
    //    setupDetailInfoViewLayout()
    
    setupBlogReviewViewLayout()
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
    contentStackView.setCustomSpacing(48, after: shopImageView)
  }
  
  private func setupHeaderStackViewLayout() {
    contentStackView.addArrangedSubview(headerStackView)
    contentStackView.setCustomSpacing(38, after: headerStackView)
    addSeperatorLineView()
    
    // 스택뷰 내부의 주소 부분을 중간으로 잡기 위한 containerView 구성
    addressContainerView.addSubview(addressStackView)
    addressStackView.snp.makeConstraints {
      $0.verticalEdges.equalToSuperview()
      $0.centerX.equalToSuperview()
    }
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
  
  private func setupDetailInfoViewLayout() {
    contentStackView.addArrangedSubview(separatorView)
    contentStackView.addArrangedSubview(detailInfoView)
  }
  
  private func setupBlogReviewViewLayout() {
    contentStackView.addArrangedSubview(separatorView)
    contentStackView.addArrangedSubview(blogReviewTitleView)
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
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
      self.setActivityIndicator(toAnimate: false)
    }
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
  
  private func setupBlogReviewsView(with cakeShopDetail: CakeShopDetailResponse) {
    
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
    viewModel.input.viewDidLoad.send()
    
    viewModel.output.cakeShopDetail
      .sink { [weak self] cakeShopDetail in
        guard let self else { return }
        
        self.nameLabel.text = cakeShopDetail.name
        self.addressLabel.text = cakeShopDetail.address
        self.setupCakeShopTypeChips(with: cakeShopDetail)
        self.setActivityIndicator(toAnimate: false)
      }
      .store(in: &cancellableBag)
    
    viewModel.output.failToFetchDetail
      .sink { [weak self] in
        guard let self else { return }
        self.showFailAlert(with: "상세 정보를 불러오지 못했어요.") {
          self.navigationController?.popViewController(animated: true)
        }
      }
      .store(in: &cancellableBag)
  }
}

// MARK: - Preview

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct ShopDetailViewControllerPreView: PreviewProvider {
  static var previews: some View {
    UINavigationController(
      rootViewController:
        ShopDetailViewController(
          viewModel: ShopDetailViewModel(
            cakeShop: SampleData.cakeShopList.first!,
            service: NetworkService<CakeAPI>(type: .stub)))
    ).toPreview()
  }
}
#endif
