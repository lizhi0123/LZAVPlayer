//
//  LVideoResourceLoader.swift
//  LAVPlayerTest
//
//  Created by LiZhi荔枝 on 2021/6/28.
//

import Foundation
import AVFoundation

class LZResourceLoader: NSObject {
    /// 加载队列
   public lazy var resourceLoaderQueue = DispatchQueue(label: "resourceLoaderQueue")
    
    /// 原始url
  public  var originalURL: URL
    public var streamSchemeURL:URL
    var videoDownload: LZResourceDownloader?
        
    init(originalURL: URL,streamSchemeURL: URL) {
        self.originalURL = originalURL
        self.streamSchemeURL = streamSchemeURL
        
        super.init()
    }
    
    deinit {
        // 取消并保存数据
        let url = originalURL
        DispatchQueue.global().async { // 防止锁逻辑卡到主线程，cancel放到子线程去做
//            VideoDownloadManager.shared.cancelDownload(url: url)
        }
    }
}

// MARK: - AVAssetResourceLoaderDelegate
extension LZResourceLoader: AVAssetResourceLoaderDelegate {
     
    
    public func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        guard let dataRequest = loadingRequest.dataRequest else {
            return false
        }
        
//        NSURL *resourceURL = [loadingRequest.request URL];
//        let resourceURL = loadingRequest.request.url
//        guard   resourceURL?.scheme ==  StreamString  else{
//            return false
//        }
        
        let lowerBound = Int64(dataRequest.requestedOffset)
        let requestedLength = dataRequest.requestedLength
        print("--[shouldWait]-" + String(lowerBound) + "-requestedLength-" + String(requestedLength))

        // 启动下载任务，同时保留loadingRequest, progress 是 URLSession 响应数据的回调处理
        if  videoDownload == nil{
            videoDownload = LZResourceDownloader(originalUrl: originalURL)
        }
        
//        videoDownload.startDownload(url: originalURL, loadingRequest: loadingRequest)
        print("--[shouldWait]-- loadRequest = \(loadingRequest)")
        videoDownload?.addDownload(loadingRequest: loadingRequest)

        return true
        
    }
    
    public func resourceLoader(_ resourceLoader: AVAssetResourceLoader, didCancel loadingRequest: AVAssetResourceLoadingRequest) {
        objc_sync_enter(self)
        print("-- resourceLoader|didCancel")
        videoDownload?.removeDownload(loadingRequest: loadingRequest)
        objc_sync_exit(self)
    }
}
