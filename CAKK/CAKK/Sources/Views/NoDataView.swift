//
//  NoDataView.swift
//  CAKK
//
//  Created by 이승기 on 2023/05/27.
//

import UIKit

import Then
import SnapKit

class NoDataView: UIView {
  
  // MARK: - Constants
  
  enum Metrics {
    static let imageSize = 140.f
    static let imagePadding = 10.f
  }
  
  
  // MARK: - Properties
  
  private var title: String
  private var subTitle: String
  
  
  // MARK: - UI
  
  private lazy var stackView = UIStackView(
    arrangedSubviews: [imageView, titleLabel, subTitleLabel]
  ).then {
    $0.spacing = 8
    $0.axis = .vertical
    $0.alignment = .center
  }
  
  private let imageView = UIImageView().then {
    $0.image = R.image.nodata()?.withAlignmentRectInsets(.init(common: -Metrics.imagePadding))
    $0.contentMode = .scaleAspectFit
  }
  
  private let titleLabel = UILabel().then {
    $0.font = .pretendard(size: 15, weight: .bold)
    $0.textColor = .black
  }
  
  private let subTitleLabel = UILabel().then {
    $0.font = .pretendard(size: 13)
    $0.textColor = .black.withAlphaComponent(0.8)
  }
  
  override var intrinsicContentSize: CGSize {
    return stackView.intrinsicContentSize
  }
  
  
  // MARK: - LifeCycle
  
  init(title: String = "", subTitle: String = "") {
    self.title = title
    self.subTitle = subTitle
    super.init(frame: .zero)
    
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  // MARK: - Private
  
  // Setups
  private func setup() {
    setupLayout()
    setupView()
  }
  
  // Setup Layouts
  private func setupLayout() {
    setupStackViewLayout()
    setupImageLayout()
  }

  private func setupStackViewLayout() {
    addSubview(stackView)
    stackView.snp.makeConstraints {
      $0.center.equalToSuperview()
    }
  }
  
  private func setupImageLayout() {
    imageView.snp.makeConstraints {
      $0.width.height.equalTo(Metrics.imageSize)
    }
  }
  
  private func setupView() {
    setupTitleLabel()
    setupSubTitleLabel()
  }
  
  private func setupTitleLabel() {
    titleLabel.text = title
  }
  
  private func setupSubTitleLabel() {
    subTitleLabel.text = subTitle
  }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct NoDataView_Preview: PreviewProvider {
  static var previews: some View {
    UIViewPreview {
      NoDataView(
        title: "표시할 데이터가 없어요!",
        subTitle: "빠른 시일내에 준비하겠습니다."
      )
    }
    .previewLayout(.sizeThatFits)
  }
}
#endif
