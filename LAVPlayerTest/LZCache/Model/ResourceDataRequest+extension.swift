//
//  LZResourceDataRequest.swift
//  LAVPlayerTest
//
//  Created by LiZhi on 2022/11/11.
//

import Foundation
import AVFoundation


 extension AVAssetResourceLoadingDataRequest {

    /// 请求的最低bound
    public  func lowerBound() -> Int64? {
        let lowerBound = self.requestedOffset
        return lowerBound
    }
    /// 请求的最高bound
     public  func upperBound() -> Int64? {
        let upperBound = self.requestedOffset + Int64(self.requestedLength) - Int64( 1)
        return upperBound
    }
}
