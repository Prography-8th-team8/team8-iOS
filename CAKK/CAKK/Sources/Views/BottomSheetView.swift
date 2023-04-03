//
//  BottomSheetView.swift
//  CAKK
//
//  Created by Mason Kim on 2023/04/03.
//

import UIKit

final class BottonSheetView: UIView {
  
  // MARK: - Constants
  
  enum Metric {
    static let cornerRadius = 16.f
    
    static let barViewWidth = 30.f
    static let barViewHeight = 3.f
    static let barViewTopInset = 20.f
    
    static let labelsStackViewSpacing = 8.f
    static let labelsStackViewLeadingInset = 16.f
    static let labelsStackViewTopInset = 55.f
    
    static let changeLocationButtonCornerRadius = 24.f
    static let changeLocationButtonSize = 48.f
    static let changeLocationButtonTopInset = 40.f
    static let changeLocationButtonTrailingInset = 16.f
    static let changeLocationButtonFontSize = 12.f
  }
  
  // MARK: - Properties
  
  // MARK: - UI
  
  private let barView = UIView().then {
    $0.backgroundColor = .black
    $0.isUserInteractionEnabled = false
  }
  
  private let locationsLabel = UILabel().then {
    $0.text = "은평, 마포, 서대문"
    $0.font = .systemFont(ofSize: 16, weight: .bold)
  }
  
  private let numberOfCakeshopsLabel = UILabel().then {
    $0.text = "0개의 케이크샵"
    $0.font = .systemFont(ofSize: 14)
  }
  
  private lazy var labelsStack = UIStackView(
    arrangedSubviews: [locationsLabel, numberOfCakeshopsLabel]
  ).then {
    $0.alignment = .leading
    $0.axis = .vertical
    $0.spacing = Metric.labelsStackViewSpacing
  }
  
  private let changeLocationButton = UIButton().then {
    let attributedTitle = NSAttributedString(
      string: "지역\n변경",
      attributes: [.font: UIFont.systemFont(ofSize: Metric.changeLocationButtonFontSize, weight: .medium)]
    )
    $0.titleLabel?.numberOfLines = 0
    $0.setAttributedTitle(attributedTitle, for: .normal)
    $0.setTitleColor(.white, for: .normal)
    $0.backgroundColor = .black
    $0.layer.cornerRadius = Metric.changeLocationButtonCornerRadius
  }
  
  // MARK: - LifeCycle
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Public
  
  // MARK: - Private
  
  private func setup() {
    setupLayout()
    setupViewStyle()
    backgroundColor = .systemBlue
  }
  
  private func setupViewStyle() {
    layer.cornerRadius = Metric.cornerRadius
  }
  
  private func setupLayout() {
    addSubview(barView)
    barView.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.equalToSuperview().inset(Metric.barViewTopInset)
      $0.width.equalTo(Metric.barViewWidth)
      $0.height.equalTo(Metric.barViewHeight)
    }
    
    addSubview(labelsStack)
    labelsStack.snp.makeConstraints {
      $0.leading.equalToSuperview().inset(Metric.labelsStackViewLeadingInset)
      $0.top.equalToSuperview().inset(Metric.labelsStackViewTopInset)
    }
    
    addSubview(changeLocationButton)
    changeLocationButton.snp.makeConstraints {
      $0.width.height.equalTo(Metric.changeLocationButtonSize)
      $0.top.equalToSuperview().inset(Metric.changeLocationButtonTopInset)
      $0.trailing.equalToSuperview().inset(Metric.changeLocationButtonTrailingInset)
    }
  }
}
