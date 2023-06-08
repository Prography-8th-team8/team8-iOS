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
  /// numberOfPosts을 지정하지 않으면 포스팅 갯수의 기본값은 3임
  case fetchBlogReviews(id: Int, numberOfPosts: Int? = nil)
  case fetchCakeShopImage(id: Int)
}

extension CakeAPI: TargetType {
  var baseURL: URL {
    return URL(string: "http://15.165.196.34:8081/api/store")!
  }
  
  var path: String {
    switch self {
    case .fetchCakeShopList:
      return "/list"
    case .fetchDistrictCounts:
      return "/district/count"
    case .fetchCakeShopDetail(id: let id):
      return "/\(id)"
    case .fetchBlogReviews(id: let id):
      return "/\(id)/blog"
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
        "district": districts
          .map { $0.rawValue.uppercased() }
          .joined(separator: ",")
      ]
      let encoding = URLEncoding(destination: .queryString)
      return .requestParameters(parameters: parameters, encoding: encoding)
      
    case .fetchDistrictCounts:
      return .requestPlain
      
    case .fetchCakeShopDetail:
      return .requestPlain
      
    case .fetchBlogReviews(id: _, numberOfPosts: let numberOfPosts):
      if let numberOfPosts = numberOfPosts {
        let parameters: Parameters = ["num": numberOfPosts]
        let encoding = URLEncoding(destination: .queryString)
        return .requestParameters(parameters: parameters, encoding: encoding)
      }
      return .requestPlain
      
    case .fetchCakeShopImage:
      return .requestPlain
    }
  }
  
  var headers: [String: String]? {
    return nil
  }
  
  /// Moya Provider의 Stub Closure 에서 호출되는 SampleData
  var sampleData: Data {
    switch self {
    case .fetchCakeShopList:
      return SampleData.cakeShopListData
    case .fetchDistrictCounts:
      return SampleData.districtCountData
    case .fetchCakeShopDetail:
      return SampleData.cakeShopDetailData
    case .fetchBlogReviews:
      return SampleData.blogPostsData
      
    // TODO: 샵 이미지는 아직 명세 정해지지 않음
    case .fetchCakeShopImage:
      return Data()
    }
  }
}
