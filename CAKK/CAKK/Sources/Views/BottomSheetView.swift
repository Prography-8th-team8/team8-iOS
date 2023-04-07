//
//  BottomSheetView.swift
//  CAKK
//
//  Created by Mason Kim on 2023/04/03.
//

import UIKit
import SnapKit
import Then

final class BottonSheetView: UIView {
  
  // MARK: - Constants
  
  enum Metric {
    static let cornerRadius = 16.f
    
    static let headerViewHeight = 124.f
    
    static let barViewSize = CGSize(width: 30.f, height: 3.f)
    static let barViewTopInset = 20.f
    
    static let locationLabelFontSize = 16.f
    static let numberOfCakeshopsLabelFontSize = 14.f
    
    static let labelsStackViewSpacing = 8.f
    static let labelsStackViewLeadingInset = 16.f
    static let labelsStackViewTopInset = 55.f
    
    static let changeLocationButtonCornerRadius = 24.f
    static let changeLocationButtonSize = CGSize(width: 48.f, height: 48.f)
    static let changeLocationButtonTopInset = 40.f
    static let changeLocationButtonTrailingInset = 16.f
    static let changeLocationButtonFontSize = 12.f
    
    static let cakeTableViewItemSpacing = 10.f
  }
  
  // MARK: - Properties
  
  // MARK: - UI
  
  let cakeTableView = UITableView(frame: .zero, style: .plain).then {
    $0.bounces = false
    $0.registerCell(cellClass: CakeListCell.self)
    $0.separatorStyle = .none
  }
  
  private let headerView = UIView()
  
  private let barView = UIView().then {
    $0.backgroundColor = .black
    $0.isUserInteractionEnabled = false
  }
  
  private let locationsLabel = UILabel().then {
    $0.text = "은평, 마포, 서대문"
    $0.font = .systemFont(ofSize: Metric.locationLabelFontSize, weight: .bold)
  }
  
  private let numberOfCakeshopsLabel = UILabel().then {
    $0.text = "0개의 케이크샵"
    $0.font = .systemFont(ofSize: Metric.numberOfCakeshopsLabelFontSize)
  }
  
  private lazy var labelsStack = UIStackView(
    arrangedSubviews: [locationsLabel, numberOfCakeshopsLabel]
  ).then {
    $0.alignment = .leading
    $0.axis = .vertical
    $0.spacing = Metric.labelsStackViewSpacing
  }
  
  private let changeLocationButton = UIButton().then {
    let attributedTitle = NSAttributedString(
      string: "지역\n변경",
      attributes: [.font: UIFont.systemFont(ofSize: Metric.changeLocationButtonFontSize, weight: .medium)]
    )
    $0.titleLabel?.numberOfLines = 0
    $0.setAttributedTitle(attributedTitle, for: .normal)
    $0.setTitleColor(.white, for: .normal)
    $0.backgroundColor = .black
    $0.layer.cornerRadius = Metric.changeLocationButtonCornerRadius
  }
  
  private let lineView = UIView().then {
    $0.backgroundColor = .lightGray
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
    backgroundColor = .white
    layer.cornerRadius = Metric.cornerRadius
  }
  
  private func setupLayout() {
    addSubview(headerView)
    headerView.snp.makeConstraints {
      $0.top.leading.trailing.equalToSuperview()
      $0.height.equalTo(Metric.headerViewHeight)
    }
    
    headerView.addSubview(barView)
    barView.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.equalToSuperview().inset(Metric.barViewTopInset)
      $0.size.equalTo(Metric.barViewSize)
    }
    
    headerView.addSubview(labelsStack)
    labelsStack.snp.makeConstraints {
      $0.leading.equalToSuperview().inset(Metric.labelsStackViewLeadingInset)
      $0.top.equalToSuperview().inset(Metric.labelsStackViewTopInset)
    }
    
    headerView.addSubview(changeLocationButton)
    changeLocationButton.snp.makeConstraints {
      $0.size.equalTo(Metric.changeLocationButtonSize)
      $0.top.equalToSuperview().inset(Metric.changeLocationButtonTopInset)
      $0.trailing.equalToSuperview().inset(Metric.changeLocationButtonTrailingInset)
    }
    
    addSubview(cakeTableView)
    cakeTableView.snp.makeConstraints {
      $0.top.equalTo(headerView.snp.bottom)
      $0.leading.trailing.equalToSuperview()
      $0.bottom.equalToSuperview()
    }
    
    addSubview(lineView)
    lineView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.height.equalTo(1)
      $0.bottom.equalTo(cakeTableView.snp.top)
    }
  }
}
