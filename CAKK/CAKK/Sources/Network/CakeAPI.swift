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
  case fetchBlogReviews(cakeShopName: String)
  case fetchCakeShopImage(id: Int)
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
    case .fetchBlogReviews:
      return "/blog"
    case .fetchCakeShopImage(id: let id):
      return "/image/\(id)"
    }
  }
  
  var method: Moya.Method {
    switch self {
    default:
      return .get
    }
  }
  
  var task: Moya.Task {
    switch self {
    case .fetchCakeShopList(let districts):
      let parameters: Parameters = [
        "district": districts.map { $0.rawValue.uppercased() }
      ]
      let encoding = URLEncoding(destination: .queryString)
      return .requestParameters(parameters: parameters, encoding: encoding)
      
    case .fetchDistrictCounts:
      return .requestPlain
      
    case .fetchCakeShopDetail(let id):
      let parameters: Parameters = ["id": id]
      let encoding = URLEncoding(destination: .queryString)
      return .requestParameters(parameters: parameters, encoding: encoding)
      
    case .fetchBlogReviews(cakeShopName: let name):
      let parameters: Parameters = ["name": name]
      let encoding = URLEncoding(destination: .queryString)
      return .requestParameters(parameters: parameters, encoding: encoding)
      
    case .fetchCakeShopImage:
      return .requestPlain
    }
  }
  
  var headers: [String: String]? {
    return nil
  }
  
  /// Moya Provider의 Stub Closure 에서 호출되는 SampleData
  // TODO: 명세서의 example이 아직 정의되지 않음... / 현재는 예시로 넣어놓은 데이터...
  var sampleData: Data {
    switch self {
    case .fetchCakeShopList:
      return SampleData.cakeShopListData
    case .fetchDistrictCounts:
      return Data()
    case .fetchCakeShopDetail:
      return Data()
    case .fetchBlogReviews:
      return Data()
    case .fetchCakeShopImage:
      return Data()
    }
  }
}
