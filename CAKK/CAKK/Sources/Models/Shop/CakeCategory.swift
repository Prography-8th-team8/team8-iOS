//
//  CakeCategory.swift
//  CAKK
//
//  Created by Mason Kim on 2023/05/07.
//

import UIKit

enum CakeCategory: String, Decodable, CaseIterable {
  case lettering = "LETTERING"
  case character = "CHARACTER"
  case mealbox = "MEALBOX"
  case tiara = "TIARA"
  case rice = "RICE"
  case flower = "FLOWER"
  case photo = "PHOTO"
  case figure = "FIGURE"
  case etc = "ETC"
}

extension CakeCategory {
  var localizedString: String {
    switch self {
    case .lettering:
      return "레터링"
    case .character:
      return "캐릭터"
    case .mealbox:
      return "도시락"
    case .tiara:
      return "티아라"
    case .rice:
      return "떡케이크"
    case .flower:
      return "플라워"
    case .photo:
      return "포토"
    case .figure:
      return "피규어"
    case .etc:
      return "기타"
    }
  }
}

extension CakeCategory {
  var color: UIColor {
    switch self {
    case .lettering:
      return UIColor(hex: 0x2448FF)
    case .character:
      return UIColor(hex: 0xFF5CBE)
    case .mealbox:
      return UIColor(hex: 0xCEAA15)
    case .tiara:
      return UIColor(hex: 0x222222)
    case .rice:
      return UIColor(hex: 0x8161EB)
    case .flower:
      return UIColor(hex: 0xDD1717)
    case .photo:
      return UIColor(hex: 0x141C3B)
    case .figure:
      return UIColor(hex: 0x977944)
    case .etc:
      return UIColor(hex: 0x141C3B)
    }
  }
}

extension CakeCategory {
  var icon: UIImage? {
    switch self {
    case .lettering:
      return R.image.filter_lettering()
    case .character:
      return R.image.filter_character()
    case .mealbox:
      return R.image.filter_dosirak()
    case .tiara:
      return R.image.filter_tiara()
    case .rice:
      return R.image.filter_rice()
    case .flower:
      return R.image.filter_flower()
    case .photo:
      return R.image.filter_camera()
    case .figure:
      return R.image.filter_figure()
    case .etc:
      return nil
    }
  }
}
