//
//  AudioManager.swift
//  SOVA
//
//  Created by Мурат Камалов on 07.10.2020.
//

import AVFoundation
import AVKit

protocol AudioErrorDelegate: class, AVAudioRecorderDelegate{
    func audioErrorMessage(title: String, message: String?)
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
            self.errorDelegate?.audioErrorMessage(title: "Ошибка доступа к AVAudioSession".localized, message: error.localizedDescription)
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
            self.finishRecording(is: false)
            guard let url = self.url else {
                self.errorDelegate?.audioErrorMessage(title: "Не удается найти путь для записи".localized, message: nil)
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
                self.errorDelegate?.audioErrorMessage(title: "Не удается начать запись".localized, message: error.localizedDescription)
            }
        }
    }
    
    private func finishRecording(is succes: Bool){
        self.audioRecorder?.stop()
        self.audioRecorder = nil
        
        self.recordDelegate?.recording(state: .stop)
        guard succes else { return }
        
        do{
            let data = try Data(contentsOf: self.url!)
            self.recordDelegate?.speechState(state: .start)
            self.speechRecognizer.recognize(data: data) { (text, error) in
                guard error == nil, let text = text else {
                    self.errorDelegate?.audioErrorMessage(title: "Ошибка распознования текста", message: error)
                    self.recordDelegate?.speechState(state: .stop)
                    return
                }
                let message = Message(title: text, sender: .user)
                DataManager.shared.saveNew(message)
                self.sendMessageFromAudio(text: text)
            }
            
        }catch{
            self.errorDelegate?.audioErrorMessage(title: error.localizedDescription, message: error.localizedDescription)
        }
    
    }
    
    public func playSpeech(with text: String){
        self.speech.getSpeech(text: text) { (data) in
            guard let dataAudio = data else{
                self.errorDelegate?.audioErrorMessage(title: "Ошибка воспроизведения синтезатора речи", message: nil)
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
                self.errorDelegate?.audioErrorMessage(title: "Ошибка отправки сообщения".localized, message: error)
                self.recordDelegate?.speechState(state: .stop)
                return
            }
            let message = Message(title: messg, sender: .assistant)
            DataManager.shared.saveNew(message)
            AnimateVC.shared.configure(with: animation)
            self.playSpeech(with: messg)
            self.recordDelegate?.speechState(state: .stop)
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
        self.errorDelegate?.audioErrorMessage(title: error?.localizedDescription ?? "Some error".localized, message: nil)
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
