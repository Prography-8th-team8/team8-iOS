//
//  BottomSheetView.swift
//  CAKK
//
//  Created by Mason Kim on 2023/04/03.
//

import UIKit

final class BottonSheetView: UIView {
  
  // MARK: - Constants
  
  enum Metric {
    static let cornerRadius = 16.f
  }
  
  // MARK: - Properties
  
  // MARK: - UI
  
  private let barView = UIView().then {
    $0.backgroundColor = .darkGray
    $0.isUserInteractionEnabled = false
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
    backgroundColor = .systemBlue
  }
  
  private func setupViewStyle() {
    layer.cornerRadius = Metric.cornerRadius
  }
  
  private func setupLayout() {
    addSubview(barView)
//    barView.snp.makeConstraints {
//
//    }
  }
}
