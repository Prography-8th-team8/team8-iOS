//
//  FloatingPanelNavigationBar.swift
//  CAKK
//
//  Created by 이승기 on 2023/07/13.
//

import UIKit

import SnapKit
import Then

import Combine
import CombineCocoa

class FloatingPanelNavigationBar: UIView {
  
  // MARK: - Constants
  
  enum Metric {
    static let horizontalPadding = 16.f
    static let buttonSize = 24.f
    static let buttonImageInset = 2.f
    
    static let dividerHeight = 1.f
  }
  
  
  // MARK: - Properties
  
  private var cancellableBag = Set<AnyCancellable>()
  public var title: String {
    didSet {
      titleLabel.text = title
    }
  }
  public var leadingButtonHandler: (() -> Void)?
  
  
  // MARK: - UI
  
  private let titleLabel = UILabel().then {
    $0.font = .pretendard(size: 17, weight: .bold)
    $0.textColor = R.color.black()
  }
  
  private let leadingButton = UIButton().then {
    $0.setImage(R.image.chevron_down()!, for: .normal)
    $0.tintColor = R.color.black()
    $0.imageEdgeInsets = .init(common: Metric.buttonImageInset)
  }
  
  private let divider = UIView().then {
    $0.backgroundColor = R.color.gray_10()
  }
  
  
  // MARK: - Initializers
  
  init(title: String) {
    self.title = title
    super.init(frame: .zero)
    
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}


// MARK: - UI & Layout

extension FloatingPanelNavigationBar {
  
  private func setup() {
    setupLayout()
    setupView()
  }
  
  private func setupLayout() {
    setupTitleLabelLayout()
    setupLeadingButtonLayout()
    setupDividerLayout()
  }
  
  private func setupTitleLabelLayout() {
    addSubview(titleLabel)
    titleLabel.snp.makeConstraints {
      $0.center.equalToSuperview()
    }
  }
  
  private func setupLeadingButtonLayout() {
    addSubview(leadingButton)
    leadingButton.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.leading.equalToSuperview().inset(Metric.horizontalPadding)
      $0.size.equalTo(Metric.buttonSize)
    }
  }
  
  private func setupDividerLayout() {
    addSubview(divider)
    divider.snp.makeConstraints {
      $0.leading.trailing.bottom.equalToSuperview()
      $0.height.equalTo(Metric.dividerHeight)
    }
  }
  
  private func setupView() {
    setupBaseView()
    setupTitleLabel()
    setupLeadingButton()
  }
  
  private func setupBaseView() {
    backgroundColor = R.color.white()
  }
  
  private func setupTitleLabel() {
    titleLabel.text = title
  }
  
  private func setupLeadingButton() {
    leadingButton
      .tapPublisher
      .sink { [weak self] in
        self?.leadingButtonHandler?()
      }
      .store(in: &cancellableBag)
  }
}


// MARK: - Preview

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct FloatingPanelNavigationBar_Preview: PreviewProvider {
  static var previews: some View {
    VStack {
      UIViewPreview {
        FloatingPanelNavigationBar(title: "title")
      }
      .frame(height: 44)
      
      Spacer()
    }
    .background(Color.gray.ignoresSafeArea())
  }
}
#endif
