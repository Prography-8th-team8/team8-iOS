//
//  District.swift
//  CakkCategoryUploader
//
//  Created by 이승기 on 2023/06/25.
//

import Foundation

enum District: String, Decodable, CaseIterable {
  case jongno = "JONGNO"
  case jung = "JUNG"
  case yongsan = "YONGSAN"
  case seongdong = "SEONGDONG"
  case gwangjin = "GWANGJIN"
  case dongdaemun = "DONGDAEMUN"
  case jungnang = "JUNGNANG"
  case seongbuk = "SEONGBUK"
  case gangbuk = "GANGBUK"
  case dobong = "DOBONG"
  case nowon = "NOWON"
  case eunpyeong = "EUNPYEONG"
  case seodaemun = "SEODAEMUN"
  case mapo = "MAPO"
  case yangcheon = "YANGCHEON"
  case gangseo = "GANGSEO"
  case guro = "GURO"
  case geumcheon = "GEUMCHEON"
  case yeongdeungpo = "YEONGDEUNGPO"
  case dongjak = "DONGJAK"
  case gwanak = "GWANAK"
  case seocho = "SEOCHO"
  case gangnam = "GANGNAM"
  case songpa = "SONGPA"
  case gangdong = "GANGDONG"
  
  var koreanName: String {
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
