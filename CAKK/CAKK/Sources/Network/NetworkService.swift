//
//  NetworkService.swift
//  CAKK
//
//  Created by Mason Kim on 2023/05/07.
//

import Moya
import Combine

final class NetworkService {
  
  // MARK: - Properties
  
  private let provider = MoyaProvider<CakeAPI>()
  private let decoder = JSONDecoder()
  
  // MARK: - Public
  
  private func request<T: Decodable>(_ target: CakeAPI, type: T.Type) -> AnyPublisher<T, MoyaError> {
    provider.requestPublisher(target)
      .filterSuccessfulStatusCodes()
      .compactMap { [weak self] in
        guard let self else { return nil }
        return try? self.decoder.decode(T.self, from: $0.data)
      }
      .eraseToAnyPublisher()
  }
  
}

struct CakeMockData: Decodable {
  let cakeNames: [String]
}
