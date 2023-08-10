//
//  WebView.swift
//  CakkCategoryUploader
//
//  Created by 이승기 on 2023/06/23.
//

import SwiftUI
import WebKit
 
struct WebView: UIViewRepresentable {
  
  var url: String
  weak var navigationDelegate: WKNavigationDelegate?
  
  //ui view 만들기
  func makeUIView(context: Context) -> WKWebView {
    guard let url = URL(string: self.url) else {
      return WKWebView()
    }
    
    let webView = WKWebView()
    webView.load(URLRequest(url: url))
    webView.navigationDelegate = navigationDelegate
    return webView
  }
  
  func updateUIView(_ uiView: WKWebView, context: UIViewRepresentableContext<WebView>) { }
}

//Canvas 미리보기용
struct MyWebView_Previews: PreviewProvider {
  static var previews: some View {
    WebView(url: "https://www.naver.com")
  }
}
