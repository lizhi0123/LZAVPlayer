//
//  LAVPlayer.swift
//  LAVPlayerTest
//
//  Created by LiZhi荔枝 on 2021/6/28.
//  个人主页：https://www.jianshu.com/u/2dc174d83679

import Foundation
import AVFoundation

class LZAVPlayer: NSObject {
    /// 视频地址
    var mediaUrl: String!
    /// 真正的播放器实例
    var realPlayer: AVPlayer?
    /// 边下边播的代理
    var resourceLoader: LZResourceLoader?
    
    init(withURL url: String?){
        super.init()
        self.mediaUrl = url
        preparePlayer()
    }
    
    private func preparePlayer() {
        guard let url = URL(string: mediaUrl) else {
            return
        }
        //下载
        var component = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        component.scheme = "LZStream"
        let streamUrl: URL = component.url!
        let urlAssrt = AVURLAsset(url: streamUrl)
        resourceLoader = LZResourceLoader(originalURL: url)

        guard let resourceLoader = resourceLoader else {
            return
        }
        urlAssrt.resourceLoader.setDelegate(resourceLoader, queue: resourceLoader.resourceLoaderQueue)
       let playerItem = AVPlayerItem(asset: urlAssrt)
        if realPlayer == nil {
            realPlayer = AVPlayer(playerItem: playerItem)
        } else {
            realPlayer?.replaceCurrentItem(with: playerItem)
        }
    }
    
}

extension LZAVPlayer {
    public func play(){
        self.realPlayer?.play()
    }
}


