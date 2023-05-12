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
  
  // MARK: - UI
  
  private let cakkView = CakkView()
  
  
  // MARK: - Properties
  
  private var title: String = ""
  private var numberOfRegions: Int = 0
  private var color = UIColor(hex: 0xE9EDFF)
  private var borderColor = UIColor(hex: 0xD5D9E9)
  
  
  // MARK: - Views
  
  public let titleLabel = UILabel().then {
    $0.font = .pretendard(size: Metric.titleFontSize, weight: .regular)
    $0.textColor = .black
    $0.numberOfLines = 2
    $0.textAlignment = .left
  }
  
  public let numberOfRegionsLabel = UILabel().then {
    $0.font = .pretendard(size: Metric.numberOfRegionsFontSize, weight: .bold)
    $0.textColor = .black
    $0.textAlignment = .right
  }
  
  
  // MARK: - LifeCycles
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  // MARK: - Publics
  
  public func configure(_ item: DistrictSection) {
    self.title = item.sectionName
    self.numberOfRegions = item.count
    self.color = item.color
    self.borderColor = item.borderColor
    
    configureView()
  }
  
  
  // MARK: - Privates
  
  private func setup() {
    setupLayout()
    configureView()
  }
  
  private func setupLayout() {
    setupCakkViewLayout()
    setupTitleLabelLayout()
    setupNumberOfRegionsLabelLayout()
  }
  
  private func setupCakkViewLayout() {
    addSubview(cakkView)
    cakkView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }
  
  private func setupTitleLabelLayout() {
    cakkView.addSubview(titleLabel)
    titleLabel.snp.makeConstraints {
      $0.top.equalToSuperview().inset(Metric.verticalPadding)
      $0.leading.trailing.equalToSuperview().inset(Metric.horizontalPadding)
    }
  }
  
  private func setupNumberOfRegionsLabelLayout() {
    cakkView.addSubview(numberOfRegionsLabel)
    numberOfRegionsLabel.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(Metric.horizontalPadding)
      $0.bottom.equalToSuperview().inset(Metric.verticalPadding)
    }
  }
  
  private func configureView() {
    configureCakkView()
    configureTitleLabel()
    configureNumberOfRegionsLabel()
  }
  
  private func configureCakkView() {
    backgroundColor = .clear
    
    cakkView.borderColor = borderColor
    cakkView.backgroundColor = color
    cakkView.cornerRadius = Metric.cornerRadius
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
        .init(
          count: 43,
          color: UIColor(hex: 0xE9EDFF),
          borderColor: UIColor(hex: 0xD5D9E9),
          districts: [.dobong, .gangbuk, .seongbuk, .nowon])
      )
      
      return regionPicker
    }
    .frame(width: 170, height: 120)
    .previewLayout(.sizeThatFits)
  }
}
#endif
