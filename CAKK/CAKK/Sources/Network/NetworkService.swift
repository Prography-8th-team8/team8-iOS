//
//  NetworkService.swift
//  CAKK
//
//  Created by Mason Kim on 2023/05/07.
//

import Moya
import Combine

protocol NetworkServiceProtocol: AnyObject {
  associatedtype API: TargetType
  func request<T: Decodable>(_ target: API, type: T.Type) -> AnyPublisher<T, Error>
}

/// 사용 예시
///
/// ```
/// NetworkService<CakeAPI>(type: .stub)
///  .request(.fetchCakeShopList(districts: [.gangnam]), type: CakeShopResponse.self)
///  .sink(receiveCompletion: , receiveValue: )
/// ```
final class NetworkService<Target: TargetType>: NetworkServiceProtocol {
  
  enum NetworkServiceType {
    case server
    case stub
  }
  
  // MARK: - Properties
  
  private let provider: MoyaProvider<Target>
  private let decoder = JSONDecoder()
  
  // MARK: - LifeCycle
  
  init(type: NetworkServiceType = .server) {
    switch type {
    case .server:
      self.provider = MoyaProvider<Target>()
    case .stub:
      /// 서비스의 타입이 stub 일 경우, 1초 후에 sampleData 를 반환하는 provider를 생성
      self.provider = MoyaProvider<Target>(stubClosure: MoyaProvider.delayedStub(1.0))
    }
  }
  
  // MARK: - Public
  
  // Moya + Combine 으로 구현
  func request<T: Decodable>(_ target: Target, type: T.Type) -> AnyPublisher<T, Error> {
    provider
      .requestPublisher(target)
      .filterSuccessfulStatusCodes()
      .map(\.data)
      .decode(type: T.self, decoder: decoder)
      .eraseToAnyPublisher()
  }
}
