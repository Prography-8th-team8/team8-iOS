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
  
  private let scrollView = UIScrollView()
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
  }
  
  private func setupScrollViewLayout() {
    view.addSubview(scrollView)
    scrollView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    
    scrollView.addSubview(contentView)
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
  
  private func setupView() {
    view.backgroundColor = .white
    title = "상세정보"
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
