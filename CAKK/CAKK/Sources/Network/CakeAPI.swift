//
//  CakeAPI.swift
//  CAKK
//
//  Created by Mason Kim on 2023/05/07.
//

import Moya
import Alamofire

enum CakeAPI {
  case fetchCakeShopList(districts: [District])
  case fetchDistrictCounts
  case fetchCakeShopDetail(id: Int)
}

extension CakeAPI: TargetType {
  var baseURL: URL {
    return URL(string: "http://15.165.196.34:8080/store")!
  }
  
  var path: String {
    switch self {
    case .fetchCakeShopList:
      return "/list"
    case .fetchDistrictCounts:
      return "/district/count"
    case .fetchCakeShopDetail:
      return "/store"
    }
  }
  
  var method: Moya.Method {
    switch self {
    case .fetchCakeShopList:
      return .get
    case .fetchDistrictCounts:
      return .get
    case .fetchCakeShopDetail:
      return .get
    }
  }
  
  var task: Moya.Task {
    switch self {
    case let .fetchCakeShopList(districts):
      let parameters: Parameters = [
        "district": districts.map { $0.rawValue }
      ]
      let encoding = URLEncoding(destination: .queryString)
      return .requestParameters(parameters: parameters, encoding: encoding)
    case .fetchDistrictCounts:
      return .requestPlain
    case let .fetchCakeShopDetail(id):
      let parameters: Parameters = [
        "id": id
      ]
      let encoding = URLEncoding(destination: .queryString)
      return .requestParameters(parameters: parameters, encoding: encoding)
    }
  }
  
  var headers: [String: String]? {
    return nil
  }
  
  /// Moya Provider의 Stub Closure 에서 호출되는 SampleData
  var sampleData: Data {
    switch self {
    case .fetchCakeShopList:
      // TODO: Sample Mock Data 제공 (JSON 형태로 필요) _ 아직 백엔드 명세가 나오지 않음...
      return Data()
    case .fetchDistrictCounts:
      return Data()
    case .fetchCakeShopDetail:
      return Data()
    }
  }
}
