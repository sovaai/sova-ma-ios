//
//  AnimateVC.swift
//  SOVA
//
//  Created by Мурат Камалов on 20.10.2020.
//

import UIKit
import AVKit

class AnimateVC: UIViewController{
    
    static var shared: AnimateVC = AnimateVC()
    
    private var player =  AVPlayer()
    let playerLayerAV = AVPlayerLayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.navigationController?.navigationBar.isHidden = true

        self.playerLayerAV.frame = self.view.frame
        self.view.layer.addSublayer(self.playerLayerAV)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.playerLayerAV.frame = self.view.frame
    }
    
    public func configure(){
        guard let path = Bundle.main.path(forResource: "hi", ofType:"mp4") else { self.showSimpleAlert(title: "wrong url".localized); return }
        let url = URL(fileURLWithPath: path)
        
        self.player = AVPlayer(url: url)
        self.playerLayerAV.player = self.player
        self.player.play()
    }
}
