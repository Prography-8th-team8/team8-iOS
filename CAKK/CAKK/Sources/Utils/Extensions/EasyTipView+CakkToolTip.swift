//
//  EasyTipView+CakkToolTip.swift
//  CAKK
//
//  Created by 이승기 on 2023/08/12.
//

import EasyTipView

extension EasyTipView.Preferences {
  
  static func cakkToolTipPreferences(_ arrowPosition: EasyTipView.ArrowPosition) -> EasyTipView.Preferences {
    var preferences = EasyTipView.Preferences()
    preferences.drawing.font = .systemFont(ofSize: 13, weight: .semibold)
    preferences.drawing.foregroundColor = .white
    preferences.drawing.backgroundColor = .black
    preferences.drawing.arrowPosition = arrowPosition
    preferences.drawing.cornerRadius = 14
    return preferences
  }
}
