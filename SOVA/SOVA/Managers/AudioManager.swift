//
//  AudioManager.swift
//  SOVA
//
//  Created by Мурат Камалов on 07.10.2020.
//

import AVFoundation

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

class AudioManager{
    private var recordingSession: AVAudioSession = AVAudioSession.sharedInstance()
    private var audioRecorder: AVAudioRecorder!
    
    public var isRecording: Bool = false {
        didSet{
            if self.isRecording{
                self.startRecoding()
            }else{
                self.finishRecording(is: true)
            }
        }
    }
    
    public weak var delegate: AudioDelegate? = nil {
        didSet
        {
            do{
                try self.recordingSession.setCategory(.playAndRecord, mode: .default)
                try self.recordingSession.setActive(true)
            }catch{
                self.delegate?.audioErrorMessage(title: "Ошибка доступа к AVAudioSession".localized)
            }
        }
    }
    
    private func startRecoding(){
        self.recordingSession.requestRecordPermission { [weak self] allowed in
            guard let self = self else { return }
            guard allowed else { self.delegate?.allowAlert(); return }
        }
        
        guard let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent("userRecording.m4a") else {
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
    }
}

enum AudioState{
    case start
    case stop
}
