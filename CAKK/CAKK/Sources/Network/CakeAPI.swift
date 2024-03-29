//
//  CakeAPI.swift
//  CAKK
//
//  Created by Mason Kim on 2023/05/07.
//

import Moya
import Alamofire

import NMapsGeometry

enum CakeAPI {
  case fetchCakeShopsByDistricts(
    _ districts: [District],
    categories: [CakeCategory],
    page: Int)
  case fetchCakeShopsByBounds(
    _ bounds: NMGLatLngBounds,
    categories: [CakeCategory],
    page: Int)
  case fetchDistrictCounts
  case fetchCakeShopDetail(id: Int)
  /// numberOfPosts을 지정하지 않으면 포스팅 갯수의 기본값은 3임
  case fetchBlogReviews(id: Int, numberOfPosts: Int = 3)
  case fetchCakeCategory(id: Int)
  case fetchFeed(page: Int)
  case fetchBookmark(id: Int)
}

extension CakeAPI: TargetType {
  var baseURL: URL {
    return URL(string: "http://3.39.95.150:8081/api/store")!
  }
  
  var path: String {
    switch self {
    case .fetchCakeShopsByDistricts:
      return "/list"
      
    case .fetchCakeShopsByBounds:
      return "/reload"
      
    case .fetchDistrictCounts:
      return "/district/count"
      
    case .fetchCakeShopDetail(id: let id):
      return "/\(id)"
      
    case .fetchBlogReviews(id: let id, numberOfPosts: _):
      return "/\(id)/blog"
    
    case .fetchCakeCategory(id: let id):
      return "/\(id)/type"
      
    case .fetchFeed:
      return "/feed"
      
    case .fetchBookmark(id: let id):
      return "/\(id)/bookmark"
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
    case .fetchCakeShopsByDistricts(let districts, let categories, let page):
      let districtsString = districts
        .map { $0.rawValue }
        .joined(separator: ",")
      let categoriesString = categories
        .map { $0.rawValue }
        .joined(separator: ",")
      
      let parameters: Parameters = [
        "district": districtsString,
        "storeTypes": categoriesString,
        "page": page
      ]
      let encoding = URLEncoding(destination: .queryString)
      return .requestParameters(parameters: parameters, encoding: encoding)
      
    case .fetchCakeShopsByBounds(let bounds, let categories, let page):
      let categoriesString = categories
        .map { $0.rawValue }
        .joined(separator: ",")
      
      let parameters: Parameters = [
        "southwestLatitude": bounds.southWestLat,
        "southwestLongitude": bounds.southWestLng,
        "northeastLatitude": bounds.northEastLat,
        "northeastLongitude": bounds.northEastLng,
        "storeTypes": categoriesString,
        "page": page
      ]
      let encoding = URLEncoding(destination: .queryString)
      return .requestParameters(parameters: parameters, encoding: encoding)
      
    case .fetchDistrictCounts:
      return .requestPlain
      
    case .fetchCakeShopDetail:
      return .requestPlain
      
    case .fetchBlogReviews(id: _, numberOfPosts: let numberOfPosts):
      let parameters: Parameters = ["num": numberOfPosts]
      let encoding = URLEncoding(destination: .queryString)
      return .requestParameters(parameters: parameters, encoding: encoding)
      
    case .fetchCakeCategory:
      return .requestPlain
    
    case .fetchFeed(let page):
      let parameters: Parameters = [
        "page": page
      ]
      let encoding = URLEncoding(destination: .queryString)
      return .requestParameters(parameters: parameters, encoding: encoding)
      
    case .fetchBookmark:
      return .requestPlain
    }
  }
  
  var headers: [String: String]? {
    return nil
  }
  
  /// Moya Provider의 Stub Closure 에서 호출되는 SampleData
  var sampleData: Data {
    switch self {
    case .fetchCakeShopsByDistricts:
      return SampleData.cakeShopListData
      
    case .fetchCakeShopsByBounds:
      return SampleData.cakeShopListData
      
    case .fetchDistrictCounts:
      return SampleData.districtCountData
      
    case .fetchCakeShopDetail:
      return SampleData.cakeShopDetailData
      
    case .fetchBlogReviews:
      return SampleData.blogPostsData
      
    case .fetchCakeCategory:
      return SampleData.cakeCategoryData
      
    case .fetchFeed:
      return SampleData.feedData
      
    case .fetchBookmark:
      return SampleData.bookmarkData
    }
  }
}
