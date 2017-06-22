//
//  SignalProducerMapping.swift
//  API
//
//  Created by ET|冰琳 on 2017/3/24.
//  Copyright © 2017年 IB. All rights reserved.
//

import Foundation
import ReactiveSwift
import MappingAce



extension SignalProducer where Value: Any, Error: NSError {
    
    
    /// mapping entity
    func doMapping<T: Mapping>() -> SignalProducer<T, Error> {
        
        return self.map({ input -> T in
            
            if let value = input as? [String : Any] {
        
                let t: T = T.init(fromDic: value)
                return t
            }
            
            let t: T = T.init(fromDic: [String: Any]())
            return t
            
        })
    }
    
    func doMapping<T: Mapping>(_ result: T.Type) -> SignalProducer<T, Error> {
        return self.map({ input -> T in
            
            if let value = input as? [String : Any] {
             
                let t: T = T.init(fromDic: value)
                return t
            }
            
            let t: T = T.init(fromDic: [String: Any]())
            return t
        })
    }
    
    /// mapping entity array
    func doArrayMapping<T: Mapping>() -> SignalProducer<[T], Error> {
        return self.map({ input -> [T] in
            guard let value = input as? [[String : Any]] else {
                return [T]()
            }
            return value.lazy.map({ (v) -> T in
                return T.init(fromDic: v)
            })
        })
    }
    
    func doArrayMapping<T: Mapping>(_ result: T.Type) -> SignalProducer<[T], Error> {
        return self.map({ input -> [T] in
            guard let value = input as? [[String : Any]] else {
                return [T]()
            }
            
            return value.lazy.map({ (v) -> T in
                return T.init(fromDic: v)
            })
        })
    }
    
    /// just map to type
    func doMap<T>() -> SignalProducer<T, Error> {
        return self.map{$0 as! T}
    }
    
    func doMap<T>(_ result: T.Type) -> SignalProducer<T, Error> {
        return self.map{$0 as! T}
    }
}
