//
//  Coordinator.swift
//  CAKK
//
//  Created by 이승기 on 2023/08/19.
//

import UIKit

protocol Coordinator {
  
  associatedtype eventType
  
  var childCoordinators: [any Coordinator] { get set }
  var navigationController: UINavigationController { get set }
  
  func start()
  func eventOccurred(event: eventType)
}

protocol CoordinatorEvent { }
