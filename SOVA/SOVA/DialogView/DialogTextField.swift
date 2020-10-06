//
//  DialogTextField.swift
//  SOVA
//
//  Created by Мурат Камалов on 06.10.2020.
//

import UIKit

class DialogTextField: UIView{

    private var textView = UITextView()
    private var sendMessage = UIButton()
        
    public var keyboardIsHide: Bool = true {
        didSet{
            if self.keyboardIsHide {
                self.textView.resignFirstResponder()
                self.isHidden = true
            }else{
                self.isHidden = false
                self.textView.becomeFirstResponder()
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        self.backgroundColor = .white
        
        self.addSubview(self.sendMessage)
        self.sendMessage.translatesAutoresizingMaskIntoConstraints = false
        self.sendMessage.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.sendMessage.heightAnchor.constraint(equalToConstant: 24).isActive = true
        self.sendMessage.widthAnchor.constraint(equalTo: self.sendMessage.heightAnchor).isActive = true
        self.sendMessage.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -17).isActive = true
        
        self.sendMessage.setImage(UIImage(named: "Menu/sendBtn"), for: [])
        self.sendMessage.addTarget(self, action: #selector(self.sendMesg), for: .touchUpInside)
        self.sendMessage.isHidden = true
        
        self.addSubview(self.textView)
        self.textView.translatesAutoresizingMaskIntoConstraints = false
        self.textView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.textView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.textView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.textView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 17).isActive = true
        self.textView.rightAnchor.constraint(equalTo: self.sendMessage.leftAnchor, constant: -17).isActive = true
        
        self.textView.text = "Напишите сообщение…"
        self.textView.textColor = UIColor(r: 15, g: 31, b: 72, a: 0.2)
        self.textView.font = UIFont.systemFont(ofSize: 14)
        self.textView.isEditable = true
        
        self.textView.delegate = self
        
        let line = UIView()
        self.addSubview(line)
        line.translatesAutoresizingMaskIntoConstraints = false
        line.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        line.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        line.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        line.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        line.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        
    }
    
    @objc func sendMesg(){
        self.textView.text = "Напишите сообщение…"
        self.textView.textColor = UIColor(r: 15, g: 31, b: 72, a: 0.2)
        self.sendMessage.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DialogTextField: UITextViewDelegate{
        
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView.textColor == UIColor(r: 15, g: 31, b: 72, a: 0.2) {
            textView.text = nil
            textView.textColor = UIColor.black
            return true
        }else if range == NSRange(location: 0, length: 1) , text.isEmpty {
            textView.text = "Напишите сообщение…"
            textView.textColor = UIColor(r: 15, g: 31, b: 72, a: 0.2)
            self.sendMessage.isHidden = true
            return false
        }
        
        guard !text.isEmpty else { return true }
        self.sendMessage.isHidden = false
        return true
    }
}
