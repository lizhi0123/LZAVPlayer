//
//  LVideoDownloadManager.swift
//  LAVPlayerTest
//
//  Created by lizhi荔枝 on 2021/6/28.
//  个人主页：https://www.jianshu.com/u/2dc174d83679

import Foundation
import AVFoundation
import  MobileCoreServices


class LZResourceDownloader: NSObject {
    private var originalURL: URL
    private var session: URLSession!
    private var downloadQueue: DispatchQueue!
    private var loadingRequest: AVAssetResourceLoadingRequest?
    private var task: URLSessionDataTask?
    
    init(originalUrl: URL) {
        self.originalURL = originalUrl
        super.init()
        prepare()
    }
    
    func prepare()  {
        downloadQueue = DispatchQueue(label: "lizhi_ResourceDownloadQueue")
        let opertionQueue = OperationQueue()
        opertionQueue.maxConcurrentOperationCount = 3
        opertionQueue.underlyingQueue = downloadQueue
        session = URLSession(configuration: .default, delegate: self, delegateQueue: opertionQueue)
    }
    
    /// 启动下载任务
    func addDownload(loadingRequest: AVAssetResourceLoadingRequest){
        self.loadingRequest = loadingRequest
        guard let dataRequest = loadingRequest.dataRequest else {
            return
        }
        var request = URLRequest(url: self.originalURL)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        let lowerBound = dataRequest.requestedOffset
        let upperBound = lowerBound + Int64(dataRequest.requestedLength) - Int64( 1)
        let rangeHeader = "bytes=\(lowerBound)-\(upperBound)"
        print("--[rangeHeader] = \(rangeHeader)")
        request.setValue(rangeHeader, forHTTPHeaderField: "Range")
        
        let dataTask = self.session.dataTask(with: request)
        dataTask.resume()
        self.task = dataTask
        
    }
    func removeDownload(loadingRequest: AVAssetResourceLoadingRequest)  {
        self.task?.cancel()
    }
}

// MARK: - URLSessionDataDelegate
extension LZResourceDownloader: URLSessionDataDelegate,URLSessionTaskDelegate {
    /// 从响应请求头中获取视频文件总长度 contentLength
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        self.fillInContentInformationRequest(self.loadingRequest!, from: response)
        
        completionHandler(.allow)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        self.loadingRequest!.dataRequest?.respond(with: data)
        
    }
    
    func urlSession(_: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let _ =  error  {
            self.loadingRequest?.finishLoading(with: error)
        }else {
            loadingRequest?.finishLoading()
        }
    }
    
    //填充请求
    func fillInContentInformationRequest(_ loadingRestst:AVAssetResourceLoadingRequest,from response:URLResponse) {
        var contentLength = Int64(0)
        var isByteRangeAccessSupported = true
        var contentType: String = ""
        
        guard let httpResponse = response as? HTTPURLResponse else {
            return
        }
        // 将headers的key都转换为小写
        var headers = [String: Any]()
        for key in httpResponse.allHeaderFields.keys {
            let lowercased = (key as! String).lowercased()
            
            headers[lowercased] = httpResponse.allHeaderFields[key]
        }
        isByteRangeAccessSupported = (headers["accept-ranges"] as? String) == "bytes"
        if let rangeText = headers["content-range"] as? String, let lengthText = rangeText.split(separator: "/").last {
            contentLength = Int64(lengthText)!
        }
        
        if let mimeType = response.mimeType,
           let aContentType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType as CFString, nil)?.takeRetainedValue()
        {
            contentType = aContentType as String
        }
        
        loadingRestst.contentInformationRequest?.contentType = contentType
        loadingRestst.contentInformationRequest?.contentLength = contentLength
        loadingRestst.contentInformationRequest?.isByteRangeAccessSupported = isByteRangeAccessSupported
    }
}

