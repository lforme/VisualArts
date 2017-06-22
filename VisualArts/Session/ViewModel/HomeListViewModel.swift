//
//  HomeListViewModel.swift
//  VisualArts
//
//  Created by 木瓜 on 2017/6/22.
//  Copyright © 2017年 WHY. All rights reserved.
//

import UIKit
import ReactiveSwift
import MappingAce

class HomeListViewModel<Service: HomeListService>: NSObject {
    let service: Service
    
    private let _cellModels = MutableProperty<[DocEntity]>([])
    private let _executing = MutableProperty<Bool>(false)
    private let _errorMessage = MutableProperty<String?>(nil)
    
    var placeCellModels: Property<[DocEntity]> {
        return Property(self._cellModels)
    }
    var executing: Property<Bool> {
        return Property(self._executing)
    }
    var errorMessage: Property<String?> {
        return Property(self._errorMessage)
    }
    
    init(service: Service) {
        self.service = service
    }
    
    public func fetchedList() {
        service.getHomeList()
            .handleViewModelRequsetWith(executing: _executing)
            .on( failed: {[unowned self] (error) in
                self._errorMessage.value = error.localizedDescription
            }, value: { (json) in
                guard let json = json as? [String: Any] else { return }
                guard let response = json["response"] as? [String: Any] else { return }
                guard let docs = response["docs"] as? [[String: Any]] else { return }
                
              let haflDocs = docs[0..<20]
              let newDocs = Array(haflDocs)
                
              self._cellModels.value = newDocs.lazy.map({ (doc) -> DocEntity in
                return DocEntity(fromDic: doc)
              })
                
            }).start()
    }
    
}



extension SignalProducer where Value: Any, Error: NSError {
    public func handleViewModelRequsetWith(executing: MutableProperty<Bool>) -> SignalProducer<Value, Error>  {
        return self.observe(on: UIScheduler())
            .on(starting: {
                executing.value = true
            }, failed: { (error) in
                executing.value = false
            }, completed: {
                executing.value = false
            }, disposed: {
                executing.value = false
            }, value: { (_) in
                executing.value = false
            })
    }
}
