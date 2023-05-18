//
//  CAKKNetworkingTests.swift
//  CAKKNetworkingTests
//
//  Created by Mason Kim on 2023/05/18.
//

import XCTest
import Combine
@testable import CAKK

final class CAKKNetworkingTests: XCTestCase {
  
  var sut: NetworkService<CakeAPI>!
  private var cancellableBag = Set<AnyCancellable>()
  
  override func setUpWithError() throws {
    sut = NetworkService<CakeAPI>(type: .stub)
  }
  
  override func tearDownWithError() throws {
    sut = nil
  }
  
  func test_케이크리스트_Response_객체가_정상적으로_디코딩_된다() throws {
    sut.request(.fetchCakeShopList(districts: [.dobong]), type: CakeShopResponse.self)
      .sink { error in
        print(error)
        XCTFail("CakeShopResponse 객체 디코딩 실패")
      } receiveValue: { response in
        XCTAssertGreaterThan(response.cakeShops.count, 0)
      }
      .store(in: &cancellableBag)
  }
  
  func test_케이크상세정보_Response_객체가_정상적으로_디코딩_된다() throws {
    let expectation = SampleData.cakeShopDetail
    
    sut.request(.fetchCakeShopDetail(id: 0), type: CakeShopDetailResponse.self)
      .sink { error in
        print(error)
        XCTFail("CakeShopDetailResponse 객체 디코딩 실패")
      } receiveValue: { response in
        XCTAssertEqual(response.name, expectation?.name)
      }
      .store(in: &cancellableBag)
  }

  func test_지역별_가게_갯수_Response_객체가_정상적으로_디코딩_된다() throws {
    let expectation = SampleData.districtCount
    
    sut.request(.fetchDistrictCounts, type: DistrictCountResponse.self)
      .sink { error in
        print(error)
        XCTFail("DistrictCountResponse 객체 디코딩 실패")
      } receiveValue: { response in
        XCTAssertEqual(response.count, expectation?.count)
      }
      .store(in: &cancellableBag)
  }
}
