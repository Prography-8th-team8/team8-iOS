//
//  RegionPickerCollectionCell.swift
//  CAKK
//
//  Created by 이승기 on 2023/05/05.
//

import UIKit

import SnapKit
import Then

class RegionPickerCollectionCell: UICollectionViewCell {
  
  // MARK: - Constants
  
  static let identifier = String(describing: RegionPickerCollectionCell.self)
  
  enum Metric {
    static let verticalPadding = 24.f
    static let horizontalPadding = 20.f
    
    static let cornerRadius = 24.f
    static let titleFontSize = 14.f
    static let numberOfRegionsFontSize = 20.f
  }
  
  
  // MARK: - Properties
  
  private var title: String = ""
  private var numberOfRegions: Int = 0
  private var color: UIColor = R.color.fuschia100()!
  
  
  // MARK: - Views
  
  private let titleLabel = UILabel().then {
    $0.font = .pretendard(size: Metric.titleFontSize, weight: .regular)
    $0.textColor = .black
    $0.numberOfLines = 2
    $0.textAlignment = .left
  }
  
  private let numberOfRegionsLabel = UILabel().then {
    $0.font = .pretendard(size: Metric.numberOfRegionsFontSize, weight: .bold)
    $0.textColor = .black
    $0.textAlignment = .right
  }
  
  
  // MARK: - LifeCycles
  
  init() {
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  // MARK: - Publics
  
  public func configure(title: String, numberOfRegions: Int, color: UIColor) {
    self.title = title
    self.numberOfRegions = numberOfRegions
    self.color = color
    
    configureView()
  }
  
  
  // MARK: - Privates
  
  private func setup() {
    setupLayout()
    configureView()
  }
  
  private func setupLayout() {
    setupTitleLabelLayout()
    setupNumberOfRegionsLabelLayout()
  }
  
  private func setupTitleLabelLayout() {
    addSubview(titleLabel)
    titleLabel.snp.makeConstraints {
      $0.top.equalToSuperview().inset(Metric.verticalPadding)
      $0.leading.trailing.equalToSuperview().inset(Metric.horizontalPadding)
    }
  }
  
  private func setupNumberOfRegionsLabelLayout() {
    addSubview(numberOfRegionsLabel)
    numberOfRegionsLabel.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(Metric.horizontalPadding)
      $0.bottom.equalToSuperview().inset(Metric.verticalPadding)
    }
  }
  
  private func configureView() {
    configureBaseView()
    configureTitleLabel()
    configureNumberOfRegionsLabel()
  }
  
  private func configureBaseView() {
    backgroundColor = .clear
    
    contentView.backgroundColor = color
    contentView.layer.borderWidth = 2
    contentView.layer.borderColor = color.cgColor
    contentView.layer.cornerRadius = Metric.cornerRadius
  }
  
  private func configureTitleLabel() {
    titleLabel.text = title
  }
  
  private func configureNumberOfRegionsLabel() {
    numberOfRegionsLabel.text = "\(numberOfRegions)개"
  }
}


// MARK: - Preview

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct RegionPickerPreview: PreviewProvider {
  static var previews: some View {
    UIViewPreview {
      let regionPicker = RegionPickerCollectionCell()
      regionPicker.configure(
        title: "도봉 강북 성북 노원",
        numberOfRegions: 43,
        color: UIColor(hex: 0x2448FF).withAlphaComponent(0.1))
      return regionPicker
    }
    .frame(width: 170, height: 120)
    .previewLayout(.sizeThatFits)
  }
}
#endif
