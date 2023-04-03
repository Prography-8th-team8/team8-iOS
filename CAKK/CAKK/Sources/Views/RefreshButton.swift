//
//  RefreshButton.swift
//  CAKK
//
//  Created by Mason Kim on 2023/04/03.
//

import UIKit

final class RefreshButton: UIButton {
  
  // MARK: - Constants
  
  enum Metric {
    static let cornerRadius = 20.f
    
    static let refreshImageViewVerticalInset = 12.f
    static let refreshImageViewLeftInset = 16.f
    
    static let refreshLabelRightInset = 16.f
    static let refreshLabelSpacing = 8.f
  }
  
  // MARK: - Properties
  
  // MARK: - UI
  
  private let refreshImageView = UIImageView().then {
    $0.tintColor = .white
    $0.image = UIImage(systemName: "arrow.clockwise")
  }
  
  private let refreshLabel = UILabel().then {
    $0.text = "새로 고침"
    $0.textColor = .white
    $0.font = .preferredFont(forTextStyle: .body)
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
  }
  
  private func setupViewStyle() {
    backgroundColor = .black
    layer.cornerRadius = Metric.cornerRadius
  }
  
  private func setupLayout() {
    addSubview(refreshImageView)
    refreshImageView.snp.makeConstraints {
      $0.top.bottom.equalToSuperview().inset(Metric.refreshImageViewVerticalInset)
      $0.left.equalToSuperview().inset(Metric.refreshImageViewLeftInset)
    }
    
    addSubview(refreshLabel)
    refreshLabel.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.right.equalToSuperview().inset(Metric.refreshLabelRightInset)
      $0.left.equalTo(refreshImageView.snp.right).offset(Metric.refreshLabelSpacing)
    }
  }
}
