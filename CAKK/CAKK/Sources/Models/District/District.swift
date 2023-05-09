//
//  District.swift
//  CAKK
//
//  Created by Mason Kim on 2023/05/07.
//

import Foundation

enum District: String, Decodable {
  case jongno
  case jung
  case yongsan
  case seongdong
  case gwangjin
  case dongdaemun
  case jungnang
  case seongbuk
  case gangbuk
  case dobong
  case nowon
  case eunpyeong
  case seodaemun
  case mapo
  case yangcheon
  case gangseo
  case guro
  case geumcheon
  case yeongdeungpo
  case dongjak
  case gwanak
  case seocho
  case gangnam
  case songpa
  case gangdong
  
  var korean: String {
    switch self {
    case .jongno:
      return "종로"
    case .jung:
      return "중구"
    case .yongsan:
      return "용산"
    case .seongdong:
      return "성동"
    case .gwangjin:
      return "광진"
    case .dongdaemun:
      return "동대문"
    case .jungnang:
      return "중랑"
    case .seongbuk:
      return "성북"
    case .gangbuk:
      return "강북"
    case .dobong:
      return "도봉"
    case .nowon:
      return "노원"
    case .eunpyeong:
      return "은평"
    case .seodaemun:
      return "서대문"
    case .mapo:
      return "마포"
    case .yangcheon:
      return "양천"
    case .gangseo:
      return "강서"
    case .guro:
      return "구로"
    case .geumcheon:
      return "금천"
    case .yeongdeungpo:
      return "영등포"
    case .dongjak:
      return "동작"
    case .gwanak:
      return "관악"
    case .seocho:
      return "서초"
    case .gangnam:
      return "강남"
    case .songpa:
      return "송파"
    case .gangdong:
      return "강동"
    }
  }
}
