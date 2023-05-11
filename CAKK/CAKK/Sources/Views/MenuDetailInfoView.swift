//
//  MenuDetailInfoView.swift
//  CAKK
//
//  Created by Mason Kim on 2023/05/11.
//

import UIKit

import SnapKit
import Then

final class MenuDetailInfoView: UIView {
  
  // MARK: - Constants
  
  enum Metric {
    static let horizontalPadding = 16.f
  }
  
  // MARK: - Properties
  
  private let cakeShop: CakeShop
  
  // MARK: - UI
  
  private let detailTitleLabel = UILabel().then {
    $0.text = "상세 정보"
    $0.font = .pretendard(size: 20, weight: .bold)
  }
  
  private let addressView = UIView()
  private let addressIconImageView = UIImageView(image: R.image.map())
  
  private lazy var addressLabel = UILabel().then {
    $0.text = "\(cakeShop.location) ·"
    $0.font = .pretendard()
  }
  private let copyAddressButton = UIButton().then {
    $0.setAttributedTitle(
      NSAttributedString(
        string: "주소 복사",
        attributes: [.font: UIFont.pretendard(weight: .bold)]), for: .normal
    )
  }
  private lazy var addressHorizontalStackView = UIStackView(arrangedSubviews: [
    addressLabel, copyAddressButton
  ]).then {
    $0.spacing = 8
    $0.axis = .horizontal
  }
  
  private lazy var lotAddressLabel = UILabel().then {
    $0.textColor = R.color.stroke()
    $0.font = .pretendard()
    $0.text = "지번: 갈현동 399-7"
    //    $0.text = cakeShop. TODO: - 지번 주소 가져와야 함
  }
  private lazy var distanceFromStationLabel = UILabel().then {
    $0.text = "연신내역 7번 출구에서 219m"
    //    $0.text = cakeShop. TODO: - 역에서의 거리 가져와야 함
    $0.font = .pretendard()
  }
  
  private lazy var addressLabelsStackView = UIStackView(arrangedSubviews: [
    addressHorizontalStackView,
    lotAddressLabel,
    distanceFromStationLabel
  ]).then {
    $0.axis = .vertical
    $0.distribution = .fillEqually
    $0.spacing = 12
  }
  
  private let businessTimeButton = UIButton()
  private let businessTimeIconImageView = UIImageView(image: R.image.time())
  private lazy var businessStateLabel = UILabel().then {
    $0.font = .pretendard(weight: .bold)
    $0.text = "영업중"
  }
  private lazy var businessTimeLabel = UILabel().then {
    $0.text = "22:30에 영업 종료"
    $0.font = .pretendard()
    //    $0.text = cakeShop. TODO: - 영업 시간 가져와야 함
  }
  
  // MARK: - LifeCycle
  
  init(with cakeShop: CakeShop) {
    self.cakeShop = cakeShop
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Public
  
  // MARK: - Private
  
  private func setup() {
    setupLayout()
  }
  
  private func setupLayout() {
    setupTitleLabelLayout()
    setupAddressView()
    setupBusinessHourView()
  }
  
  private func setupTitleLabelLayout() {
    addSubview(detailTitleLabel)
    detailTitleLabel.snp.makeConstraints {
      $0.top.equalToSuperview().inset(40)
      $0.horizontalEdges.equalToSuperview().inset(Metric.horizontalPadding)
    }
  }
  
  private func setupAddressView() {
    addSubview(addressView)
    addressView.snp.makeConstraints {
      $0.top.equalTo(detailTitleLabel.snp.bottom).offset(24)
      $0.horizontalEdges.equalToSuperview().inset(Metric.horizontalPadding)
      $0.height.equalTo(100)
    }
    addressView.addBorders(to: [.top, .bottom], color: R.color.stroke() ?? .lightGray)
    
    addressView.addSubview(addressIconImageView)
    addressIconImageView.snp.makeConstraints {
      $0.leading.equalToSuperview()
      $0.top.equalToSuperview().inset(16)
    }
    
    addressView.addSubview(addressLabelsStackView)
    addressLabelsStackView.snp.makeConstraints {
      $0.top.equalTo(addressIconImageView)
      $0.leading.equalTo(addressIconImageView.snp.trailing).offset(Metric.horizontalPadding)
      $0.bottom.equalToSuperview().inset(16)
    }
  }
  
  private func setupBusinessHourView() {
    
  }
}

// MARK: - Preview

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct MenuDetailInfoViewPreview: PreviewProvider {
  static var previews: some View {
    UIViewPreview {
      return MenuDetailInfoView(with: SampleData.cakeShopList.first!)
    }
    .padding()
//    .frame(height: 250)
    .border(.black)
    .previewLayout(.sizeThatFits)
  }
}
#endif
