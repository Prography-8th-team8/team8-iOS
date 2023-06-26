//
//  CakeCategory.swift
//  CakkCategoryUploader
//
//  Created by 이승기 on 2023/06/23.
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
    }
  }
}
