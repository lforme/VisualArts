//
//  SignalProducerPipe.swift
//  Inteligence.plus
//
//  Created by ET|冰琳 on 2017/5/25.
//  Copyright © 2017年 IT. All rights reserved.
//

import Foundation
import ReactiveSwift

extension SignalProducer {
    
    func pipe() -> (Signal<Value, Error>, Disposable ){
        
        var signal: Signal<Value, Error>!
        var disposable: Disposable!
        
        self.startWithSignal { (s, dispose) in
            signal = s
            disposable = dispose
        }
        return (signal, disposable)
    }
    
    func toSignal() -> Signal<Value, Error> {
        
        var signal: Signal<Value, Error>!
        
        self.startWithSignal { (s, dispose) in
            signal = s
        }
        return signal
    }
}
