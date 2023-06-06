//
//  CakeShopListFloatingPanelLayout.swift
//  CAKK
//
//  Created by 이승기 on 2023/06/06.
//

import UIKit

import FloatingPanel

class CakeShopListFloatingPanelLayout: FloatingPanelLayout {
  let position: FloatingPanelPosition = .bottom
  let initialState: FloatingPanelState = .hidden
  let anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] = [
    .full: FloatingPanelLayoutAnchor(absoluteInset: 0, edge: .top, referenceGuide: .safeArea),
    .half: FloatingPanelLayoutAnchor(fractionalInset: 0.5, edge: .bottom, referenceGuide: .safeArea),
    .tip: FloatingPanelLayoutAnchor(absoluteInset: 100, edge: .bottom, referenceGuide: .safeArea)
  ]
}
