//
//  String+extension.swift
//  LAVPlayerTest
//
//  Created by LiZhi on 2022/11/11.
//

import Foundation
import CommonCrypto

extension String {
    func lzMd5() -> String {
        let utf8 = cString(using: .utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5(utf8, CC_LONG(utf8!.count - 1), &digest)
        var md5 = digest.reduce("") { $0 + String(format:"%02X", $1) }
        return md5
    }
}
