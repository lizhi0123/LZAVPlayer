//
//  LVideoResourceLoader.swift
//  LAVPlayerTest
//
//  Created by LiZhi荔枝 on 2021/6/28.
// 个人主页：https://www.jianshu.com/u/2dc174d83679

import Foundation
import AVFoundation

class LZResourceLoader: NSObject {
    /// 加载队列
    public lazy var resourceLoaderQueue = DispatchQueue(label: "lizhi_resourceLoaderQueue")
    /// 原始url
    public  var originalURL: URL
    var downloader: LZResourceDownloader
    
    init(originalURL: URL) {
        self.originalURL = originalURL
        downloader = LZResourceDownloader(originalUrl: originalURL)
        super.init()
    }
}

// MARK: - AVAssetResourceLoaderDelegate
extension LZResourceLoader: AVAssetResourceLoaderDelegate {
    public func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        // 启动下载任务，同时保留loadingRequest
        downloader.addDownload(loadingRequest: loadingRequest)
        return true
    }
    
    public func resourceLoader(_ resourceLoader: AVAssetResourceLoader, didCancel loadingRequest: AVAssetResourceLoadingRequest) {
        objc_sync_enter(self)
        downloader.removeDownload(loadingRequest: loadingRequest)
        objc_sync_exit(self)
    }
}
