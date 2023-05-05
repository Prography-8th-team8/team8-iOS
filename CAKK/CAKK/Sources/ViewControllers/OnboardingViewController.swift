//
//  OnboardingViewController.swift
//  CAKK
//
//  Created by 이승기 on 2023/05/06.
//

import UIKit

import SnapKit
import Then

class OnboardingViewController: UIViewController {
  
  // MARK: - Constants
  
  enum Metric {
    static let padding = 16.f
    static let topPadding = 44.f
    
    static let descriptionLabelTopPadding = 12.f
  }
  
  // MARK: - Properties
  
  // MARK: - UI
  
  let titleLabel = UILabel().then {
    $0.text = "내게 맞는 케이크샵은 어디에 있을까요?"
    $0.font = .pretendard(size: 20, weight: .bold)
    $0.textColor = .black
    $0.textAlignment = .left
  }
  
  let descriptionLabel = UILabel().then {
    $0.text = "서울의 케이샵을 지역별로 정리했어요."
    $0.font = .pretendard(size: 16)
    $0.textColor = .black.withAlphaComponent(0.6)
    $0.textAlignment = .left
  }
  
  // MARK: - LifeCycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }
  
  // MARK: - Public
  
  // MARK: - Private
  
  private func setup() {
    setupLayout()
  }
  
  private func setupLayout() {
    setupTitleLabelLayout()
    setupDescriptionLabelLayout()
  }
  
  private func setupTitleLabelLayout() {
    view.addSubview(titleLabel)
    titleLabel.snp.makeConstraints {
      $0.top.equalToSuperview().inset(Metric.topPadding)
      $0.leading.trailing.equalToSuperview().inset(Metric.padding)
    }
  }
  
  private func setupDescriptionLabelLayout() {
    view.addSubview(descriptionLabel)
    descriptionLabel.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(Metric.descriptionLabelTopPadding)
      $0.leading.trailing.equalToSuperview().inset(Metric.padding)
    }
  }
}


#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct OnboardingViewControllerPreview: PreviewProvider {
  static var previews: some View {
    OnboardingViewController().toPreview()
  }
}
#endif
