//
//  LVideoResourceLoader.swift
//  LAVPlayerTest
//
//  Created by LiZhi荔枝 on 2021/6/28.
//  个人主页：https://www.jianshu.com/u/2dc174d83679
//

import Foundation
import AVFoundation

class LZResourceLoader: NSObject {
    /// 加载队列
   public lazy var resourceLoaderQueue = DispatchQueue(label: "resourceLoaderQueue")
    /// 原始url
  public  var originalURL: URL
    var videoDownload: LZResourceDownloader?
        
    init(originalURL: URL) {
        self.originalURL = originalURL
        
        super.init()
    }
    
    deinit {
    }
}

// MARK: - AVAssetResourceLoaderDelegate
extension LZResourceLoader: AVAssetResourceLoaderDelegate {
     
    
    public func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        // 启动下载任务，同时保留loadingRequest, progress 是 URLSession 响应数据的回调处理
        if  videoDownload == nil{
            videoDownload = LZResourceDownloader(originalUrl: originalURL)
        }
        
        print("--[shouldWait]-- loadRequest = \(loadingRequest)")
        videoDownload?.addDownload(loadingRequest: loadingRequest)

        return true
        
    }
    
    public func resourceLoader(_ resourceLoader: AVAssetResourceLoader, didCancel loadingRequest: AVAssetResourceLoadingRequest) {
        print("-- resourceLoader|didCancel")
        videoDownload?.removeDownload(loadingRequest: loadingRequest)
    }
}
