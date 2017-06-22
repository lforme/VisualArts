//
//  HomeListServiceIMPL.swift
//  VisualArts
//
//  Created by 木瓜 on 2017/6/22.
//  Copyright © 2017年 WHY. All rights reserved.
//

import Foundation
import Alamofire
import MappingAce
import ReactiveSwift

extension Path {
    static let archivev = Path(path: "svc/archive/v1/")
}

class HomeListServiceIMP: NSObject, HomeListService {
    
    func getHomeList() -> SignalProducer<Any, NSError> {
        
        var params: [String: Any] = [:]
        params["api-key"] = "ef61d1b0dd424965ac615b69986f24c6"
        
        return requestJSON(path: .archivev, method: .get, parameters: params, encoding: URLEncoding(destination: .queryString), headers: nil)
    }
}
