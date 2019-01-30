//
//  ShowVideoViewController.swift
//  BoringSSL
//
//  Created by Togami Yuki on 2019/01/29.
//

import UIKit
import AVFoundation
import Photos

class ShowVideoViewController: UIViewController {

    var videoURL:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("memo:URL",videoURL)
       
        
        // 動画ファイルのURLを取得
        let url = URL(string: videoURL)

        let player = AVPlayer(url: url!)
        
        // レイヤーの追加
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.view.bounds
        self.view.layer.addSublayer(playerLayer)
        
        // 再生
        player.play()
    }
}
