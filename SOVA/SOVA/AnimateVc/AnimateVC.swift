//
//  AnimateVC.swift
//  SOVA
//
//  Created by Мурат Камалов on 20.10.2020.
//

import UIKit
import AVKit

class AnimateVC: UIViewController{
    
    //----------------------------------------------------------------------------------------------------------------
    //MARK: Support
    //----------------------------------------------------------------------------------------------------------------
    
    //MARK: Static
    static public private(set) var shared: AnimateVC = AnimateVC()
    static private let DELAY = 5
    
    //MARK: Player
    private lazy var playerView = VideoPlayerView()
    
    private let player = AVQueuePlayer()
    
    public var isActive: Bool = false
    //MARK: Timer
    private var timer: Timer!
    private var isAssistantWaiting = false
    private var nextIdleTime: DispatchTime = .now() + .seconds(DELAY)
    
    private func initTimer() {
        self.timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(AnimateVC.DELAY / 2), repeats: true, block: { [weak self] (_) in
            guard let context = self, .now() > context.nextIdleTime else { return }
            context.playVideoIdle()
        })
    }
    
    //----------------------------------------------------------------------------------------------------------------
    //MARK: vc's lifecycle
    //----------------------------------------------------------------------------------------------------------------
    
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
        
        self.initTimer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.playVideo(name: AnimationType.hi.videoPath, wakeup: true)
        self.timer.fire()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.timer.invalidate()
        self.player.removeAllItems()
    }
    
    //----------------------------------------------------------------------------------------------------------------
    //MARK: Configure
    //----------------------------------------------------------------------------------------------------------------
    
    public func configure(with value: Int?) {
        guard self.isActive else { return }
        guard value != nil, let type = AnimationType(rawValue: value!) else { self.showSimpleAlert(title: "Some error in animate".localized); return }
        guard type != .idle else { self.playVideoIdle(); return }
        self.playVideo(name: type.videoPath, wakeup: true)
    }
    
    //----------------------------------------------------------------------------------------------------------------
    //MARK: Viedo player
    //----------------------------------------------------------------------------------------------------------------
    
    fileprivate func playVideoIdle() {
        guard self.isActive else { return }
        guard !self.isAssistantWaiting else { self.playVideo(name: AnimationType.idle.videoPath, wakeup: false); return }
        self.playVideo(name: AnimationType.startIdle.videoPath, wakeup: false)
        self.isAssistantWaiting = true
    }
    
    public func playVideo(name: String, wakeup: Bool) {
        guard self.isActive else { return }
        if wakeup && self.isAssistantWaiting, let path = Bundle.main.path(forResource: AnimationType.stopIdle.videoPath, ofType:"mp4") {
            let asset = AVURLAsset(url: URL(fileURLWithPath: path))
            let item = AVPlayerItem(asset: asset)
            self.playAssistant(item: item)
            self.isAssistantWaiting = false
        }
        
        guard let path = Bundle.main.path(forResource: name, ofType:"mp4") else { return }
        let asset = AVURLAsset(url: URL(fileURLWithPath: path))
        let item = AVPlayerItem(asset: asset)
        self.playAssistant(item: item)
    }
    
    private func playAssistant(item: AVPlayerItem?) {
        guard self.isActive else { return }
        guard let item = item else { self.showSimpleAlert(title: "Video play error".localized); return }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.onVideoItemEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: item)
        
        self.player.insert(item, after: self.player.items().last)
        self.player.play()
        self.nextIdleTime = .now() + .seconds(AnimateVC.DELAY)
        
    }
    
    public func speechState(state: AudioState) {
        let type:AnimationType = state == .start ? .startIdle : .stopIdle
        self.configure(with: type.rawValue)
    }
    
    @objc private func onVideoItemEnd(notification: Notification?) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: notification?.object)
        guard self.player.items().count != 1 else { self.player.pause(); return }
        self.player.advanceToNextItem()
    }
    
    //----------------------------------------------------------------------------------------------------------------
    
}
