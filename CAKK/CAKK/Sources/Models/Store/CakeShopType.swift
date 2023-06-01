//
//  CakeShopType.swift
//  CAKK
//
//  Created by Mason Kim on 2023/05/07.
//

import UIKit

enum CakeShopType: String, Decodable, CaseIterable {
  case lettering = "LETTERING"
  case character = "CHARACTER"
  case mealbox = "MEALBOX"
  case tiara = "TIARA"
  case rice = "RICE"
  case flower = "FLOWER"
  case photo = "PHOTO"
  case figure = "FIGURE"
}

extension CakeShopType {
  var localizedString: String {
    switch self {
    case .lettering:
      return "✏️ 레터링"
    case .character:
      return "🤖 캐릭터"
    case .mealbox:
      return "🍱 도시락"
    case .tiara:
      return "👑 티아라"
    case .rice:
      return "🍡 떡케이크"
    case .flower:
      return "💐 플라워"
    case .photo:
      return "🖼️ 포토"
    case .figure:
      return "🪆 피규어"
    }
  }
}

extension CakeShopType {
  var color: UIColor {
    switch self {
    case .lettering:
      return UIColor(hex: 0x2448FF)
    case .character:
      return UIColor(hex: 0xFF5CBE)
    case .mealbox:
      return UIColor(hex: 0xE4B801)
    case .tiara:
      return UIColor(hex: 0xE63260)
    case .rice:
      return UIColor(hex: 0x8161EB)
    case .flower:
      return UIColor(hex: 0x977944)
    case .photo:
      return UIColor(hex: 0xE64136)
    case .figure:
      return UIColor(hex: 0x141C3B)
    }
  }
}
