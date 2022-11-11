//
//  LVideoResourceLoader.swift
//  LAVPlayerTest
//
//  Created by LiZhi荔枝 on 2021/6/28.
//  个人主页：https://www.jianshu.com/u/2dc174d83679
//

import Foundation
import AVFoundation

/**
 通过 LZResourceLoader 转到下载，然后 在 区分用  FileHandle 取本地数据 还是 ResourceDownloader 下载数据
 */
open class LZResourceLoader: NSObject {
    /// 加载队列
   public lazy var resourceLoaderQueue = DispatchQueue(label: "LZ_resourceLoaderQueue")
    /// 原始url
  public  var originalUrl: String
    var videoDownload: LZResourceDownloader?
    var fileHandle:LZFileHandle?
        
    init(originalUrl: String) {
        self.originalUrl = originalUrl
        
        super.init()
    }
    
    deinit {
    }
    
    func setup()  {
        fileHandle = LZFileHandle()
    }
}

// MARK: - AVAssetResourceLoaderDelegate
extension LZResourceLoader: AVAssetResourceLoaderDelegate {
     
    
    public func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        
        
        let isCached =   self.fileHandle?.isCached(url: originalUrl, lowerBound: Int(loadingRequest.dataRequest?.lowerBound() ?? 0), upperBound: Int(loadingRequest.dataRequest?.upperBound() ?? 0)) ?? false
        if isCached {
            
        }else {
            // 启动下载任务，同时保留loadingRequest, progress 是 URLSession 响应数据的回调处理
            if  videoDownload == nil{
                videoDownload = LZResourceDownloader(originalUrl: originalUrl)
            }
            
            print("--[shouldWait]-- loadRequest = \(loadingRequest)")
            videoDownload?.addDownload(loadingRequest: loadingRequest)
        }
        
       

        return true
        
    }
    
    public func resourceLoader(_ resourceLoader: AVAssetResourceLoader, didCancel loadingRequest: AVAssetResourceLoadingRequest) {
        print("-- resourceLoader|didCancel")
        if false { //本地
            
        }else {
            videoDownload?.removeDownload(loadingRequest: loadingRequest)
        }
       
    }
}
