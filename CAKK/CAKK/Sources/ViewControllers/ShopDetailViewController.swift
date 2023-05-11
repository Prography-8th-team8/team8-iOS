//
//  ShopDetailViewController.swift
//  CAKK
//
//  Created by Mason Kim on 2023/05/10.
//

import UIKit

import SnapKit
import Then

final class ShopDetailViewController: UIViewController {
  
  // MARK: - Constants
  
  enum Metric {
    
  }
  
  // MARK: - Properties
  
  private let cakeShop: CakeShop
  
  // MARK: - UI
  
  private let mainScrollView = UIScrollView().then {
    $0.contentInsetAdjustmentBehavior = .always
  }
  private let contentStackView = UIStackView().then {
    $0.axis = .vertical
  }
  
  private let shopImageView = UIImageView().then {
    $0.backgroundColor = R.color.stroke()
  }
  
  private lazy var nameLabel = UILabel().then {
    $0.font = .pretendard(size: 20, weight: .bold)
    $0.textAlignment = .center
    $0.text = cakeShop.name
  }
  
  private lazy var addressLabel = UILabel().then {
    $0.font = .pretendard(size: 16)
    $0.textAlignment = .center
    $0.text = cakeShop.location
  }
  
  private let callMenuButton = MenuDetailButton(image: R.image.call(), title: "전화하기")
  private let bookmarkMenuButton = MenuDetailButton(image: R.image.bookmark(), title: "북마크")
  private let naviMenuButton = MenuDetailButton(image: R.image.navi(), title: "길 안내")
  private let shareMenuButton = MenuDetailButton(image: R.image.share(), title: "공유하기")
  
  private lazy var menuButtonStackView = UIStackView(
    arrangedSubviews: [callMenuButton,
                       bookmarkMenuButton,
                       naviMenuButton,
                       shareMenuButton]
  ).then {
    $0.axis = .horizontal
    $0.distribution = .fillEqually
    $0.addSeparators(color: R.color.stroke()?.withAlphaComponent(0.5) ?? .lightGray)
//    $0.isHidden = true // TODO: - MVP에서 메뉴 버튼 숨기기?
  }
  
  private lazy var titleStackView = UIStackView(
    arrangedSubviews: [nameLabel, addressLabel, menuButtonStackView]
  ).then {
    $0.axis = .vertical
    $0.spacing = 12
    $0.setCustomSpacing(32, after: addressLabel)
  }
  
  private let keywordTitleLabel = UILabel().then {
    $0.text = "키워드"
    $0.font = .pretendard(size: 20, weight: .bold)
  }
  
  private let keywordScrollView = UIScrollView().then {
    $0.showsHorizontalScrollIndicator = false
    $0.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
  }
  private let keywordContentStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 4
  }
  
  private var seperatorView: UIView {
    UIView().then {
      $0.snp.makeConstraints { view in
        view.height.equalTo(10)
      }
      $0.backgroundColor = R.color.stroke()?.withAlphaComponent(0.2)
    }
  }
  
  private lazy var detailInfoView = MenuDetailInfoView(with: cakeShop)
    
  // MARK: - LifeCycle
  
  init(cakeShop: CakeShop) {
    self.cakeShop = cakeShop
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }
  
  // MARK: - Public
  
  // MARK: - Private
  
  private func setup() {
    setupLayout()
    setupView()
  }
  
  private func setupLayout() {
    setupScrollViewLayout()
    setupShopImageViewLayout()
    setupTitleViewLayout()
    setupKeywordTitleLabelLayout()
    setupKeywordScrollViewLayout()
    setupDetailInfoView()
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
  
  private func setupTitleViewLayout() {
    contentStackView.addArrangedSubview(titleStackView)
    contentStackView.setCustomSpacing(40, after: titleStackView)
    addSeperatorLineView(withBottomSpacing: 32)
  }
  
  private func setupKeywordTitleLabelLayout() {
    contentStackView.addArrangedSubview(keywordTitleLabel)
    contentStackView.setCustomSpacing(24, after: keywordTitleLabel)
    keywordTitleLabel.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(16)
    }
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
    contentStackView.addArrangedSubview(seperatorView)
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
  
  private func setupView() {
    view.backgroundColor = .white
    title = "상세정보"
    setupCakeShopChips()
  }
  
  private func setupCakeShopChips() {
    let chipViews = cakeShop.cakeShopTypes.map {
      CakeShopTypeChip($0)
    }
    
    chipViews.forEach {
      keywordContentStackView.addArrangedSubview($0)
    }
  }
}

// MARK: - Preview

import SwiftUI

struct ShopDetailViewControllerPreView: PreviewProvider {
  static var previews: some View {
    UINavigationController(
      rootViewController:
        ShopDetailViewController(cakeShop: SampleData.cakeShopList.first!)
    ).toPreview()
    
  }
}