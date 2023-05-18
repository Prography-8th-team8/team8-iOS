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
  
  func test_케이크리스트_Response_객체가_정상적으로_디코딩_된다() {
    // given
    let expectation = XCTestExpectation()
    
    // when
    sut.request(.fetchCakeShopList(districts: [.dobong]), type: CakeShopResponse.self)
      .sink { completion in
        if case let .failure(error) = completion {
          XCTFail("CakeShopResponse 객체 디코딩 실패: \(error)")
        }
      } receiveValue: { response in
        // then
        XCTAssertGreaterThan(response.cakeShops.count, 0)
        expectation.fulfill()
      }
      .store(in: &cancellableBag)
    
    wait(for: [expectation], timeout: 2)
  }
  
  func test_케이크상세정보_Response_객체가_정상적으로_디코딩_된다() {
    // given
    let expectation = XCTestExpectation()
    let expectatedData = SampleData.cakeShopDetail
    
    // when
    sut.request(.fetchCakeShopDetail(id: 0), type: CakeShopDetailResponse.self)
      .sink { completion in
        if case let .failure(error) = completion {
          XCTFail("CakeShopDetailResponse 객체 디코딩 실패: \(error)")
        }
      } receiveValue: { response in
        // then
        XCTAssertEqual(response.name, expectatedData?.name)
        expectation.fulfill()
      }
      .store(in: &cancellableBag)
    
    wait(for: [expectation], timeout: 2)
  }

  func test_지역별_가게_갯수_Response_객체가_정상적으로_디코딩_된다() {
    // given
    let expectation = XCTestExpectation()
    let expectatedData = SampleData.districtCount
    
    // when
    sut.request(.fetchDistrictCounts, type: DistrictCountResponse.self)
      .sink { completion in
        if case let .failure(error) = completion {
          XCTFail("DistrictCountResponse 객체 디코딩 실패: \(error)")
        }
      } receiveValue: { response in
        // then
        XCTAssertEqual(response.count, expectatedData?.count)
        expectation.fulfill()
      }
      .store(in: &cancellableBag)
    
    wait(for: [expectation], timeout: 2)
  }
  
  func test_디코딩_실패시_적절한_에러를_밷는다() {
    // given
    let expectation = XCTestExpectation()
    
    // when
    sut.request(.fetchCakeShopDetail(id: 0), type: DistrictCountResponse.self)
      .sink { completion in
        guard case .failure = completion else {
          XCTFail("CakeShopDetailResponse 객체 디코딩 실패")
          return
        }
        // then
        expectation.fulfill()
      } receiveValue: { _ in
        XCTFail("타입이 일치하지 않으므로, 성공해서 들어오면 안됨")
      }
      .store(in: &cancellableBag)
    
    wait(for: [expectation], timeout: 2)
  }
}
