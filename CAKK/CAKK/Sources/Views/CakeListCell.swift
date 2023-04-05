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
    static let detailLocationLabelFontSize = 14.f

    static let containerViewCornerRadius = 16.f

    static let labelsStackViewWidth = 124.f
    static let labelsStackInset = 20.f
    static let labelsStackSpacing = 6.f

    static let detailLocationLabelTopOffset = 12.f
    static let detailLocationLabelTrailingInset = 20.f

    static let categoryStackViewSpacing = 8.f
    static let categoryStackViewInset = 20.f
  }
  
  // MARK: - Properties
  
  // MARK: - UI
  
  private let containerView = UIView().then {
    $0.layer.cornerRadius = Metric.containerViewCornerRadius
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
      make.height.equalTo(12)
    }
  }
  
  private let districtLocationLabel = UILabel().then {
    $0.text = "은평구"
    $0.font = .systemFont(ofSize: Metric.districtLocationLabelFontSize, weight: .bold)
  }
  
  private lazy var labelsStack = UIStackView(
    arrangedSubviews: [shopNameLabel, labelDividerView, districtLocationLabel]
  ).then {
    $0.alignment = .center
    $0.spacing = Metric.labelsStackSpacing
    $0.distribution = .equalSpacing
    $0.axis = .horizontal
  }

  private let detailLocationLabel = UILabel().then {
    $0.text = "서울 은평구 갈현로 36길 6-4 101호 동그리케이크"
    $0.font = .systemFont(ofSize: Metric.detailLocationLabelFontSize)
  }

  private let categoryStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = Metric.categoryStackViewSpacing
  }
  
  // MARK: - LifeCycle
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setup()

    ["레터링", "캐릭터", "기타"].forEach {
      addCategoryView(of: $0)
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Public

  func configreFirstCellTopPadding() {
    containerView.snp.updateConstraints {
      $0.top.equalToSuperview().inset(15)
    }
  }
  
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

    containerView.addSubview(detailLocationLabel)
    detailLocationLabel.snp.makeConstraints {
      $0.top.equalTo(labelsStack.snp.bottom).offset(Metric.detailLocationLabelTopOffset)
      $0.left.equalTo(labelsStack)
      $0.right.equalToSuperview().inset(Metric.detailLocationLabelTrailingInset)
    }

    containerView.addSubview(categoryStackView)
    categoryStackView.snp.makeConstraints {
      $0.left.bottom.equalToSuperview().inset(Metric.categoryStackViewInset)
    }
  }

  private func addCategoryView(of category: String) {
    let categoryView = UIView().then {
      $0.layer.cornerRadius = 14
      $0.layer.borderWidth = 1
      $0.layer.borderColor = UIColor.systemGray4.cgColor
    }

    let categoryLabel = UILabel().then {
      $0.font = .systemFont(ofSize: 12)
      $0.text = category
    }

    categoryView.addSubview(categoryLabel)
    categoryLabel.snp.makeConstraints {
      $0.top.bottom.equalToSuperview().inset(8)
      $0.leading.trailing.equalToSuperview().inset(10)
    }

    categoryStackView.addArrangedSubview(categoryView)
  }
}
