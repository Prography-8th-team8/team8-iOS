//
//  CakeListCell.swift
//  CAKK
//
//  Created by Mason Kim on 2023/04/03.
//

import UIKit
import SnapKit
import Then

final class CakeListCell: UITableViewCell {
  
  // MARK: - Constants
  
  enum Metric {
    static let cellSpacing = 5.f
    static let cellHorizontalInset = 16.f
    
    static let shopNameLabelFontSize = 16.f
    static let districtLocationLabelFontSize = 12.f
    
    static let labelsStackViewWidth = 124.f
    static let labelsStackInset = 20.f
    static let labelsStackSpacing = 6.f
  }
  
  // MARK: - Properties
  
  // MARK: - UI
  
  private let containerView = UIView().then {
    $0.layer.cornerRadius = 16
    $0.backgroundColor = .systemGray6
  }
  
  private let shopNameLabel = UILabel().then {
    $0.text = "000케이크샵"
    $0.font = .systemFont(ofSize: Metric.shopNameLabelFontSize, weight: .bold)
    $0.textColor = .black
  }
  
  private let labelDividerView = UIView().then {
    $0.backgroundColor = .lightGray
    $0.snp.makeConstraints { make in
      make.width.equalTo(1)
    }
  }
  
  private let districtLocationLabel = UILabel().then {
    $0.text = "은평구"
    $0.font = .systemFont(ofSize: Metric.districtLocationLabelFontSize, weight: .bold)
  }
  
  private lazy var labelsStack = UIStackView(
    arrangedSubviews: [shopNameLabel, labelDividerView, districtLocationLabel]
  ).then {
    $0.alignment = .fill
    $0.spacing = Metric.labelsStackSpacing
    $0.distribution = .equalSpacing
    $0.axis = .horizontal
  }
  
  // MARK: - LifeCycle
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Public
  
  // MARK: - Private
  
  private func setup() {
    setupStyle()
    setupLayout()
  }
  
  private func setupStyle() {
    selectionStyle = .none
  }
  
  private func setupLayout() {
    addSubview(containerView)
    containerView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(Metric.cellHorizontalInset)
      $0.top.bottom.equalToSuperview().inset(Metric.cellSpacing)
    }
    
    containerView.addSubview(labelsStack)
    labelsStack.snp.makeConstraints {
      $0.top.left.equalToSuperview().inset(Metric.labelsStackInset)
    }
  }
}
