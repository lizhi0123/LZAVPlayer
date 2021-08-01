//
//  ViewController.swift
//  LAVPlayerTest
//
//  Created by lizhi荔枝 on 2021/6/21.
// 个人主页：https://www.jianshu.com/u/2dc174d83679
//
let url1 =  "http://livetest.tingshuowan.com/listen/path?url=/live/SoundEffects/sound_fc3a7931028ae628512efefe4a6b304c.mp3"
let url2 =  "http://livetest.tingshuowan.com/listen/path?url=/users/98ce6abaa876ad79313e3b27b22a363e/stayvoice/voice/c703177fe98a47fedf226953506a40ee.wav"
let url3 = "http://livetest.tingshuowan.com/listen/path?url=/users/98ce6abaa876ad79313e3b27b22a363e/stayvoice/voice/90687f71fddee4a34d4debded99f3ad6.wav"
let url4 = "http://livetest.tingshuowan.com/listen/path?url=/users/b8ac5fc35c49f6a83d1171da1cc01332/stayvoice/voice/4e7d0dcba05b428961e1e7e8a5a1aa9d.wav"
let url5 = "http://download.lingyongqian.cn/music/ForElise.mp3"

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var field: UITextField!
    
    var lzPlayer: LZAVPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        field.text = url5
        
    }
    
    @IBAction func start(_ sender: Any)  {
    }
    
    @IBAction func button2Click(_ sender: Any) {
        funcLiZhi()
    }
    
    func funcLiZhi()  {
        guard let voiceUrlString = field.text else {
            return
        }
        self.lzPlayer  = LZAVPlayer(withURL: voiceUrlString)
        self.lzPlayer!.play()
        
    }
    
}


