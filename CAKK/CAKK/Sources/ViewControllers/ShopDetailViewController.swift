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
  
  private let mainScrollView = UIScrollView()
  private let contentView = UIView()
  
  private let shopImageView = UIImageView().then {
    $0.backgroundColor = .lightGray
  }
  
  private lazy var nameLabel = UILabel().then {
    $0.font = .pretendard(size: 20, weight: .bold)
    $0.textAlignment = .center
    $0.text = cakeShop.name
  }
  
  private lazy var addressLabel = UILabel().then {
    $0.font = .pretendard(size: 16)
    $0.textAlignment = .center
    $0.text = cakeShop.district
  }
  
  private lazy var titleStackView = UIStackView(
    arrangedSubviews: [nameLabel, addressLabel]
  ).then {
    $0.axis = .vertical
    $0.spacing = 12.f
    $0.distribution = .fillEqually
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
    $0.addSeparators(color: .gray.withAlphaComponent(0.3))
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
  
//  private lazy var detailKeywordView = DetailKeywordView(with: cakeShop.cakeShopTypes)
  
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
    setupMenuButtonStackViewLayout()
//    setupDetailKeywordViewLayout()
    setupKeywordTitleLabelLayout()
    setupKeywordScrollViewLayout()
  }
  
  private func setupScrollViewLayout() {
    view.addSubview(mainScrollView)
    mainScrollView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    
    mainScrollView.addSubview(contentView)
    contentView.snp.makeConstraints {
      $0.edges.equalToSuperview()
      $0.width.equalToSuperview()
    }
  }
  
  private func setupShopImageViewLayout() {
    contentView.addSubview(shopImageView)
    shopImageView.snp.makeConstraints {
      $0.height.equalTo(view.frame.width * 0.5)
      $0.top.horizontalEdges.equalToSuperview()
    }
  }
  
  private func setupTitleViewLayout() {
    contentView.addSubview(titleStackView)
    titleStackView.snp.makeConstraints {
      $0.horizontalEdges.equalToSuperview()
      $0.top.equalTo(shopImageView.snp.bottom).offset(40)
    }
  }
  
  private func setupMenuButtonStackViewLayout() {
    contentView.addSubview(menuButtonStackView)
    menuButtonStackView.snp.makeConstraints {
      $0.top.equalTo(titleStackView.snp.bottom).offset(32)
      $0.horizontalEdges.equalToSuperview()
    }
  }
  
  private func setupKeywordTitleLabelLayout() {
    contentView.addSubview(keywordTitleLabel)
    keywordTitleLabel.snp.makeConstraints {
      $0.top.equalTo(menuButtonStackView.snp.bottom).offset(40)
      $0.leading.equalToSuperview().offset(16)
    }
  }
  
  private func setupKeywordScrollViewLayout() {
    contentView.addSubview(keywordScrollView)
    keywordScrollView.snp.makeConstraints {
      $0.top.equalTo(keywordTitleLabel.snp.bottom).offset(24)
      $0.horizontalEdges.equalToSuperview()
      $0.bottom.equalToSuperview().inset(24)
    }
    
    keywordScrollView.addSubview(keywordContentStackView)
    keywordContentStackView.snp.makeConstraints {
      $0.edges.equalToSuperview()
      $0.height.equalToSuperview()
    }
  }
  
  private func setupView() {
    view.backgroundColor = .white
    title = "상세정보"
    setupCakeShopChips()
  }
  
  private func setupCakeShopChips() {
    let chipViews = cakeShop.cakeShopTypes.map { _ in
      let chipView = ChipView()
      // TODO: ChipView 케이크샵 타입에 따라 색상, 레이블 꾸미기...
      chipView.title = "케이크 카테고리"
      chipView.titleColor = R.color.iris100()
      return chipView
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
