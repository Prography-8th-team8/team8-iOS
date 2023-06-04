//
//  UserDefault.swift
//  CAKK
//
//  Created by 이승기 on 2023/06/04.
//

import Foundation

@propertyWrapper
struct UserDefault<T> {
  
  let key: String
  
  let defaultValue: T
  
  var wrappedValue: T {
    get { UserDefaults.standard.object(forKey: self.key) as? T ?? self.defaultValue }
    set { UserDefaults.standard.set(newValue, forKey: self.key) }
  }
}
