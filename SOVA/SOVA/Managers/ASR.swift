//
//  ASR.swift
//  SOVA
//
//  Created by Мурат Камалов on 12.10.2020.
//

import Foundation


import Foundation
import Alamofire

class ASR {
    var ASR_API_URL: String {
        get{
            let lang = Locale.preferredLanguages[0]
            return lang != "ru-RU" ? "https://asr-en.ashmanov.org/asr/" : "https://asr.ashmanov.org/asr/"
        }
    }
    
    struct Request {
        let model_type: String = "ASR"
        
        let audio: Data
        
        var multipartFormData: MultipartFormData {
            get {
                let mpData = MultipartFormData()
                mpData.append(self.audio, withName: "audio_blob", fileName: "1.wav", mimeType: "audio/wav")
                return mpData
            }
        }
    }
    
    struct Responce: Decodable {
        let text: String?
        let time: Float
    }
    
    struct ResponceMain: Decodable {
        let response_audio_url: String
        let response_code: Int
        let response: [Responce]
    }
    
    struct ResponceRoot: Decodable {
        let r: [ResponceMain]
    }
    
    
    public func recognize(data: Data, _ completion: @escaping(_ successText: String?, _ errorText: String?) -> Void ) {
        let request = Request(audio: data)
        AF.upload(
            multipartFormData: request.multipartFormData,
            to: ASR_API_URL,
            method: .post,
            headers: [.authorization("Basic YW5uOjVDdWlIT0NTMlpRMQ==")],
            requestModifier: { $0.timeoutInterval = 30 }
        )
        .responseJSON(queue: DispatchQueue(label: "speech", qos: .utility)) { responce in
            guard responce.error == nil else { completion(nil, responce.error?.localizedDescription); return }
            //            let resp = ResponceMain(from: responce.value as! Decoder)
            //            completion(Data(base64Encoded: resp.response_audio))
        }
        .responseDecodable(of: ResponceRoot.self) { responce in
            
            guard responce.error == nil else { completion(nil, responce.error?.localizedDescription ?? ""); return }
            
            guard let respRoot = responce.value,
                  let resp = respRoot.r.first,
                  let text = resp.response.first?.text else { completion(nil, "500"); return }
            completion(text, nil)
        }
    }
}
