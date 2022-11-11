//
//  LZFileHandle.swift
//  LAVPlayerTest
//
//  Created by LiZhi on 2022/11/11.
//

import Foundation

//缓存文件结构
//└── LZAVPlayer_cache
//    └── http
//        ├── 1-15
//        └── total

/// 文件处理
open class LZFileHandle {
    // TODO: <##>
    /// 往cache里写数据
    open func writeToCache(url:String,lowerBound:Int,upperBound:Int){
        
    }
    // TODO: <##>
    /// 读取cache里的数据
    open func readFromCache(url:String,lowerBound:Int,upperBound:Int){
        
    }
    // TODO: <##>
    /// 是否缓存过，没缓存过的缓存，缓存过的取缓存里的数据
    open func isCached(url:String,lowerBound:Int,upperBound:Int) -> Bool{
        return false
    }
}
