//
//  TTS.swift
//  SOVA
//
//  Created by Мурат Камалов on 12.10.2020.
//
import Foundation
import Alamofire

class TTS {
    let TTS_API_URL = "https://tts.ashmanov.org/tts/"
    
    //    @Headers("Authorization: Basic YW5uOjVDdWlIT0NTMlpRMQ==")
    //
    // data to send:
    // - model_type -
    // - text       -
    // - options    -
    
    // responce:
    // - response_audio - String Base64 encoded wav
    // - response_audio_url - String
    // - response_code - Int
    // - response - array:
    //       - name - String
    //       - time - Float
    
    struct Request {
        let model_type: String
        let text: String
        let options: String
        
        var multipartFormData: MultipartFormData {
            get {
                let mpData = MultipartFormData()
                mpData.append(Data(model_type.utf8), withName: "voice")
                mpData.append(Data(text.utf8), withName: "text")
                mpData.append(Data(options.utf8), withName: "options")
                return mpData
            }
        }
    }
    
    struct Responce: Decodable {
        let name: String
        let time: Float
        let response_audio: String
        let response_audio_url: String
    }
    
    struct ResponceMain: Decodable {
        let response_code: Int
        let response: [Responce]
    }
    // все остальные поля не нужны.
    // API плавающий, поля меняются, появляются/исчезают.
    // берем только то что нужно
    
    public func getSpeech(text: String, _ completion: @escaping(Data?) -> Void ) {
        let request = Request(model_type: "Belenkaya", text: text, options: "")

        AF.upload(
            multipartFormData: request.multipartFormData,
            to: TTS_API_URL,
            method: .post,
            headers: [.authorization("Basic YW5uOjVDdWlIT0NTMlpRMQ==")],
            requestModifier: { $0.timeoutInterval = 5 }
        )
//        .responseJSON(queue: DispatchQueue(label: "speech", qos: .utility)) { responce in
//            Log.e("Responce:", responce.value.debugDescription)
//            if let error = responce.error {
//                Log.e("ERROR:", error)
//                completion(nil)
//            } else {
//                let resp = ResponceMain(responce.value)
//                completion(Data(base64Encoded: resp.response_audio))
//            }
//        }
        .responseDecodable(of: ResponceMain.self, queue: DispatchQueue(label: "speech", qos: .utility)) { responce in
//            Log.e("Responce:", responce)
            if let error = responce.error {
//                Log.e("ERROR:", error)
                completion(nil)
            } else if let resp = responce.value,
                      let audio = resp.response.first?.response_audio {
                completion(Data(base64Encoded: audio))
            }
        }
    }
}

