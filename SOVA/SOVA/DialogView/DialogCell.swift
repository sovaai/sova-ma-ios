//
//  DialogCell.swift
//  SOVA
//
//  Created by Мурат Камалов on 02.10.2020.
//

import UIKit
import Foundation

//MARK: DialogCell
class DialogCell: UICollectionViewCell{
    
    private(set) lazy var messageLabel: InteractiveLinkLabel = {
        let label = InteractiveLinkLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        
        return label
    }()
    
    
    lazy var messageBackground: UIView = {
        let backgroundView = UIView()
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.backgroundColor = UIColor(named: "Colors/userColor")
        backgroundView.layer.cornerRadius = 17
        return backgroundView
    }()
    
    fileprivate var leftConstraint: NSLayoutConstraint!
    fileprivate var rightConstraint: NSLayoutConstraint!
    fileprivate var topConstrint: NSLayoutConstraint!
    
    fileprivate var rightLabelConstrint: NSLayoutConstraint!
    fileprivate var leftLabelContraint: NSLayoutConstraint!
    
    fileprivate var bottomLine = UIView()
    
    public var url: URL? = nil
    
    fileprivate var sender: WhosMessage = .user{
        didSet{
            self.leftLabelContraint.constant = self.sender == .user ? 16 : 0
            self.rightLabelConstrint.constant = self.sender == .user ? 0 : -16
            self.leftConstraint.isActive = self.sender != .user
            self.rightConstraint.isActive = self.sender == .user
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUp()
        
    }
    
    fileprivate func setUp(){
        self.contentView.addSubview(messageBackground)
        self.topConstrint = self.messageBackground.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8)
        self.topConstrint.isActive = true
        self.messageBackground.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: 0).isActive = true
        self.leftConstraint = self.messageBackground.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
        self.rightConstraint = self.messageBackground.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16)
        self.messageBackground.widthAnchor.constraint(lessThanOrEqualToConstant: 257).isActive = true
        self.leftConstraint.isActive = true
        self.rightConstraint.isActive = false
        
        self.messageBackground.addSubview(self.bottomLine)
        self.bottomLine.translatesAutoresizingMaskIntoConstraints = false
        self.bottomLine.bottomAnchor.constraint(equalTo: self.messageBackground.bottomAnchor).isActive = true
        self.bottomLine.heightAnchor.constraint(equalToConstant: 17).isActive = true
        self.rightLabelConstrint = self.bottomLine.rightAnchor.constraint(equalTo: self.messageBackground.rightAnchor)
        self.leftLabelContraint = self.bottomLine.leftAnchor.constraint(equalTo: self.messageBackground.leftAnchor)
        self.rightLabelConstrint.isActive = true
        self.leftLabelContraint.isActive = true
        
        self.messageBackground.addSubview(self.messageLabel)
        self.messageLabel.rightAnchor.constraint(lessThanOrEqualTo: messageBackground.rightAnchor, constant: -16) .isActive = true
        self.messageLabel.topAnchor.constraint(equalTo: messageBackground.topAnchor, constant: 16).isActive = true
        self.messageLabel.bottomAnchor.constraint(equalTo: messageBackground.bottomAnchor, constant: -16).isActive = true
        self.messageLabel.leftAnchor.constraint(equalTo: messageBackground.leftAnchor, constant: 16).isActive = true
    }
    
    
    func configure(with message: Message, and indent: CGFloat){
        self.sender = message.sender
        
        self.topConstrint.constant = indent
        
        self.messageBackground.backgroundColor = self.sender.backgroundColor
        self.bottomLine.backgroundColor = self.sender.backgroundColor
        
        self.messageLabel.message = message
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
    }
}


//MARK: AnimationCell
class AnimationCell: UICollectionViewCell {
    
    private lazy var centralView = UIView()
    private lazy var rightView = UIView()
    private lazy var leftView = UIView()
    
    private var heightConstrints = [NSLayoutConstraint]()
    
    private var backgroundImageView = UIImageView()
    
