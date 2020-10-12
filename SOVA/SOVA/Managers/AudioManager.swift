//
//  AudioManager.swift
//  SOVA
//
//  Created by Мурат Камалов on 07.10.2020.
//

import AVFoundation
import AVKit

protocol AudioDelegate: class, AVAudioRecorderDelegate{
    func audioErrorMessage(title: String)
    func allowAlert() // “Разрешите доступ к микрофону”
    func recording(state : AudioState)
}

extension AudioDelegate{
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        guard !flag else { return }
        self.recording(state: .stop)
    }
}

class AudioManager: NSObject{
    private lazy var recordingSession: AVAudioSession = {
       let session = AVAudioSession.sharedInstance()
        do{
            try session.setCategory(.playAndRecord)
            try session.setActive(true)
            try session.overrideOutputAudioPort(.speaker)
        }catch{
            self.delegate?.audioErrorMessage(title: "Ошибка доступа к AVAudioSession".localized)
        }
        return session
    }()
    
    private var audioRecorder: AVAudioRecorder!
    
    private var player: AVAudioPlayer?
    
    public var isRecording: Bool = false {
        didSet{
            if self.isRecording{
                self.startRecoding()
            }else{
                self.finishRecording(is: true)
            }
        }
    }
    
    public weak var delegate: AudioDelegate? = nil
        
    
    private lazy var url: URL? = {
        let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent("userRecording.m4a")
        return url
    }()
    
    private func startRecoding(){
        self.recordingSession.requestRecordPermission { [weak self] allowed in
            guard let self = self else { return }
            guard allowed else { self.delegate?.allowAlert(); return }
        }
        
        guard let url = self.url else {
            self.delegate?.audioErrorMessage(title: "Не удается найти путь для записи".localized)
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
            self.audioRecorder.delegate = delegate
            self.audioRecorder.record()
            self.delegate?.recording(state: .start)
        }catch{
            self.delegate?.audioErrorMessage(title: "Не удается начать запись".localized)
        }
    }
    
    private func finishRecording(is succes: Bool){
        self.audioRecorder.stop()
        self.audioRecorder = nil
        
        self.delegate?.recording(state: .stop)
        guard succes else {
            self.delegate?.audioErrorMessage(title: "Не удалось коректно завершить запись".localized)
            return
        }
        do{
            let data = try Data(contentsOf: self.url!)
            ASR().recognize(data: data) { (text, error) in
                guard error == nil, let text = text else { self.delegate?.audioErrorMessage(title: "Ошибка распозования текста".localized) ;return }
                let message = Message(title: text, sender: DialogViewController.sender)
                DataManager.shared.saveNew(message)
                NetworkManager.shared.sendMessage(cuid: DataManager.shared.currentAssistants.cuid.string, message: text) { (msg, error) in
                    guard error == nil else { return }
                    guard let messg = msg else { return }
                    let message = Message(title: messg, sender: .assistant)
                    DataManager.shared.saveNew(message)
                    TTS().getSpeech(text: messg) { (data) in
                        guard let dataAudio = data, let url = self.saveSpeechFile(data: dataAudio) else{ return }
                            let item = AVPlayerItem(url: url)
                        do{
                        self.player = try AVAudioPlayer(data: dataAudio)
                        }catch{
                            print(error)
                        }
                            self.player?.play()
                //            deleteSpeechFile(url: url)
                        

                    }
                }
            }
        }catch{
            print(error)
        }
    }
    
    public func playAudio(){
        guard let url = self.url else { self.delegate?.audioErrorMessage(title: "Не удалось воспроизвести аудио по данному пути"); return}
        do {
            self.player = try AVAudioPlayer(contentsOf: url)
            self.player?.prepareToPlay()
            self.player?.play()
        }catch{
            self.delegate?.audioErrorMessage(title: "Не удалось воспроизвести аудио по данному пути")
        }
    }
    
    private func saveSpeechFile(data: Data) -> URL? {
        let url = self.getDocumentURL(file: "speech_\(Date().timeIntervalSince1970).wav")
        do {
            try data.write(to: url)
        } catch {
            // failed to write file – missing permissions?
            return nil
        }
        return url
    }
    
    func getDocumentURL(file: String) -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent(file)
    }
}

enum AudioState{
    case start
    case stop
}
