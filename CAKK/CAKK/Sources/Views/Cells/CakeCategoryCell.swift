//
//  CakeCategoryCell.swift
//  CAKK
//
//  Created by 이승기 on 2023/06/23.
//

import UIKit

import Combine

import SnapKit
import Then

class CakeCategoryCell: UICollectionViewCell {
  
  // MARK: - Constants
  
  enum Metric {
    static let height = 34.f
    static let spacing = 4.f
    
    static let horizontalPadding = 12.f
    static let verticalPadding = 8.f
    
    static let iconSize = 16.f
    static let titleFontSize = 14.f
  }
  
  
  // MARK: - Properties
  
  private var cancellableBag = Set<AnyCancellable>()
  
  public var cakeCategory: CakeCategory?
  public var isChipSelected: Bool = false {
    didSet {
      if isChipSelected {
        setSelected()
      } else {
        setUnselected()
      }
    }
  }
  
  override var isHighlighted: Bool {
    didSet {
      if isHighlighted {
        alpha = 0.2
      } else {
        UIView.animate(withDuration: 0.2) {
          self.alpha = 1
        }
      }
    }
  }
  
  
  // MARK: - UI
  
  private lazy var stackView = UIStackView(arrangedSubviews: [iconImageView, titleLabel]).then {
    $0.axis = .horizontal
    $0.spacing = Metric.spacing
  }
  
  private let iconImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFit
  }
  
  private let titleLabel = UILabel().then {
    $0.font = .pretendard(size: 14, weight: .bold)
    $0.textColor = R.color.black()
  }
  
  
  // MARK: - Initialization
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  // MARK: - Public
  
  public func configure(cakeCategory: CakeCategory, isSelected: Bool) {
    self.cakeCategory = cakeCategory
    
    titleLabel.text = cakeCategory.localizedString
    isChipSelected = isSelected
    
    // configure image
    if let iconImage = cakeCategory.icon {
      iconImageView.image = cakeCategory.icon
    } else {
      iconImageView.removeFromSuperview()
    }
  }
  
  
  // MARK: - Private
  
  private func setSelected() {
    if let cakeCategory {
      titleLabel.textColor = cakeCategory.color
      contentView.backgroundColor = cakeCategory.color.withAlphaComponent(0.2)
      contentView.layer.borderWidth = 0
    }
  }
  
  private func setUnselected() {
    titleLabel.textColor = R.color.black()
    contentView.backgroundColor = .white
    contentView.layer.borderWidth = 1
  }
}


// MARK: - UI & Layout

extension CakeCategoryCell {

  private func setup() {
    setupLayout()
    setupView()
  }
  
  private func setupLayout() {
    setupStackViewLayout()
    setupIconImageLayout()
  }
  
  private func setupStackViewLayout() {
    contentView.addSubview(stackView)
    stackView.snp.makeConstraints {
      $0.horizontalEdges.equalToSuperview().inset(Metric.horizontalPadding)
      $0.verticalEdges.equalToSuperview().inset(Metric.verticalPadding)
    }
  }
  
  private func setupIconImageLayout() {
    iconImageView.snp.makeConstraints {
      $0.size.equalTo(Metric.iconSize)
    }
  }
  
  private func setupView() {
    setupContentView()
  }
  
  private func setupContentView() {
    contentView.layer.cornerRadius = Metric.height / 2
    contentView.layer.borderWidth = 1
    contentView.layer.borderColor = R.color.gray_20()!.cgColor
  }
}
