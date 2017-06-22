//
//  BusinessConfiguration.swift
//  VisualArts
//
//  Created by 木瓜 on 2017/6/22.
//  Copyright © 2017年 WHY. All rights reserved.
//

import Foundation
import ReactiveCocoa
import ReactiveSwift
import Alamofire
import Result



extension Server {
    
    struct Default {}
}

extension Server.Default {
//    https://api.nytimes.com/svc/archive/v1
    static let product = Server(scheme: "https", host: "api.nytimes.com", basePath: "/")
    
     static let develop =  Server(scheme: "https", host: "api.nytimes.com", basePath: "/")
    
    static let fileBase = ""
    
    static var host: Server {
        #if DEBUG
            return self.develop
        #else
            return self.product
        #endif
    }
    
}