    public var isAnimateStart: Bool = false{
        didSet{
            guard oldValue != self.isAnimateStart else { return }
            if isAnimateStart{
                self.startAnimate()
            }else{
                self.stopAnimate()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        self.addSubview(self.backgroundImageView)
        self.backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
        self.backgroundImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.backgroundImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16).isActive = true
        self.backgroundImageView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        self.backgroundImageView.image = UIImage(named: "Menu/Bundle")?.allowTinted
        self.backgroundImageView.tintColor = UIColor(named: "Colors/assisTantColor")
        
        self.addSubview(self.centralView)
        self.addSubview(self.leftView)
        self.leftView.translatesAutoresizingMaskIntoConstraints = false
        self.leftView.centerYAnchor.constraint(equalTo: self.backgroundImageView.centerYAnchor).isActive = true
        self.leftView.widthAnchor.constraint(equalTo: self.leftView.heightAnchor).isActive = true
        let heightConstrint = self.leftView.heightAnchor.constraint(equalToConstant: 4)
        heightConstrint.isActive = true
        self.heightConstrints.append(heightConstrint)
        self.leftView.rightAnchor.constraint(equalTo: self.centralView.leftAnchor, constant: -3).isActive = true
        self.leftView.backgroundColor = UIColor(named: "Colors/assistantTextColor")?.withAlphaComponent(0.4)
        
        self.centralView.translatesAutoresizingMaskIntoConstraints = false
        self.centralView.centerYAnchor.constraint(equalTo: self.backgroundImageView.centerYAnchor).isActive = true
        self.centralView.widthAnchor.constraint(equalTo: self.centralView.heightAnchor).isActive = true
        self.centralView.centerXAnchor.constraint(equalTo: self.backgroundImageView.centerXAnchor).isActive = true
        let heightConstrintCentr = self.centralView.heightAnchor.constraint(equalToConstant: 4)
        heightConstrintCentr.isActive = true
        self.heightConstrints.append(heightConstrintCentr)
        self.centralView.backgroundColor = UIColor(named: "Colors/assistantTextColor")?.withAlphaComponent(0.4)
        
        self.addSubview(self.rightView)
        self.rightView.translatesAutoresizingMaskIntoConstraints = false
        self.rightView.centerYAnchor.constraint(equalTo: self.backgroundImageView.centerYAnchor).isActive = true
        self.rightView.widthAnchor.constraint(equalTo: self.rightView.heightAnchor).isActive = true
        
        let heightConstrintRight = self.rightView.heightAnchor.constraint(equalToConstant: 4)
        heightConstrintRight.isActive = true
        self.heightConstrints.append(heightConstrintRight)
        
        self.rightView.leftAnchor.constraint(equalTo: self.centralView.rightAnchor, constant: 3).isActive = true
        
        self.rightView.backgroundColor = UIColor(named: "Colors/assistantTextColor")?.withAlphaComponent(0.4)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        self.centralView.layer.cornerRadius = self.centralView.frame.height / 2
        self.leftView.layer.cornerRadius = self.leftView.frame.height / 2
        self.rightView.layer.cornerRadius = self.rightView.frame.height / 2
    }
    
    private func stopAnimate(){
        self.layer.removeAllAnimations()
    }
    
    private func startAnimate(){
        guard self.isAnimateStart else { return }
        UIView.animate(withDuration: 0.5) {
            self.heightConstrints[2].constant = 4
            self.heightConstrints[0].constant = 5
            self.rightView.backgroundColor = UIColor(named: "Colors/assistantTextColor")?.withAlphaComponent(0.4)
            self.leftView.backgroundColor = UIColor(named: "Colors/assistantTextColor")
            self.layoutIfNeeded()
        } completion: { (_) in
            UIView.animate(withDuration: 0.5) {
                self.heightConstrints[0].constant = 4
                self.heightConstrints[1].constant = 5
                self.leftView.backgroundColor = UIColor(named: "Colors/assistantTextColor")?.withAlphaComponent(0.4)
                self.centralView.backgroundColor = UIColor(named: "Colors/assistantTextColor")
                self.layoutIfNeeded()
            } completion: { (_) in
                UIView.animate(withDuration: 0.5) {
                    self.heightConstrints[1].constant = 4
                    self.heightConstrints[2].constant = 5
                    self.centralView.backgroundColor = UIColor(named: "Colors/assistantTextColor")?.withAlphaComponent(0.4)
                    self.rightView.backgroundColor = UIColor(named: "Colors/assistantTextColor")
                    self.layoutIfNeeded()
                } completion: { (_) in
                    self.startAnimate()
                }
            }
        }
    }
    
}

//MARK: SimpleCell
extension DialogViewController{
    class SimpleCell: UICollectionViewCell{
        
        private var label = UILabel()
        
        public var title: String = ""{
            didSet{
                self.label.text = self.title
            }
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            self.heightAnchor.constraint(equalToConstant: 64).isActive = true
            
            self.addSubview(self.label)
            self.label.translatesAutoresizingMaskIntoConstraints = false
            self.label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            self.label.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            self.label.textColor = UIColor(named: "Colors/headerColor") ?? UIColor(r: 21, g: 31, b: 73, a: 0.3)
            self.label.font = UIFont.systemFont(ofSize: 12)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            self.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        }
    }
}
//MARK: InteractiveLinkLabel
class InteractiveLinkLabel: UILabel {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.configure()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configure()
    }
    
