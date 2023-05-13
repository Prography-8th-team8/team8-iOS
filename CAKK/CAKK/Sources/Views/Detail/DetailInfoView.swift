//
//  DetailInfoView.swift
//  CAKK
//
//  Created by Mason Kim on 2023/05/11.
//

import UIKit

import SnapKit
import Then

final class DetailInfoView: UIView {
  
  // MARK: - Constants
  
  enum Metric {
    static let horizontalPadding = 16.f
  }
  
  // MARK: - Properties
  
  private let cakeShop: CakeShop
  private var isBusinessTimeExpanded = false
  
  // MARK: - UI
  
  private let detailTitleLabel = UILabel().then {
    $0.text = "상세 정보"
    $0.font = .pretendard(size: 20, weight: .bold)
  }
  
  private var dotLabel: UILabel {
    return UILabel().then {
      $0.textColor = R.color.stroke()
      $0.text = "·"
    }
  }
  
  // MARK: - UI - 주소부분
  
  private let addressContainerView = UIView()
  
  private let addressIconImageView = UIImageView(image: R.image.map())
  
  private lazy var addressLabel = UILabel().then {
    $0.text = "\(cakeShop.location)"
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
    addressLabel,
    dotLabel,
    copyAddressButton
  ]).then {
    $0.spacing = 4
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
  
  // MARK: - UI - 영업시간 부분
  
  private lazy var businessTimeContainerButton = UIButton().then {
    $0.addTarget(self, action: #selector(showAndHideWeekendBusinessHours), for: .touchUpInside)
  }
  
  private let businessTimeIconImageView = UIImageView(image: R.image.time()).then {
    $0.contentMode = .scaleAspectFit
    $0.snp.makeConstraints { imageView in
      imageView.width.height.equalTo(20)
    }
  }
  
  private lazy var businessStateLabel = UILabel().then {
    $0.font = .pretendard(weight: .bold)
    $0.text = "영업중"
  }
  
  private lazy var businessTimeLabel = UILabel().then {
    $0.text = "22:30에 영업 종료"
    $0.font = .pretendard()
    //    $0.text = cakeShop. TODO: - 영업 시간 가져와야 함
  }
  
  private let businessTimeToggleImageView = UIImageView().then {
    $0.image = R.image.toggle_arrow_closed()
    $0.contentMode = .scaleAspectFit
    $0.snp.makeConstraints { imageView in
      imageView.width.height.equalTo(16)
    }
  }
  
  private lazy var businessTimeHorizontalStackView = UIStackView(arrangedSubviews: [
    businessTimeIconImageView,
    businessStateLabel,
    dotLabel,
    businessTimeLabel,
    businessTimeToggleImageView
  ]).then {
    $0.axis = .horizontal
    $0.spacing = 4
    $0.setCustomSpacing(10, after: businessTimeIconImageView)
    $0.alignment = .center
  }
  
  private let businessTimeWeekendStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 8
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
    setupBusinessHourLabels()
  }
  
  private func setupLayout() {
    setupTitleLabelLayout()
    setupAddressViewLayout()
    setupBusinessHourViewLayout()
  }
  
  private func setupTitleLabelLayout() {
    addSubview(detailTitleLabel)
    detailTitleLabel.snp.makeConstraints {
      $0.top.equalToSuperview().inset(40)
      $0.horizontalEdges.equalToSuperview().inset(Metric.horizontalPadding)
    }
  }
  
  private func setupAddressViewLayout() {
    addSubview(addressContainerView)
    addressContainerView.snp.makeConstraints {
      $0.top.equalTo(detailTitleLabel.snp.bottom).offset(24)
      $0.horizontalEdges.equalToSuperview().inset(Metric.horizontalPadding)
      $0.height.equalTo(100)
    }
    addressContainerView.addBorders(to: [.top, .bottom], color: R.color.stroke()?.withAlphaComponent(0.5) ?? .lightGray)
    
    addressContainerView.addSubview(addressIconImageView)
    addressIconImageView.snp.makeConstraints {
      $0.leading.equalToSuperview()
      $0.top.equalToSuperview().inset(16)
    }
    
    addressContainerView.addSubview(addressLabelsStackView)
    addressLabelsStackView.snp.makeConstraints {
      $0.top.equalTo(addressIconImageView)
      $0.leading.equalTo(addressIconImageView.snp.trailing).offset(Metric.horizontalPadding)
      $0.bottom.equalToSuperview().inset(16)
    }
  }
  
  private func setupBusinessHourViewLayout() {
    addSubview(businessTimeContainerButton)
    businessTimeContainerButton.snp.makeConstraints {
      $0.top.equalTo(addressContainerView.snp.bottom)
      $0.height.equalTo(50)
      $0.horizontalEdges.equalToSuperview().inset(Metric.horizontalPadding)
    }
    
    businessTimeContainerButton.addSubview(businessTimeHorizontalStackView)
    businessTimeHorizontalStackView.snp.makeConstraints {
      $0.verticalEdges.leading.equalToSuperview()
    }
    
    addSubview(businessTimeWeekendStackView)
    businessTimeWeekendStackView.snp.makeConstraints {
      $0.leading.equalTo(businessStateLabel)
      $0.top.equalTo(businessTimeHorizontalStackView.snp.bottom) //.offset(12)
      $0.bottom.equalToSuperview()
    }
    
    // 버튼 내부의 subview이 버튼의 터치 이벤트를 막지 않도록 함
    businessTimeContainerButton.subviews.forEach {
      $0.isUserInteractionEnabled = false
    }
  }
  
  @objc private func showAndHideWeekendBusinessHours() {
    businessTimeWeekendStackView.arrangedSubviews.forEach {
      $0.isHidden = isBusinessTimeExpanded
    }
    
    let toggleImage = isBusinessTimeExpanded ? R.image.toggle_arrow_closed() : R.image.toggle_arrow_opened()
    businessTimeToggleImageView.image = toggleImage
    
    isBusinessTimeExpanded.toggle()
  }
  
  private func setupBusinessHourLabels() {
    // TODO: 날짜별 정보 받아와서 뿌려주기... / 해당 날짜 bold 처리
    (1...7).forEach { _ in
      let label = UILabel().then {
        $0.text = "월 11:00 - 22:30"
        $0.font = .pretendard()
      }
      businessTimeWeekendStackView.addArrangedSubview(label)
      label.isHidden = true
    }
  }
}

// MARK: - Preview

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct MenuDetailInfoViewPreview: PreviewProvider {
  static var previews: some View {
    UIViewPreview {
      return DetailInfoView(with: SampleData.cakeShopList.first!)
    }
    .padding()
    .frame(height: 400)
    .border(.black)
    .previewLayout(.sizeThatFits)
  }
}
#endif
