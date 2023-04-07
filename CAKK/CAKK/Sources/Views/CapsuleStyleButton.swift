//
//  CapsuleStyleButton.swift
//  CAKK
//
//  Created by Mason Kim on 2023/04/03.
//

import UIKit
import SnapKit
import Then

final class CapsuleStyleButton: UIButton {
  
  // MARK: - Constants
  
  enum Metric {
    static let cornerRadius = 22.f
    
    static let refreshImageViewVerticalInset = 12.f
    static let refreshImageViewLeftInset = 16.f
    
    static let refreshLabelRightInset = 16.f
    static let refreshLabelSpacing = 8.f
  }
  
  // MARK: - Properties
  
  // MARK: - UI
  
  private let iconImageView = UIImageView().then {
    $0.tintColor = .white
  }
  
  private let buttonLabel = UILabel().then {
    $0.text = "새로 고침"
    $0.textColor = .white
    $0.font = .preferredFont(forTextStyle: .body)
  }
  
  // MARK: - LifeCycle

  init(iconImage: UIImage, text: String) {
    super.init(frame: .zero)
    setup(iconImage, text)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Public
  
  // MARK: - Private
  
  private func setup(_ iconImage: UIImage, _ text: String) {
    setupLayout()
    setupViewStyle()
    setupComponent(iconImage, text)
  }
  
  private func setupViewStyle() {
    backgroundColor = .black
    layer.cornerRadius = Metric.cornerRadius
  }

  private func setupComponent(_ iconImage: UIImage, _ text: String) {
    buttonLabel.text = text
    iconImageView.image = iconImage
  }
  
  private func setupLayout() {
    addSubview(iconImageView)
    iconImageView.snp.makeConstraints {
      $0.top.bottom.equalToSuperview().inset(Metric.refreshImageViewVerticalInset)
      $0.left.equalToSuperview().inset(Metric.refreshImageViewLeftInset)
    }
    
    addSubview(buttonLabel)
    buttonLabel.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.right.equalToSuperview().inset(Metric.refreshLabelRightInset)
      $0.left.equalTo(iconImageView.snp.right).offset(Metric.refreshLabelSpacing)
    }
  }
}
