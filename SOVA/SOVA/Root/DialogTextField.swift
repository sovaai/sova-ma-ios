//
//  DialogTextField.swift
//  SOVA
//
//  Created by Мурат Камалов on 06.10.2020.
//

import UIKit

class DialogTextField: UIView{

    private var textView = UITextView()
    private var sendMessageBtn = UIButton()
        
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
        
        self.backgroundColor = UIColor(named: "Colors/mainbacground")
        
        self.addSubview(self.sendMessageBtn)
        self.sendMessageBtn.translatesAutoresizingMaskIntoConstraints = false
        self.sendMessageBtn.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.sendMessageBtn.heightAnchor.constraint(equalToConstant: 24).isActive = true
        self.sendMessageBtn.widthAnchor.constraint(equalTo: self.sendMessageBtn.heightAnchor).isActive = true
        self.sendMessageBtn.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -17).isActive = true
        
        self.sendMessageBtn.setImage(UIImage(named: "Menu/sendBtn"), for: [])
        self.sendMessageBtn.addTarget(self, action: #selector(self.sendMesg), for: .touchUpInside)
        self.sendMessageBtn.isHidden = true
        
        self.addSubview(self.textView)
        self.textView.translatesAutoresizingMaskIntoConstraints = false
        self.textView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.textView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.textView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.textView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 17).isActive = true
        self.textView.rightAnchor.constraint(equalTo: self.sendMessageBtn.leftAnchor, constant: -17).isActive = true
        
        self.textView.text = "Напишите сообщение…"
        self.textView.textColor = UIColor(named: "Colors/headerColor") ?? UIColor(r: 15, g: 31, b: 72, a: 0.2)
        self.textView.font = UIFont.systemFont(ofSize: 16)
        self.textView.isEditable = true
        self.textView.backgroundColor = UIColor(named: "Colors/mainbacground")
        
        self.textView.delegate = self
        
        self.textView.autocapitalizationType = .sentences
        
        let line = UIView()
        self.addSubview(line)
        line.translatesAutoresizingMaskIntoConstraints = false
        line.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        line.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        line.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        line.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        line.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        
    }
    
    func centerVertically(){
        self.textView.centerVertically()
    }
        
    @objc func sendMesg(){
        guard let text = self.textView.text, !text.isEmpty else { return }
        self.textView.text = "Напишите сообщение…"
        self.textView.textColor = UIColor(named: "Colors/headerColor") ?? UIColor(r: 15, g: 31, b: 72, a: 0.2)
        self.sendMessageBtn.isHidden = true
        let message = Message(title: text, sender: .user)
        DataManager.shared.saveNew(message)
        NetworkManager.shared.sendMessage(cuid: DataManager.shared.currentAssistants.cuid.string, message: text) { (msg, animation, error) in
            guard error == nil else { return }
            
            AnimateVC.shared.configure(with: animation)
            
            guard let messg = msg else { return }
            let message = Message(title: messg, sender: .assistant)
            DataManager.shared.saveNew(message)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DialogTextField: UITextViewDelegate{
        
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView.textColor == (UIColor(named: "Colors/headerColor") ?? UIColor(r: 15, g: 31, b: 72, a: 0.2)) {
            textView.text = nil
            textView.textColor = UIColor(named: "Colors/textColor") ?? UIColor.black
            self.sendMessageBtn.isHidden = false
        }else if range == NSRange(location: 0, length: 1) , text.isEmpty {
            textView.text = "Напишите сообщение…"
            textView.textColor = UIColor(named: "Colors/headerColor") ?? UIColor(r: 15, g: 31, b: 72, a: 0.2)
            self.sendMessageBtn.isHidden = true
            return false
        }
        guard !text.isEmpty, text == "\n" else { return true }
        self.sendMesg()
        return false
    }
    
    func textViewDidChange(_ textView: UITextView) {
        textView.centerVertically()
    }
    
}