    private func configure() {
        self.isUserInteractionEnabled = true
    }
    
    private var ranges: [NSRange : String] = [:]
    
    public var message: Message = Message(title: ""){
        didSet{
            self.textColor = message.sender.messageColor
            
            guard self.message.title != self.message.title.html2String else {self.text = message.title.html2String; return }
            
            let muttableAttributedString = NSMutableAttributedString(string: message.title.html2String, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor: message.sender.messageColor])
            
            guard let att = message.title.html2AttributedString else { self.text = message.title.html2String; return }
            let wholeRange = NSRange((att.string.startIndex...), in: att.string)
            att.enumerateAttribute(.link, in: wholeRange, options: []) { (value, range, pointee) in
                guard value != nil else { return }
                muttableAttributedString.addAttributes([NSAttributedString.Key.foregroundColor : UIColor.blue], range: range)
                self.attributedText = muttableAttributedString
            }
            
            self.attributedText = muttableAttributedString
            self.ranges.removeAll()
            let ranges = self.checkUserLinks(firstText: self.message.title.html2String, text: self.message.title)
            for range in ranges{
                let rangeVal = NSRange(range, in: self.message.title.html2String)
                muttableAttributedString.addAttributes([NSAttributedString.Key.foregroundColor : UIColor.blue], range: rangeVal)
                let text = self.message.title.html2String[range]
                self.ranges[rangeVal] = String(text)
                self.attributedText = muttableAttributedString
            }
        }
    }
    
    func checkUserLinks(firstText: String, text: String, ranges: [Range<String.Index>] = [] ) -> [Range<String.Index>]{
        
        guard let low = text.range(of: "<userlink>")?.upperBound,
              let upper = text.range(of: "</userlink>")?.lowerBound,
              let upperforRemove = text.range(of: "</userlink>")?.upperBound else { return ranges}
        let textBtn = text[low..<upper]
        var rangeArray = ranges
        if let range = firstText.range(of: textBtn) {
            rangeArray.append(range)
        }
        return self.checkUserLinks(firstText: firstText,text: String(text[upperforRemove...]), ranges: rangeArray)
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard self.text != nil else { return false}
        
        let superBool = super.point(inside: point, with: event)
        
        // Configure NSTextContainer
        let textContainer = NSTextContainer(size: self.frame.size)
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = lineBreakMode
        textContainer.maximumNumberOfLines = self.numberOfLines
        
        // Configure NSLayoutManager and add the text container
        let layoutManager = NSLayoutManager()
        layoutManager.addTextContainer(textContainer)
        
        guard let attributedText = attributedText else {return false}
        
        // Configure NSTextStorage and apply the layout manager
        let textStorage = NSTextStorage(attributedString: attributedText)
        textStorage.addAttribute(NSAttributedString.Key.font, value: font!, range: NSMakeRange(0, attributedText.length))
        textStorage.addLayoutManager(layoutManager)
        
        // get the tapped character location
        let locationOfTouchInLabel = point
        
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x -  2, y: locationOfTouchInLabel.y - 2)
        
        // work out which character was tapped
        var characterIndex = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        let attributeName = NSAttributedString.Key.link
        characterIndex += characterIndex == 0 ? 0 : -1
        // work out how many characters are in the string up to and including the line tapped, to ensure we are not off the end of the character string
        let lineTapped = Int(ceil(locationOfTouchInLabel.y / font.lineHeight)) 
        let rightMostPointInLineTapped = CGPoint(x: bounds.size.width, y: font.lineHeight * CGFloat(lineTapped))
        let charsInLineTapped = layoutManager.characterIndex(for: rightMostPointInLineTapped, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        guard characterIndex < charsInLineTapped else {return false}
        
        for range in self.ranges{
            guard range.key.contains(characterIndex) else { continue }
            let message = Message(title: range.value, sender: .user)
            DataManager.shared.saveNew(message)
            NetworkManager.shared.sendMessage(cuid: DataManager.shared.currentAssistants.cuid.string, message: range.value) { (msg, error) in
                guard error == nil else { return }
                guard let messg = msg else { return }
                let message = Message(title: messg, sender: .assistant)
                DataManager.shared.saveNew(message)
            }
        }
        
        let attributeValue = self.message.title.html2AttributedString!.attribute(attributeName, at: characterIndex, effectiveRange: nil)
        
        guard let value = attributeValue as? URL  else { return false }
        var fakeURLString = value.absoluteString
        guard let range = fakeURLString.range(of: "http") else{ return false}
        let startIndex = range.lowerBound
        fakeURLString.removeSubrange(..<startIndex)
        guard let url = URL(string: fakeURLString) else { return false}
        UIApplication.shared.open(url)
        
        return superBool
        
    }
}
