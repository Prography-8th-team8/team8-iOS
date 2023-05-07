//
//  CakeAPI.swift
//  CAKK
//
//  Created by Mason Kim on 2023/05/07.
//

import Moya
import Alamofire

enum CakeAPI {
  case fetchCakeList
}

extension CakeAPI: TargetType {
  var baseURL: URL {
    switch self {
    case .fetchCakeList:
      return URL(string: "케이크크 API baseURL")!
    }
  }
  
  var path: String {
    switch self {
    case .fetchCakeList:
      return "케이크크 API path 경로"
    }
  }
  
  var method: Moya.Method {
    switch self {
    case .fetchCakeList:
      return .get
    }
  }
  
  var task: Moya.Task {
    switch self {
    case .fetchCakeList:
      return .requestPlain
//      let parameters: Parameters = [:] // TODO: 파라미터 정의
//      let encoding = URLEncoding( // TODO: Encoding 정의
//        destination: .queryString,
//        arrayEncoding: .noBrackets,
//        boolEncoding: .literal
//      )
//      return .requestParameters(parameters: parameters, encoding: encoding)
    }
  }
  
  var headers: [String: String]? {
    return nil
  }
}
