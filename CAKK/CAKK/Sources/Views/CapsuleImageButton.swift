//
//  CapsuleImageButton.swift
//  CAKK
//
//  Created by Mason Kim on 2023/04/03.
//

import UIKit

import SnapKit
import Then

class CapsuleImageButton: UIButton {
  
  // MARK: - Properties
  
  public var font: UIFont = .pretendard(size: 14, weight: .bold) {
    didSet {
      buttonLabel.font = font
    }
  }
  
  public override var tintColor: UIColor! {
    didSet {
      imageView?.tintColor = tintColor
      titleLabel?.textColor = tintColor
    }
  }
  
  public var borderColor: UIColor = .clear {
    didSet {
      layer.borderColor = borderColor.cgColor
    }
  }
  
  public var borderWidth: CGFloat = 0 {
    didSet {
      layer.borderWidth = borderWidth
    }
  }
  
  override var isEnabled: Bool {
    didSet {
      if isEnabled {
        enableButton()
      } else {
        disableButton()
      }
    }
  }
  
  override var isHighlighted: Bool {
    didSet {
      UIView.animate(withDuration: 0.1) {
        if self.isHighlighted {
          self.alpha = 0.3
        } else {
          self.alpha = 1
        }
      }
    }
  }
  
  private let spacing: CGFloat
  private let horizontalPadding: CGFloat
  private let verticalPadding: CGFloat
  private let imageSize: CGSize
  
  
  // MARK: - UI
  
  lazy var stackView = UIStackView().then {
    $0.spacing = self.spacing
    $0.isUserInteractionEnabled = false
  }
  
  let iconImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFit
    $0.tintColor = .white
  }
  
  lazy var buttonLabel = UILabel().then {
    $0.textColor = .white
    $0.font = self.font
    $0.textAlignment = .center
  }
  
  
  // MARK: - Initialization

  init(iconImage: UIImage,
       text: String,
       spacing: CGFloat = 4,
       horizontalPadding: CGFloat = 0,
       verticalPadding: CGFloat = 0,
       imageSize: CGSize = .init(width: 20, height: 20)) {
    self.spacing = spacing
    self.horizontalPadding = horizontalPadding
    self.verticalPadding = verticalPadding
    self.imageSize = imageSize

    super.init(frame: .zero)
    setup(iconImage, text)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  // MARK: - LifeCycle
  
  override func layoutSubviews() {
    super.layoutSubviews()
    configureCornerRadius()
  }

  // MARK: - Public
  
  // MARK: - Private
  
  private func setup(_ iconImage: UIImage?, _ text: String) {
    setupLayout()
    setupComponent(iconImage, text)
  }

  private func setupComponent(_ iconImage: UIImage?, _ text: String) {
    buttonLabel.text = text
    iconImageView.image = iconImage
  }
  
  private func setupLayout() {
    addSubview(stackView)
    stackView.snp.makeConstraints {
      $0.horizontalEdges.equalToSuperview().inset(self.horizontalPadding)
      $0.verticalEdges.equalToSuperview().inset(self.verticalPadding)
    }
    
    stackView.addArrangedSubview(iconImageView)
    stackView.addArrangedSubview(buttonLabel)
    
    iconImageView.snp.makeConstraints {
      $0.width.height.equalTo(self.imageSize)
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
