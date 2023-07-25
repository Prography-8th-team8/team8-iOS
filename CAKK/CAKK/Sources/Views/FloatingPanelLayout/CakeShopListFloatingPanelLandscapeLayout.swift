//
//  DefaultFloatingPanelLandscapeLayout.swift
//  CAKK
//
//  Created by 이승기 on 2023/06/06.
//

import FloatingPanel

class CakeShopListFloatingPanelLandscapeLayout: FloatingPanelLayout {
  let position: FloatingPanelPosition = .bottom
  let initialState: FloatingPanelState = .tip
  let anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] = [
    .full: FloatingPanelLayoutAnchor(absoluteInset: 0, edge: .top, referenceGuide: .safeArea),
    .half: FloatingPanelLayoutAnchor(fractionalInset: 0.5, edge: .bottom, referenceGuide: .safeArea),
    .tip: FloatingPanelLayoutAnchor(absoluteInset: 120, edge: .bottom, referenceGuide: .safeArea)
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
