//
//  AudioBtn.swift
//  SOVA
//
//  Created by Мурат Камалов on 07.10.2020.
//

import UIKit

class AudioBtn: UIView{
    private var btn = UIButton()
    private var animateView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.btn)
        self.btn.translatesAutoresizingMaskIntoConstraints = false
        self.btn.topAnchor.constraint(equalTo: self.topAnchor, constant: 17).isActive = true
        self.btn.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -17).isActive = true
        self.btn.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 17).isActive = true
        self.btn.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -17).isActive = true
        
        self.btn.setImage(UIImage(named: "Menu/recordingbtn")?.allowTinted, for: .normal)
        self.btn.backgroundColor = UIColor(named: "Colors/mainbacground")
        self.btn.tintColor = UIColor(r: 252, g: 45, b: 129, a: 1.0)
        self.btn.layer.cornerRadius = 30
        self.btn.shadowOptions()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.btn.layer.cornerRadius = self.btn.frame.height / 2
    }
    
    public func addTarget(_ target: Any?, action: Selector, for controlEvents: UIControl.Event){
        self.btn.addTarget(target, action: action, for: controlEvents)
    }
    
    public func audioState(is state: AudioState){
        self.btn.backgroundColor = state == .start ? UIColor(r: 252, g: 45, b: 129, a: 1.0) :  UIColor(named: "Colors/mainbacground")
        self.btn.tintColor = state == .start ?  UIColor(named: "Colors/mainbacground") : UIColor(r: 252, g: 45, b: 129, a: 1.0)
        guard state == .stop else { self.startAnimate(); return }
        self.subviews.forEach{
            guard !($0 is UIButton) else { return }
            $0.layer.removeAllAnimations()
            $0.removeFromSuperview()
        }
    }
    
    private func startAnimate(){
        for i in 0...2{
            DispatchQueue.main.asyncAfter(deadline: .now() + (0.5 * Double(i))) {
                let view = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
                view.center = self.btn.center
                view.layer.cornerRadius = view.frame.height / 2
                view.layer.borderColor = UIColor(r: 252, g: 45, b: 129 , a: 1.0).cgColor
                view.layer.borderWidth = 1.0
                self.addSubview(view)
                self.sendSubviewToBack(view)
                self.animate(view)
            }
        }
    }
    
    private func animate(_ view: UIView){
        
        UIView.animate(withDuration: 1.5, delay: 0, options: .curveLinear) {
            view.frame.size.height = 94
            view.frame.size.width = 94
            view.layer.cornerRadius = 94 / 2
            view.layer.borderColor = UIColor(r: 252, g: 45, b: 129, a: 0.1).cgColor
            view.center = self.btn.center
        } completion: { (_) in
            view.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
            view.center = self.btn.center
            view.layer.cornerRadius = view.frame.height / 2
            view.layer.borderColor = UIColor(r: 252, g: 45, b: 129, a: 1.0).cgColor
            self.animate(view)
            self.layer.removeAllAnimations()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
