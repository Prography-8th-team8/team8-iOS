//
//  MyBookmarkViewModel.swift
//  CAKK
//
//  Created by Mason Kim on 2023/07/30.
//

import Foundation

import Combine


final class MyBookmarkViewModel: ViewModelType {
  
  // MARK: - Properties
  
  struct Input {
    let viewWillAppear = PassthroughSubject<Void, Never>()
    let saveBookmark = PassthroughSubject<Bookmark, Never>()
    let removeBookmark = PassthroughSubject<Bookmark, Never>()
  }
  
  struct Output {
    let bookmarks = CurrentValueSubject<[Bookmark], Never>([])
  }
  
  let input: Input
  let output: Output
  private var cancellables = Set<AnyCancellable>()
  
  private let realmStorage: RealmStorageProtocol
  
  
  // MARK: - Initializers
  
  init(realmStorage: RealmStorageProtocol) {
    self.input = Input()
    self.output = Output()
    self.realmStorage = realmStorage
    
    bind(input, output)
  }
  
  
  // MARK: - Private
  
  private func bind(_ input: Input, _ output: Output) {
    input.viewWillAppear.sink { [weak self] in
      guard let self = self else { return }
      let bookmarks = realmStorage
        .loadAll(entityType: BookmarkEntity.self)
        .map { $0.toModel() }
      
      output.bookmarks.send(bookmarks)
    }
    .store(in: &cancellables)
    
    bindBookmark(input, output)
  }
  
  private func bindBookmark(_ input: Input, _ output: Output) {
    input.saveBookmark.sink { [weak self] bookmark in
      self?.realmStorage.save(bookmark.toEntity())
    }
    .store(in: &cancellables)
    
    input.removeBookmark.sink { [weak self] bookmark in
      self?.realmStorage.remove(id: bookmark.id, entityType: BookmarkEntity.self)
    }
    .store(in: &cancellables)
  }
}
