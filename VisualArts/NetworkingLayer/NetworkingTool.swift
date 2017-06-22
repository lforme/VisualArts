//
//  NetworkingTool.swift
//  VisualArts
//
//  Created by 木瓜 on 2017/6/22.
//  Copyright © 2017年 WHY. All rights reserved.
//

import Foundation
import Alamofire
import ReactiveSwift
import MappingAce

enum HTTPResultCode: Int {
    case suceed = 1
    case fail   = 0
}

struct NetworkingTool {
    
    static func request(_ url: URLConvertible,
                        method: HTTPMethod = .get,
                        parameters: Parameters? = nil,
                        encoding: ParameterEncoding = URLEncoding.default,
                        headers: HTTPHeaders? = nil) -> DataRequest {
        
        #if DEBUG
            print("[{\(method)}url: \(url)]\n[headers:]: \(headers)\n[parameters]: \(parameters)")
        #endif
        return Alamofire.request(url, method: method, parameters: parameters, encoding: encoding, headers: headers)
    }
    
    static func download(_ url: URLConvertible, method: HTTPMethod, parameters: Parameters? = nil, encoding: ParameterEncoding = URLEncoding.default, headers: HTTPHeaders? = nil, fileName: String, closure: @escaping Request.ProgressHandler) -> SignalProducer<Any, NSError> {
        
        let destination: DownloadRequest.DownloadFileDestination = { a, b in
            
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent(fileName)
            
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        return SignalProducer<Any, NSError> { observer, disposable in
            
            var headerField: [String: String] = ["enctype": "multipart-form"]
            
            if let header = headers {
                for (k, v) in header {
                    headerField.updateValue(v, forKey: k)
                }
            }
            
            let req = Alamofire.download(url, method: method, parameters: parameters, encoding: encoding, headers: headerField, to: destination)
                .downloadProgress(closure: closure)
                .response { response in
                    
                    if let error = response.error {
                        observer.send(error: error as NSError)
                    }
                    
                    if let path = response.destinationURL?.path {
                        observer.send(value: path)
                        observer.sendCompleted()
                    }
            }
            
            disposable += {
                req.cancel()
            }
        }
    }
    
    /// upload
    static func upload(
        _ url: URLConvertible,
        fileURL: URL? = nil,
        image: UIImage? = nil,
        parameters: Parameters? = nil,
        headers: HTTPHeaders? = nil,
        closure: @escaping Request.ProgressHandler)
        -> SignalProducer<Any, NSError>
    {
        
        #if DEBUG
            print("[{Upload image}url: \(url)]\n[headers:]: \(headers)\n[parameters]: \(parameters)")
        #endif
        let signal = SignalProducer<(request: UploadRequest, streamingFromDisk: Bool, streamFileURL: URL?), NSError> { observer, disposable in
            
            var headerField: [String: String] = ["enctype": "multipart-form"]
            
            if let header = headers {
                for (k, v) in header {
                    headerField.updateValue(v, forKey: k)
                }
            }
            
            Alamofire.upload(multipartFormData: { multipartFormData in
                
                if let fileURL = fileURL {
                    multipartFormData.append(fileURL, withName: "files")
                }else if let img = image {
                    
                    if let data = UIImageJPEGRepresentation(img, 1) {
                        multipartFormData.append(data, withName: "files", fileName: "aaa.jpg", mimeType: "image/jpeg")
                    }else if let data = UIImagePNGRepresentation(img) {
                        multipartFormData.append(data, withName: "files", fileName: "aaa.png", mimeType: "image/png")
                    }else {
                        fatalError("data is nil")
                    }
                }
                
                guard let params = parameters else { return }
                for (key, value) in params {
                    
                    multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
                    
                }
            },
                             to: url,
                             headers: headerField,
                             encodingCompletion: { encodingResult in
                                
                                switch encodingResult{
                                case .failure(let err):
                                    observer.send(error: err as NSError)
                                case .success(let v):
                                    observer.send(value: v)
                                    observer.sendCompleted()
                                }
            })
        }
        return signal.flatMap(.latest, transform: { (request: UploadRequest, streamingFromDisk: Bool, streamFileURL: URL?) -> SignalProducer<Any, NSError> in
            print(request)
            return request.uploadProgress(closure: closure).reactive.responseJSON()
        })
    }
}


// deal common header
private func deal(header: HTTPHeaders?) -> HTTPHeaders? {
    
    let _headers: HTTPHeaders = header ?? HTTPHeaders()
    return _headers
}

private func deal(params: Parameters?) -> Parameters? {
    
    // deal common params
    return params
}

public func AppError<T>(desc: String) -> SignalProducer<T, NSError> {
    
    return SignalProducer(error: NSError(domain: "app.err",
                                         code: -1,
                                         userInfo: [NSLocalizedDescriptionKey: desc]))
    
}

private func dealError(value: Any) -> SignalProducer<Any, NSError> {
    
    guard let dic = value as? [String: Any], let code = dic["Code"] as? Int else {
        return AppError(desc: "出错啦")
    }
    
    if code == HTTPResultCode.suceed.rawValue {
        return SignalProducer.init(value: dic["Data"] ?? "error")
    }
    
    if code == HTTPResultCode.fail.rawValue, let desc = dic["Msg"] as? String {
        return AppError(desc: desc)
    }
    return AppError(desc: "出错啦")
}

/// 非code message data请求
///
/// - Returns: 后台返回给我们什么 Any就是什么
public func requestJSON(
    path: Path,
    method: Alamofire.HTTPMethod = .get,
    parameters: Parameters? = nil,
    encoding: ParameterEncoding = URLEncoding.default,
    headers: HTTPHeaders? = nil)
    -> SignalProducer<Any, NSError> {
        
        let urlO = Server.Default.host.url(path)
        
        guard let url = urlO else {
            fatalError("please provide a right url")
        }
        
        return SignalProducer<Any, NSError> { (observer, dispose) in
            
            
            let signal = SignalProducer<Any, ITError>.init({ (observe, dispose) in
                
                let signal: SignalProducer<Any, ITError> =
                    NetworkingTool.request(url, method: method, parameters: parameters, encoding: encoding, headers: deal(header: headers))
                        .validate(statusCode: 200..<300)
                        .reactive
                        .responseJSONResponse()
                
                dispose += signal.start(observe)
            })
            
            // deal token
            let mapped = signal.flatMapError({ (err) -> SignalProducer<Any, NSError> in
                
                switch err {
                    
                case .tokenExpired:
                    break
                    
                case .refreshTokenInvalid:
                   break
                    
                case .error(err: let err):
                    return SignalProducer(error: err)
                }
                return SignalProducer(error: err as NSError)
            })
            
            mapped.start(observer)
        }
}


/// 上传图片 fileURL or img
public func uploadData(path: Path ,
                       fileURL: URL? = nil,
                       img: UIImage? = nil,
                       headers: HTTPHeaders? = nil,
                       closure: @escaping Request.ProgressHandler) -> SignalProducer<Any, NSError> {
    
    let urlO = Server.Default.host.url(path)
    
    guard let url = urlO else {
        fatalError("please provide a right url")
    }
    
    return NetworkingTool.upload(url, fileURL: fileURL, image: img, headers: deal(header: headers), closure: closure)
        .flatMap(.latest, transform: { (value) -> SignalProducer<Any, NSError> in
            return dealError(value: value)
        })
}
