//
//  ViewModelType.swift
//  CAKK
//
//  Created by Mason Kim on 2023/05/14.
//

import Foundation

protocol ViewModelType {
  associatedtype Input
  associatedtype Output
  
  var input: Input! { get }
  var output: Output! { get }
}
