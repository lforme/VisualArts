//
//  ReactiveDataRequest.swift
//  API
//
//  Created by ET|冰琳 on 2017/3/24.
//  Copyright © 2017年 IB. All rights reserved.
//

import Foundation
import ReactiveSwift
import Alamofire
import Result


let TokenExpired = 401
let RefreshTokenInvalid = 400

enum ITError: Error {
    case tokenExpired
    case refreshTokenInvalid
    case error(err: NSError)
}

// MARK: - ReactiveExtensionsProvider
extension DataRequest: ReactiveExtensionsProvider{}
extension Reactive where Base: DataRequest{
    
    func responseJSONResponse(queue: DispatchQueue? = nil,
                      options: JSONSerialization.ReadingOptions = .allowFragments) -> SignalProducer<Any, ITError> {
        
        let signal: SignalProducer<DataResponse<Any>, NoError> = SignalProducer {[base = self.base] (observer, dispose) in
            
            let request = base.responseJSON(queue: queue, options: options, completionHandler: { (response) in
                observer.send(value: response)
                observer.sendCompleted()
            })
            
            dispose += {
                request.cancel()
            }
        }
        
        return signal.flatMap(.latest) { (response) -> SignalProducer<Any, ITError> in

            switch response.result {
            case .success(let value):
                
                #if DEBUG
                    print("[SUCEED] [URL: \(response.request)] \n ~~~~ \(value)")
                #endif
                
                return SignalProducer.init(value: value)
            case .failure(let error):
                
                #if DEBUG
                    print("[Error] [URL: \(response.request)] \n ~~~~ \(error)")
                    if let data = response.data, let str = String(data: data, encoding: .utf8) {
                        print("Error msg:",str)
                    }
                #endif
                
                if let err = error as? AFError,
                    case let AFError.responseValidationFailed(reason:  reason) = err,
                    case let AFError.ResponseValidationFailureReason.unacceptableStatusCode(code: code) = reason {
                    
                    if code == TokenExpired {
                        return SignalProducer.init(error: ITError.tokenExpired)
                    }
                    if code == RefreshTokenInvalid {
                        return SignalProducer.init(error: ITError.refreshTokenInvalid)
                    }
                }
                return SignalProducer.init(error: ITError.error(err: error as NSError))
            }
        }
    }
    
    
    /// response JSON
    func responseJSON<T: Error>(
        queue: DispatchQueue? = nil,
        options: JSONSerialization.ReadingOptions = .allowFragments)
        -> SignalProducer<Any, T>
    {
        return SignalProducer {[base = self.base] (observer, dispose) in
            
            let request = base.responseJSON(queue: queue, options: options, completionHandler: { (response) in
                
                switch response.result{
                case .failure(let err):
                    
                    #if DEBUG
                        print("[Error] [URL: \(response.request)] \n ~~~~ \(err)")
                        if let data = response.data, let str = String(data: data, encoding: .utf8) {
                            print("Error msg:",str)
                        }
                    #endif
                    observer.send(error: err as! T)
                case .success(let value):
                    
                    #if DEBUG
                        print("[SUCEED] [URL: \(response.request)] \n ~~~~ \(value)")
                    #endif
                    
                    observer.send(value: value)
                    observer.sendCompleted()
                }
            })
            
            dispose += {
                request.cancel()
            }
        }
    }
}

