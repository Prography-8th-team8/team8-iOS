//
//  FilterButton.swift
//  CAKK
//
//  Created by 이승기 on 2023/06/23.
//

import UIKit

import Then
import SnapKit

import BadgeSwift

class FilterButton: UIButton {
  
  
  // MARK: - Constants
  
  enum Metric {
    static let cornerRadius = 14.f
    static let borderWidth = 1.f
    static let imageInset = 10.f
    
    static let badgeSize = 16.f
    static let badgeBorderWidth = 1.f
  }
  
  // MARK: - Properties
  
  private var badgeCount: Int = 0
  
  override var isHighlighted: Bool {
    didSet {
      if isHighlighted {
        alpha = 0.3
      } else {
        alpha = 1
      }
    }
  }
  
  
  // MARK: - UI
  
  private let badge = BadgeSwift().then {
    $0.borderWidth = Metric.badgeBorderWidth
    $0.borderColor = .white
    $0.font = .pretendard(size: 10, weight: .bold)
    $0.textColor = .white
  }
  
  
  // MARK: - Initializers
  
  init(initialBadgeCount: Int) {
    badgeCount = initialBadgeCount
    super.init(frame: .zero)
    
    setup()
    setBadge(count: initialBadgeCount)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  // MARK: - Setup
  
  private func setup() {
    setupLayout()
    setupView()
  }
  
  // Setup Layout
  private func setupLayout() {
    addSubview(badge)
    badge.snp.makeConstraints {
      $0.top.trailing.equalToSuperview().inset(-4)
    }
  }
  
  private func setupBadgeLayout() {
    addSubview(badge)
  }
  
  // Setup View
  private func setupView() {
    setupBaseView()
  }
  
  private func setupBaseView() {
    setImage(R.image.filter(), for: .normal)
    imageEdgeInsets = .init(common: Metric.imageInset)
    layer.cornerRadius = Metric.cornerRadius
    layer.borderWidth = Metric.borderWidth
    layer.borderColor = R.color.gray_20()!.cgColor
    tintColor = R.color.black()
    clipsToBounds = false
  }
  
  
  // MARK: - Public
  
  public func setBadge(count: Int) {
    if count == 0 {
      badge.isHidden = true
      layer.borderColor = R.color.gray_20()!.cgColor
      backgroundColor = R.color.white()
      tintColor = R.color.black()
    } else {
      badge.isHidden = false
      layer.borderColor = UIColor.clear.cgColor
      backgroundColor = R.color.black()
      tintColor = R.color.white()
      
      badge.text = count.description
    }
  }
}
