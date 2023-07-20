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
  
  enum ImagePosition {
    case left, right
  }
  
  let insets: UIEdgeInsets
  var spacing: CGFloat = 0 {
    didSet {
      stackView.spacing = spacing
    }
  }
  
  var image: UIImage? {
    didSet {
      iconImageView.image = image
    }
  }
  let imagePosition: ImagePosition
  let imageSize: CGSize
  var imageColor: UIColor = .white {
    didSet {
      iconImageView.tintColor = imageColor
    }
  }
  
  var title: String = "" {
    didSet {
      textLabel.text = title
    }
  }
  var textColor: UIColor = .white {
    didSet {
      textLabel.textColor = textColor
    }
  }
  var font: UIFont = .pretendard(size: 14) {
    didSet {
      textLabel.font = font
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
  
  
  // MARK: - UI
  
  private lazy var stackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = self.spacing
    $0.isUserInteractionEnabled = false
  }
  
  lazy var iconImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFit
    $0.tintColor = tintColor
  }
  
  lazy var textLabel = UILabel().then {
    $0.textColor = .white
    $0.font = self.font
    $0.textAlignment = .center
  }
  
  private var oldFrame: CGRect = .zero
  
  
  // MARK: - Initialization
  
  init(imageSize: CGSize,
       imagePosition: ImagePosition = .left,
       insets: UIEdgeInsets = .zero) {
    self.imageSize = imageSize
    self.imagePosition = imagePosition
    self.insets = insets
    
    super.init(frame: .zero)
    setup()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  // MARK: - LifeCycle
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    if oldFrame != frame {
      configureCornerRadius()
      oldFrame = frame
    }
  }

  // MARK: - Public
  
  // MARK: - Private
  
  private func configureCornerRadius() {
    layer.cornerRadius = frame.height / 2
  }
  
  @objc
  private func highlight() {
    alpha = 0.2
  }
  
  @objc
  private func unhighlight() {
    UIView.animate(withDuration: 0.2) {
      self.alpha = 1.0
    }
  }
}


// MARK: - UI & Layout

extension CapsuleImageButton {
  
  private func setup() {
    setupLayout()
  }
  
  private func setupLayout() {
    addSubview(stackView)
    stackView.snp.makeConstraints {
      $0.top.equalToSuperview().inset(insets.top)
      $0.left.equalToSuperview().inset(insets.left)
      $0.right.equalToSuperview().inset(insets.right)
      $0.bottom.equalToSuperview().inset(insets.bottom)
    }
    
    switch imagePosition {
    case .left:
      stackView.addArrangedSubview(iconImageView)
      stackView.addArrangedSubview(textLabel)
    case .right:
      stackView.addArrangedSubview(textLabel)
      stackView.addArrangedSubview(iconImageView)
    }
    
    iconImageView.snp.makeConstraints {
      $0.width.equalTo(imageSize.width)
      $0.height.equalTo(imageSize.height)
    }
  }
}
