//
//  BookmarkCoordinator.swift
//  CAKK
//
//  Created by 이승기 on 2023/08/19.
//


import UIKit

final class BookmarkCoordinator: Coordinator {
  
  // MARK: - Properties
  
  var childCoordinators: [Coordinator] = []
  var navigationController: UINavigationController
  let storage: RealmStorageProtocol
  
  
  // MARK: - Initializers
  
  init(navigationController: UINavigationController,
       storage: RealmStorageProtocol) {
    self.navigationController = navigationController
    self.storage = storage
  }
  
  
  // MARK: - Methods
  
  func start() {
    let viewModel = MyBookmarkViewModel(realmStorage: storage)
    let vc = MyBookmarkViewController(viewModel: viewModel)
  }
}

