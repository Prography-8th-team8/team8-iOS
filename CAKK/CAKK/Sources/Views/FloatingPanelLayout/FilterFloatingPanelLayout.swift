//
//  FilterFloatingPanelLayout.swift
//  CAKK
//
//  Created by 이승기 on 2023/06/24.
//

import FloatingPanel

class FilterFloatingPanelLayout: FloatingPanelLayout {
  let position: FloatingPanelPosition = .bottom
  let initialState: FloatingPanelState = .hidden
  let anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] = [
    .tip: FloatingPanelLayoutAnchor(absoluteInset: 360, edge: .bottom, referenceGuide: .safeArea)
  ]
  
  func backdropAlpha(for state: FloatingPanelState) -> CGFloat {
    return 0.6
  }
}
