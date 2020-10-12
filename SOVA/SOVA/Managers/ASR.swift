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
    let ASR_API_URL = "https://asr.ashmanov.org/asr/"
    
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
        let model_type: String = "ASR"
//        let filename: String
        let audio: Data
        
        var multipartFormData: MultipartFormData {
            get {
                let mpData = MultipartFormData()
//                mpData.append(Data(model_type.utf8), withName: "model_type")
//                mpData.append(Data(filename.utf8), withName: "filename")
                mpData.append(audio, withName: "audio_blob", fileName: "1.wav", mimeType: "audio/wav")
//                mpData.append(audio, withName: "audio")
                return mpData
            }
        }
    }
    
    struct Responce: Decodable {
//        let name: String
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
//            Log.e("Responce:", responce)
//            if let error = responce.error {
//                Log.e("ERROR:", error)
//                completion(nil)
//            } else {
//                let resp = ResponceMain(responce.value)
//                completion(Data(base64Encoded: resp.response_audio))
//            }
        }
        .responseDecodable(of: ResponceRoot.self) { responce in
//            Log.e("Responce:", responce)
            if let error = responce.error?.localizedDescription {
//                Log.e("ERROR:", error)
                completion(nil, error)
            } else if let respRoot = responce.value,
                      let resp = respRoot.r.first,
                      let text = resp.response.first?.text {
                completion(text, nil)
            } else {
                completion(nil, "500")
            }
        }
    }
}
