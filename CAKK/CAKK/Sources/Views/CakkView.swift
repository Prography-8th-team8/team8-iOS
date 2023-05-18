//
//  CakkView.swift
//  CAKK
//
//  Created by 이승기 on 2023/05/12.
//

import UIKit

import SnapKit

class CakkView: UIView {
  
  // MARK: - Constants
  
  enum Metric {
    static let topPadding = 1.f
    static let horizontalPadding = 2.f
    static let bottomPadding = 4.f
  }
  
  
  // MARK: - Properties
  
  public var cornerRadius: CGFloat = 0 {
    didSet {
      configureCornerRadius()
    }
  }
  public var borderColor: UIColor? {
    didSet {
      borderView.backgroundColor = borderColor
    }
  }
  public override var backgroundColor: UIColor? {
    didSet {
      contentView.backgroundColor = backgroundColor
    }
  }
  
  
  // MARK: - UI
  
  private let borderView = UIView()
  private let contentView = UIView()
  
  
  // MARK: - LiefeCycle
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  // MARK: - Setup
  
  private func setup() {
    setupLayout()
  }
  
  private func setupLayout() {
    borderViewLayout()
    setupContentViewLayout()
  }
  
  private func borderViewLayout() {
    addSubview(borderView)
    borderView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }
  
  private func setupContentViewLayout() {
    borderView.addSubview(contentView)
    contentView.snp.makeConstraints {
      $0.top.equalToSuperview().inset(Metric.topPadding)
      $0.leading.trailing.equalToSuperview().inset(Metric.horizontalPadding)
      $0.bottom.equalToSuperview().inset(Metric.bottomPadding)
    }
  }
  
  // MARK: - Privates
  
  private func configureCornerRadius() {
    layer.cornerRadius = cornerRadius
    borderView.layer.cornerRadius = cornerRadius
    contentView.layer.cornerRadius = cornerRadius - Metric.topPadding
  }
}


#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct CakkViewPreview: PreviewProvider {
  static var previews: some View {
    UIViewPreview {
      let view = CakkView()
      view.borderColor = .systemTeal
      view.backgroundColor = .systemPink
      view.cornerRadius = 24
      return view
    }
    .frame(width: 170, height: 120)
    .padding()
    .previewLayout(.sizeThatFits)
  }
}
#endif
