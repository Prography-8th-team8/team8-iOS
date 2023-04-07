//
//  UITableView+Register.swift
//  CAKK
//
//  Created by Mason Kim on 2023/04/03.
//

import UIKit

extension UITableViewCell: ReusableView { }

extension UITableView {
  func registerCell<T: UITableViewCell>(cellClass: T.Type) {
    self.register(cellClass, forCellReuseIdentifier: T.reuseIdentifier)
  }
  
  func dequeueReusableCell<T: UITableViewCell>(cellClass: T.Type, for indexPath: IndexPath) -> T {
    guard let cell = dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
      fatalError("Unable to dequeue Reusable TableView cell")
    }
    return cell
  }
}
