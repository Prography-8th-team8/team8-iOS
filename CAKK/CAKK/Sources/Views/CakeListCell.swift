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
  }
  
  // MARK: - Properties
  
  // MARK: - UI
  
  private let containerView = UIView().then {
    $0.layer.cornerRadius = 16
    $0.backgroundColor = .lightGray
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
    setupLayout()
  }
  
  private func setupLayout() {
    addSubview(containerView)
    containerView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(Metric.cellHorizontalInset)
      $0.top.bottom.equalToSuperview().inset(Metric.cellSpacing)
    }
  }
}
