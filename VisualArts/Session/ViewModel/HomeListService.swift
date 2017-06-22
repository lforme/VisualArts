//
//  HomeListService.swift
//  VisualArts
//
//  Created by 木瓜 on 2017/6/22.
//  Copyright © 2017年 WHY. All rights reserved.
//

import Foundation
import ReactiveSwift

protocol HomeListService {
    func getHomeList() -> SignalProducer<Any, NSError>
}
