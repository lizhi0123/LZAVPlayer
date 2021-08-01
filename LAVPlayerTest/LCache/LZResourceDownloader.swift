//
//  LVideoDownloadManager.swift
//  LAVPlayerTest
//
//  Created by EDY on 2021/6/28.
//

import Foundation
import AVFoundation
import  MobileCoreServices


class LZResourceDownloader: NSObject {
    //    static let shared = LZVideoDownload()
    
    /// 存放下载任务的字典
    //    private lazy var urlTasks = [URL: VideoDownloadTask]()
    
    private var originalURL: URL
    private var session: URLSession!
    
    private var downloadQueue: DispatchQueue!
    //    private var requestTasks = [LZLoadingRequestTask]()
    //    private var isRunning = false
    //    private var runningIndex = -1;
    private var runningLoadRequest: AVAssetResourceLoadingRequest?
    private var runningTask: URLSessionDataTask?
    
    init(originalUrl: URL) {
        self.originalURL = originalUrl
        super.init()
        prepare()
    }
    
    func prepare()  {
        downloadQueue = DispatchQueue(label: "LVideoDownloadQueue")
        
        let opertionQueue = OperationQueue()
        opertionQueue.maxConcurrentOperationCount = 3
        opertionQueue.underlyingQueue = downloadQueue
        session = URLSession(configuration: .default, delegate: self, delegateQueue: opertionQueue)
    }
    
    /// 启动下载任务
    func addDownload(loadingRequest: AVAssetResourceLoadingRequest){
        
        self.runningLoadRequest = loadingRequest
        
        guard let dataRequest = loadingRequest.dataRequest else {
            return
        }
        let lowerBound = Int64(dataRequest.requestedOffset)
        let requestedLength = dataRequest.requestedLength
        //        let requestTest = URLRequest(url: URL(string: "http://www.baidu.com")!)
        print("--[startDownload]-" + String(lowerBound) + "-requestedLength-" + String(requestedLength))
        let newRequest = createURLRequest(url: self.originalURL, loadingRequest: loadingRequest, cacheLength: 0)
        let dataTask = self.session.dataTask(with: newRequest)
        dataTask.resume()
        self.runningTask = dataTask
        
    }
    
    func removeDownload(loadingRequest: AVAssetResourceLoadingRequest)  {
        self.runningTask?.cancel()
    }
    
    /// 创建下载URL请求
    private func createURLRequest(url: URL, loadingRequest: AVAssetResourceLoadingRequest, cacheLength: Int) -> URLRequest {
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        if let dataRequest = loadingRequest.dataRequest {
            let lowerBound = dataRequest.requestedOffset
            //            if  lowerBound > 0{
            let upperBound = lowerBound + Int64(dataRequest.requestedLength) - Int64( 1)
            let rangeHeader = "bytes=\(lowerBound)-\(upperBound)"
            print("--[rangeHeader] = \(rangeHeader)")
            request.setValue(rangeHeader, forHTTPHeaderField: "Range")
            //            }
        }
        
        return request
    }
    
    //    func writeContentInfo(response: URLResponse) {
    //        //        contentInformationRequest?.isByteRangeAccessSupported = contentInfo.isByteRangeAccessSupported
    //        //        contentInformationRequest?.contentLength = contentInfo.contentLength
    //        //        contentInformationRequest?.contentType = contentInfo.contentType
    //
    //
    //        guard let httpResponse = response as? HTTPURLResponse else {
    //            return
    //        }
    //
    //        var isByteRangeAccessSupported: Bool
    //        var contentLength: Int64
    //        var contentTypeStr: String
    //
    //        // 将headers的key都转换为小写
    //        var headers = [String: Any]()
    //
    //        for key in httpResponse.allHeaderFields.keys {
    //            let lowercased = (key as! String).lowercased()
    //
    //            headers[lowercased] = httpResponse.allHeaderFields[key]
    //        }
    //        isByteRangeAccessSupported = (headers["accept-ranges"] as? String) == "bytes"
    //        if let rangeText = headers["content-range"] as? String, let lengthText = rangeText.split(separator: "/").last {
    //            contentLength = Int64(lengthText)!
    //        } else {
    //            contentLength = httpResponse.expectedContentLength
    //        }
    //
    //        if let mimeType = response.mimeType,
    //           let contentType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType as CFString, nil)?.takeRetainedValue()
    //        {
    //            contentTypeStr = contentType as String
    //        } else {
    //            return
    //        }
    //    }
}

// MARK: - URLSessionDataDelegate
extension LZResourceDownloader: URLSessionDataDelegate,URLSessionTaskDelegate {
    /// 从响应请求头中获取视频文件总长度 contentLength
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        //        print("-- [response]=",response)
        //        self.writeContentInfo(response: response)
        //        self.fillInContentInformationRequest(self.loadingRequest.contentInformationRequest)
        self.fillInContentInformationRequest(self.runningLoadRequest!, from: response)
        
        completionHandler(.allow)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        
        self.runningLoadRequest!.dataRequest?.respond(with: data)
        
    }
    
    func urlSession(_: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        print("--[urlSession] didCompleteWithError = ",error)
        if let _ =  error  {
            self.runningLoadRequest?.finishLoading(with: error)
        }else {
            runningLoadRequest?.finishLoading()
        }
    }
    
    //填充请求
    func fillInContentInformationRequest(_ loadingRestst:AVAssetResourceLoadingRequest,from response:URLResponse) {
        //        self.queue.async {
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

