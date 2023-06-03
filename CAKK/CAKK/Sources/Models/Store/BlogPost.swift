//
//  BlogPost.swift
//  CAKK
//
//  Created by Mason Kim on 2023/05/25.
//

import Foundation

struct BlogPostResponse: Decodable {
  let blogPosts: [BlogPost]
}

struct BlogPost: Decodable {
  let title: String
  let link: String
  let description: String
  let bloggerName: String
  let bloggerLink: String
  let postDate: String
  
  enum CodingKeys: String, CodingKey {
    case title
    case link
    case description
    case bloggerName = "bloggername"
    case bloggerLink = "bloggerlink"
    case postDate = "postdate"
  }
}
