//
//  CakeShopDetailFloatingPanelLandscapeLayout.swift
//  CAKK
//
//  Created by 이승기 on 2023/07/03.
//

import FloatingPanel

class CakeShopDetailFloatingPanelLandscapeLayout: FloatingPanelLayout {
  let position: FloatingPanelPosition = .bottom
  let initialState: FloatingPanelState = .hidden
  let anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] = [
    .full: FloatingPanelLayoutAnchor(absoluteInset: 0, edge: .top, referenceGuide: .superview),
    .half: FloatingPanelLayoutAnchor(absoluteInset: 0, edge: .top, referenceGuide: .superview),
    .tip: FloatingPanelLayoutAnchor(absoluteInset: 240, edge: .bottom, referenceGuide: .safeArea)
  ]
  
  func backdropAlpha(for state: FloatingPanelState) -> CGFloat {
    return 0
  }
  
  func prepareLayout(surfaceView: UIView, in view: UIView) -> [NSLayoutConstraint] {
    return [
      surfaceView.widthAnchor.constraint(equalToConstant: 375)
    ]
  }
}
