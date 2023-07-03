//
//  CakeShopDetailFloatingPanelLayout.swift
//  CAKK
//
//  Created by 이승기 on 2023/07/03.
//

import FloatingPanel

class CakeShopDetailFloatingPanelLayout: FloatingPanelLayout {
  let position: FloatingPanelPosition = .bottom
  let initialState: FloatingPanelState = .hidden
  let anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] = [
    .full: FloatingPanelLayoutAnchor(absoluteInset: 0, edge: .top, referenceGuide: .safeArea),
    .tip: FloatingPanelLayoutAnchor(absoluteInset: 440, edge: .bottom, referenceGuide: .safeArea)
  ]
}
