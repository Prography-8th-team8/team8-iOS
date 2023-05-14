//
//  DetailSectionTitleView.swift
//  CAKK
//
//  Created by Mason Kim on 2023/05/13.
//

import UIKit

import SnapKit
import Then

final class DetailSectionTitleView: UIView {
  
  // MARK: - UI
  
  private let keywordTitleLabel = UILabel().then {
    $0.font = .pretendard(size: 20, weight: .bold)
    $0.text = "-"
  }
  
  // MARK: - LifeCycle
  
  init(title: String, topMargin: CGFloat = 40, bottomMargin: CGFloat = 16) {
    super.init(frame: .zero)
    setup(title: title, topMargin: topMargin, bottomMargin: bottomMargin)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Public
  
  // MARK: - Private
  
  private func setup(title: String,
                     topMargin: CGFloat,
                     bottomMargin: CGFloat) {
    keywordTitleLabel.text = title
    
    addSubview(keywordTitleLabel)
    keywordTitleLabel.snp.makeConstraints {
      $0.top.equalToSuperview().inset(topMargin)
      $0.bottom.equalToSuperview().inset(bottomMargin)
      $0.leading.equalToSuperview().inset(16)
      $0.trailing.equalToSuperview()
    }
  }
}
