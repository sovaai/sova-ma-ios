//
//  AnimateVC.swift
//  SOVA
//
//  Created by Мурат Камалов on 20.10.2020.
//

import UIKit
import AVKit

let showAnimationNotification     = Notification.Name(rawValue: "com.osmino.events.inapp.videos.show")
let switchAssistantNotification   = Notification.Name(rawValue: "com.osmino.events.inapp.assist.switched")

struct AssistantVideoStarter {
    enum AnimType: Int {
        case HI = 1,
             DONT_KNOW,
             IDLE,
             YES,
             NO
    }
    
    static func showAnimation(type: AnimType) {
        NotificationCenter.default.post(Notification(name: showAnimationNotification, userInfo: ["type" : type.rawValue]))
    }
}


class AnimateVC: UIViewController{
    
    static var shared: AnimateVC = AnimateVC()
    
    static let DELAY = 5

    private var playerView: VideoPlayerView!
    private let player = AVQueuePlayer()
    private var timer: Timer!
    
    var isAssistantWaiting = false
    var nextIdleTime: DispatchTime = .now() + .seconds(DELAY)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.playerView = VideoPlayerView()
        self.view.addSubview(self.playerView)
        self.playerView.translatesAutoresizingMaskIntoConstraints = false
        self.playerView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        self.playerView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        self.playerView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.playerView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.playerView.player = player
        self.player.actionAtItemEnd = .none
        self.registerReceivers()
        self.initTimer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        playVideoHello()
        timer.fire()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        timer.invalidate()
    }
    
    private func registerReceivers() {
        NotificationCenter.default.addObserver(self, selector: #selector(onShowAnimationRequested), name: showAnimationNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onAssistantSwitched), name: switchAssistantNotification, object: nil)
    }
    
    
    @objc func onAssistantSwitched(_ notification: Notification) {
        playVideoHello()
    }
    
    private func initTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(AnimateVC.DELAY / 2), repeats: true, block: { [weak self] (_) in
            if let context = self {
                if .now() > context.nextIdleTime {
                    context.playVideoIdle()
                }
            }
        })
    }
    
    @objc func onShowAnimationRequested(_ notification: Notification) {
        if let val = notification.userInfo?["type"] as? Int,
           let type = AssistantVideoStarter.AnimType(rawValue: val) {
            switch type {
                case .HI:
                    playVideoHello()
                    break
                case .IDLE:
                    playVideoIdle()
                    break
                case .YES:
                    playVideo(name: "yes", wakeup: true)
                    break
                case .NO:
                    playVideo(name: "no", wakeup: true)
                    break
                case .DONT_KNOW:
                    playVideo(name: "idk", wakeup: true)
                    break
            }
        }
    }

    public func playVideoHello() {
        playVideo(name: "hi", wakeup: true)
    }

    fileprivate func playVideoIdle() {
        if !isAssistantWaiting {
            playVideo(name: "idle_in", wakeup: false)
            isAssistantWaiting = true
        } else {
            playVideo(name: "idle", wakeup: false)
        }
    }
    
    public func playVideo(name: String, wakeup: Bool) {
        if wakeup && isAssistantWaiting {
            if let path = Bundle.main.path(forResource: "idle_out", ofType:"mp4") {
                let asset = AVURLAsset(url: URL(fileURLWithPath: path))
                let item = AVPlayerItem(asset: asset)
                playAssistant(item: item)
                isAssistantWaiting = false
            }
        }
        
        if let path = Bundle.main.path(forResource: name, ofType:"mp4") {
            let asset = AVURLAsset(url: URL(fileURLWithPath: path))
            let item = AVPlayerItem(asset: asset)
            playAssistant(item: item)
        }
    }
    
    private func playAssistant(item: AVPlayerItem?) {
        if let item = item {
            NotificationCenter.default.addObserver(self, selector: #selector(onVideoItemEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: item)
            
            player.insert(item, after: player.items().last)
            player.play()
            nextIdleTime = .now() + .seconds(AnimateVC.DELAY)
        }
    }
    
    @objc private func onVideoItemEnd(notification: Notification?) {
        if player.items().count == 1 {
            // последний ролик в списке
            player.pause()
        } else {
            player.advanceToNextItem()
        }
    }

    
    public func speechState(state: AudioState) {
        let animeType: AnimationType
        switch state {
        case .start:
            animeType = .startIdle
        case .stop:
            animeType = .stopIdle
        }
//        self.configure(with: animeType)
    }
}
