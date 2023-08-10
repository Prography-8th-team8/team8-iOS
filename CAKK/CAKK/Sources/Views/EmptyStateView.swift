//
//  EmptyStateView.swift
//  CAKK
//
//  Created by 이승기 on 2023/06/09.
//

import UIKit

import SnapKit

final class EmptyStateView: UIView {
  
  // MARK: - Constants
  
  enum Metric {
    static let imageSize = 120.f
  }
  
  
  // MARK: - Properties
  
  let title: String?
  let subTitle: String?
  
  
  // MARK: - UI
  
  private let stackView = UIStackView().then {
    $0.alignment = .center
    $0.distribution = .fill
    $0.axis = .vertical
  }
  
  private let imageView = UIImageView().then {
    $0.image = R.image.nodata()
    $0.contentMode = .scaleAspectFit
  }
  
  private lazy var titleLabel = UILabel().then {
    $0.text = self.title
    $0.font = .pretendard(size: 13, weight: .bold)
    $0.textColor = R.color.black()
    $0.textAlignment = .center
  }
  
  private lazy var subTitleLabel = UILabel().then {
    $0.text = self.subTitle
    $0.font = .pretendard(size: 12)
    $0.textColor = R.color.black()
    $0.alpha = 0.8
    $0.textAlignment = .center
  }
  
  
  // MARK: - Initialization
  
  init(title: String? = "",
       subTitle: String? = "") {
    self.title = title
    self.subTitle = subTitle
    super.init(frame: .zero)
    
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  // MARK: - Private
  
  private func setup() {
    setupLayout()
    setupView()
  }
  
  private func setupLayout() {
    setupStackViewLayout()
    setupImageViewLayout()
    setupTitleLabelLayout()
    setupSubTitleLabelLayout()
  }
  
  private func setupStackViewLayout() {
    addSubview(stackView)
    stackView.snp.makeConstraints {
      $0.center.equalToSuperview()
    }
  }
  
  private func setupImageViewLayout() {
    stackView.addArrangedSubview(imageView)
    stackView.setCustomSpacing(18, after: imageView)
    imageView.snp.makeConstraints {
      $0.width.height.equalTo(Metric.imageSize)
    }
  }
  
  private func setupTitleLabelLayout() {
    if title != nil {
      stackView.addArrangedSubview(titleLabel)
      stackView.setCustomSpacing(8, after: titleLabel)
    }
  }
  
  private func setupSubTitleLabelLayout() {
    if subTitle != nil {
      stackView.addArrangedSubview(subTitleLabel)
    }
  }
  
  private func setupView() {
    setupTitleLabel()
    setupSubTitleLabel()
  }
  
  private func setupTitleLabel() {
    if let title {
      titleLabel.text = title
    }
  }
  
  private func setupSubTitleLabel() {
    if let subTitle {
      subTitleLabel.text = subTitle
    }
  }
}


// MARK: - Preview

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct EmptyStateView_Previews: PreviewProvider {
  static var previews: some View {
    UIViewPreview {
      EmptyStateView(
        title: "표시할 데이터가 없어요!",
        subTitle: "빠른 시일내에 준비하겠습니다.")
    }
  }
}
#endif
