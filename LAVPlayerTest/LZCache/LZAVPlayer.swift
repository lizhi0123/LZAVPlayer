//
//  LAVPlayer.swift
//  LAVPlayerTest
//
//  Created by LiZhi荔枝 on 2021/6/28.
//  个人主页：https://www.jianshu.com/u/2dc174d83679
//

import Foundation
import AVFoundation

class LZAVPlayer: NSObject {
    /// 视频地址
    var mediaUrl: String!
    /// 播放器实例
    var player: AVPlayer?
    /// 边下边播的代理
    var videoResourceLoader: LZResourceLoader?
    
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
        videoResourceLoader = LZResourceLoader(originalURL: url)

        guard let resourceLoader = videoResourceLoader else {
            return
        }
        urlAssrt.resourceLoader.setDelegate(videoResourceLoader, queue: resourceLoader.resourceLoaderQueue)
       let playerItem = AVPlayerItem(asset: urlAssrt)
        if player == nil {
            player = AVPlayer(playerItem: playerItem)
        } else {
            player?.replaceCurrentItem(with: playerItem)
        }
    }
    
}

extension LZAVPlayer {
    public func play(){
        self.player?.play()
    }
}


