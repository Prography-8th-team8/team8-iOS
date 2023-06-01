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
    static let fontSize = 12.f
    static let horizontalInset = 12.f
    static let refreshImageViewVerticalInset = 12.f
    static let refreshLabelSpacing = 4.f
  }
  
  // MARK: - Properties
  
  override var isEnabled: Bool {
    didSet {
      if isEnabled {
        enableButton()
      } else {
        disableButton()
      }
    }
  }
  
  
  // MARK: - UI
  
  private let iconImageView = UIImageView().then {
    $0.tintColor = .white
  }
  
  private let buttonLabel = UILabel().then {
    $0.text = "새로 고침"
    $0.textColor = .white
    $0.font = .pretendard(size: Metric.fontSize, weight: .bold)
  }
  
  // MARK: - LifeCycle

  init(iconImage: UIImage, text: String) {
    super.init(frame: .zero)
    setup(iconImage, text)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    configureCornerRadius()
  }

  // MARK: - Public
  
  // MARK: - Private
  
  private func setup(_ iconImage: UIImage, _ text: String) {
    setupLayout()
    setupViewStyle()
    setupComponent(iconImage, text)
  }
  
  private func setupViewStyle() {
    backgroundColor = R.color.black()
  }

  private func setupComponent(_ iconImage: UIImage, _ text: String) {
    buttonLabel.text = text
    iconImageView.image = iconImage
  }
  
  private func setupLayout() {
    addSubview(iconImageView)
    iconImageView.snp.makeConstraints {
      $0.top.bottom.equalToSuperview().inset(Metric.refreshImageViewVerticalInset)
      $0.left.equalToSuperview().inset(Metric.horizontalInset)
    }
    
    addSubview(buttonLabel)
    buttonLabel.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.right.equalToSuperview().inset(Metric.horizontalInset)
      $0.left.equalTo(iconImageView.snp.right).offset(Metric.refreshLabelSpacing)
    }
  }
  
  private func configureCornerRadius() {
    layer.cornerRadius = frame.height / 2
  }
  
  private func disableButton() {
    UIView.animate(withDuration: 0.3) {
      self.alpha = 0
    }
  }
  
  private func enableButton() {
    UIView.animate(withDuration: 0.3) {
      self.alpha = 1
    }
  }
}
