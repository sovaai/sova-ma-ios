//
//  AudioManager.swift
//  SOVA
//
//  Created by Мурат Камалов on 07.10.2020.
//

import AVFoundation
import AVKit

protocol AudioErrorDelegate: class, AVAudioRecorderDelegate{
    func audioErrorMessage(title: String)
    func allowAlert() // “Разрешите доступ к микрофону”
}

protocol AudioRecordingDelegate: class{
    func recording(state : AudioState)
    func speechState(state: AudioState)
}

extension AudioRecordingDelegate{
    func recording(state : AudioState) {}
    func speechState(state: AudioState) {}
}

class AudioManager: NSObject{
    private lazy var recordingSession: AVAudioSession = {
        let session = AVAudioSession.sharedInstance()
        do{
            try session.setCategory(.playAndRecord)
            try session.setActive(true)
            try session.overrideOutputAudioPort(.speaker)
        }catch{
            self.errorDelegate?.audioErrorMessage(title: "Ошибка доступа к AVAudioSession".localized)
        }
    
        return session
    }()
    
    private var audioRecorder: AVAudioRecorder? = AVAudioRecorder()
    
    private var player: AVAudioPlayer? = AVAudioPlayer()
    
    public var isRecording: Bool = false {
        didSet{
            if self.isRecording{
                self.startRecoding()
            }else{
                self.finishRecording(is: true)
            }
        }
    }
    
    public weak var errorDelegate: AudioErrorDelegate? = nil
    public weak var recordDelegate: AudioRecordingDelegate? = nil
    
    private lazy var speech = TTS()
    private lazy var speechRecognizer = ASR()
    
    private var playItem = [Data]()
    
    private lazy var url: URL? = {
        let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent("userRecording.m4a")
        return url
    }()
    
    private func startRecoding(){
        self.recordingSession.requestRecordPermission { [weak self] allowed in
            guard let self = self else { return }
            guard allowed else { self.errorDelegate?.allowAlert(); return }
            self.finishRecording(is: true)
            guard let url = self.url else {
                self.errorDelegate?.audioErrorMessage(title: "Не удается найти путь для записи".localized)
                return
            }
            let settings = [
                AVFormatIDKey : Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey : 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey : AVAudioQuality.high.rawValue
            ]
            
            do{
                self.audioRecorder = try AVAudioRecorder(url: url, settings: settings)
                self.audioRecorder?.record()
                self.recordDelegate?.recording(state: .start)
            }catch{
                self.errorDelegate?.audioErrorMessage(title: "Не удается начать запись".localized)
            }
        }
    }
    
    private func finishRecording(is succes: Bool){
        self.audioRecorder?.stop()
        self.audioRecorder = nil
        
        self.recordDelegate?.recording(state: .stop)
        guard succes else {
            self.errorDelegate?.audioErrorMessage(title: "Не удалось коректно завершить запись".localized)
            return
        }
        DispatchQueue.global(qos: .userInteractive).async {
            do{
                let data = try Data(contentsOf: self.url!)
                self.recordDelegate?.speechState(state: .start)
                self.speechRecognizer.recognize(data: data) { (text, error) in
                    guard error == nil, let text = text else {
                        self.errorDelegate?.audioErrorMessage(title: "Ошибка распозования текста".localized)
                        self.recordDelegate?.speechState(state: .stop)
                        return
                    }
                    let message = Message(title: text, sender: .user)
                    DataManager.shared.saveNew(message)
                    self.sendMessageFromAudio(text: text)
                }
                
            }catch{
                self.errorDelegate?.audioErrorMessage(title: error.localizedDescription)
            }
        }
    }
    
    public func playSpeech(with text: String){
        self.speech.getSpeech(text: text) { (data) in
            defer{
                self.recordDelegate?.speechState(state: .stop)
                let message = Message(title: text, sender: .assistant)
                DataManager.shared.saveNew(message)
            }
            
            guard let dataAudio = data else{
                self.errorDelegate?.audioErrorMessage(title: "Ошибка воспроизведения синтезатора речи")
                return
            }
            self.playItem.append(dataAudio)
            guard self.playItem.count == 1 else { return }
            do{
                self.player = try AVAudioPlayer(data: dataAudio)
            }catch{
                print(error)
            }
            self.player?.play()
        }
    }
    
    private func sendMessageFromAudio(text: String){
        NetworkManager.shared.sendMessage(cuid: DataManager.shared.currentAssistants.cuid.string, message: text) { (msg,animation, error)  in
            guard error == nil, let messg = msg else {
                self.errorDelegate?.audioErrorMessage(title: "Ошибка отправки сообщения".localized)
                self.recordDelegate?.speechState(state: .stop)
                return
            }
            let message = Message(title: messg, sender: .assistant)
            DataManager.shared.saveNew(message)
            if let type = animation, let animationType = AnimationType(rawValue: type) {
//                AnimateVC.shared.configure(with: animationType)
            }
            self.playSpeech(with: messg)
        }
    }
    
    override init() {
        super.init()
        self.player?.delegate = self
        self.audioRecorder?.delegate = self
    }
}

extension AudioManager: AVAudioPlayerDelegate{
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        self.errorDelegate?.audioErrorMessage(title: error?.localizedDescription ?? "Some error".localized)
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        guard flag else { return }
        self.playItem.removeFirst()
        guard let dataAudio = self.playItem.first else { return }
        do{
            self.player = try AVAudioPlayer(data: dataAudio)
            self.player?.play()
        }catch{
            print(error)
        }
    }
}

extension AudioManager: AVAudioRecorderDelegate{
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        guard flag else { return }
        self.recordDelegate?.recording(state: .stop)
    }
}

enum AudioState{
    case start
    case stop
}
