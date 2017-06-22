//
//  ServerConfiguration.swift
//  VisualArts
//
//  Created by 木瓜 on 2017/6/22.
//  Copyright © 2017年 WHY. All rights reserved.
//

import Foundation


struct Server {
    
    // eg: http https
    let scheme: String
    
    // eg: www.baidu.com
    let host: String
    
    // eg: "/"
    let basePath: String
    
    var url: String {
        let urlString = "\(scheme)://\(host)\(basePath)"
        return urlString
    }
}

// MARK: - path
public struct Path: ExpressibleByStringLiteral {
    
    var rawValue: String
    private let dateFormatter = DateFormatter()
    
    public init(path: String) {
        let date = Date()
        dateFormatter.dateFormat = "yyyy-M"
        let convertedDate: String = dateFormatter.string(from: date)
        let time = convertedDate.components(separatedBy: "-")
        
        self.rawValue = path + time.first! + "/" + time.last! + ".json"
    }
    
    public init(stringLiteral value: String){
        rawValue = value
    }
    
    public init(unicodeScalarLiteral value: String){
        rawValue = value
    }
    
    public init(extendedGraphemeClusterLiteral value: String){
        rawValue = value
    }
}

extension Server {
    
    func urlString(_ path: Path) -> String {
        return self.url + path.rawValue
    }
    
    func url(_ path: Path) -> URL? {
        return URL(string: self.url)?.appendingPathComponent(path.rawValue)
    }
}
