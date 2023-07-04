//
//  UnderlineSegmentedControl.swift
//  CAKK
//
//  Created by Mason Kim on 2023/07/04.
//

import UIKit

import Combine

import SnapKit
import Then


final class UnderlineSegmentedControl: UISegmentedControl {
  
  
  // MARK: - Properties
  
  private var cancellables = Set<AnyCancellable>()
  
  
  // MARK: - UI Components
  
  private let underlineView = UIView().then { view in
    view.backgroundColor = .black
  }
  
  private var leadingConstraints: Constraint?
  
  
  // MARK: - Initialization
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  override init(items: [Any]?) {
    super.init(items: items)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError()
  }
  
  
  // MARK: - Private Methods
  
  private func removeBackgroundAndDivider() {
    let image = UIImage()
    setBackgroundImage(image, for: .normal, barMetrics: .default)
    setBackgroundImage(image, for: .selected, barMetrics: .default)
    setBackgroundImage(image, for: .highlighted, barMetrics: .default)
    setDividerImage(image, forLeftSegmentState: .selected, rightSegmentState: .normal, barMetrics: .default)
  }
  
  // MARK: - Setup
  
  private func setup() {
    removeBackgroundAndDivider()
    setupLayout()
    setupTextStyle()
    selectedSegmentIndex = 0
    bindSelectSegementedIndex()
  }
  
  private func setupLayout() {
    addSubview(underlineView)
    underlineView.snp.makeConstraints {
      $0.top.equalTo(snp.bottom).inset(1)
      $0.width.equalTo(snp.width).dividedBy(numberOfSegments)
      $0.height.equalTo(2)
      
      leadingConstraints = $0.leading.equalToSuperview().constraint
    }
  }
  
  private func setupTextStyle() {
    // 선택 시 bold 처리
    setTitleTextAttributes([.font: UIFont.pretendard(size: 16)], for: .normal)
    setTitleTextAttributes([.font: UIFont.pretendard(size: 16, weight: .bold)], for: .selected)
  }
  
  private func bindSelectSegementedIndex() {
    selectedSegmentIndexPublisher.sink { [weak self] index in
      guard let self = self else { return }
      let widthPerSegment = bounds.size.width / CGFloat(numberOfSegments)
      let xPosition = widthPerSegment * CGFloat(index)
      
      leadingConstraints?.update(inset: xPosition)
      UIView.animate(withDuration: 0.3, animations: {
        self.layoutIfNeeded()
      })
    }
    .store(in: &cancellables)
  }
}
