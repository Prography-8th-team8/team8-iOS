//
//  UnderlineSegmentedControl.swift
//  CAKK
//
//  Created by Mason Kim on 2023/07/04.
//

import UIKit

import SnapKit
import Then


final class UnderlineSegmentedControl: UISegmentedControl {
  
  
  // MARK: - UI Components
  
  private lazy var underlineView = UIView().then { view in
    let width = self.bounds.size.width / CGFloat(numberOfSegments)
    let height = 2.0
    let xPosition = CGFloat(selectedSegmentIndex * Int(width))
    let yPosition = bounds.size.height - 1.0
    let frame = CGRect(x: xPosition, y: yPosition, width: width, height: height)
    let view = UIView(frame: frame)
    view.backgroundColor = .green
    addSubview(view)
  }
  
  
  // MARK: - Initialization
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.removeBackgroundAndDivider()
  }
  
  override init(items: [Any]?) {
    super.init(items: items)
    self.removeBackgroundAndDivider()
  }
  
  required init?(coder: NSCoder) {
    fatalError()
  }
  
  
  // MARK: - Lifecycle
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    let underlineFinalXPosition = (self.bounds.width / CGFloat(self.numberOfSegments)) * CGFloat(self.selectedSegmentIndex)
    UIView.animate(
      withDuration: 0.1,
      animations: {
        self.underlineView.frame.origin.x = underlineFinalXPosition
      }
    )
  }
  
  
  // MARK: - Private Methods
  
  private func removeBackgroundAndDivider() {
    let image = UIImage()
    setBackgroundImage(image, for: .normal, barMetrics: .default)
    setBackgroundImage(image, for: .selected, barMetrics: .default)
    setBackgroundImage(image, for: .highlighted, barMetrics: .default)
    setDividerImage(image, forLeftSegmentState: .selected, rightSegmentState: .normal, barMetrics: .default)
  }
}
