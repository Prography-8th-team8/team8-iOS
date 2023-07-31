//
//  Feed.swift
//  CAKK
//
//  Created by 이승기 on 2023/07/30.
//

import Foundation

typealias FeedResponse = [Feed]

struct Feed: Decodable, Hashable {
  
  let id = UUID()
  
  let storeId: Int
  let storeName: String
  let district: District
  let imageUrl: String
}
