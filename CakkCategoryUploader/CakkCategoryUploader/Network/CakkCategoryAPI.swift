//
//  CakkCategoryAPI.swift
//  CakkCategoryUploader
//
//  Created by 이승기 on 2023/07/02.
//

import Foundation
import Moya

enum CakkCategoryAPI {
  case postCategory(storeName: String, categories: [CakeCategory])
}

extension CakkCategoryAPI: TargetType {
  var baseURL: URL {
    return URL(string: "http://15.165.196.34:8081/api")!
  }
  
  var path: String {
    switch self {
    case .postCategory(let storeName, _):
      return "/admin/update/category/\(storeName)"
    }
  }
  
  var method: Moya.Method {
    return .post
  }
  
  var task: Moya.Task {
    switch self {
    case .postCategory(_, let categories):
      let encoder = JSONEncoder()
      return .requestJSONEncodable(categories)
    }
  }
  
  var headers: [String : String]? {
    return ["Content-Type" : "application/json"]
  }
}
