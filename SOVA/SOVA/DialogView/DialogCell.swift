//
//  DialogCell.swift
//  SOVA
//
//  Created by Мурат Камалов on 02.10.2020.
//

import UIKit
import Foundation

//MARK: DialogCell
class DialogCell: UITableViewCell{
    
    //----------------------------------------------------------------------------------------------------------------
    
    //MARK: UI
    
    //----------------------------------------------------------------------------------------------------------------
    
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
    
    fileprivate var bottomLine = UIView()
    
    //----------------------------------------------------------------------------------------------------------------
    
    //MARK: Constraint
    
    //----------------------------------------------------------------------------------------------------------------
    
    fileprivate var leftConstraint: NSLayoutConstraint!
    fileprivate var rightConstraint: NSLayoutConstraint!
    fileprivate var topConstrint: NSLayoutConstraint!
    
    fileprivate var rightLabelConstrint: NSLayoutConstraint!
    fileprivate var leftLabelContraint: NSLayoutConstraint!
    
    //----------------------------------------------------------------------------------------------------------------
    
    //MARK: Another
    
    //----------------------------------------------------------------------------------------------------------------
    
    public var url: URL? = nil
    
    fileprivate var sender: WhosMessage = .user{
        didSet{
            self.leftLabelContraint.constant = self.sender == .user ? 0 : 16
            self.rightLabelConstrint.constant = self.sender == .user ? -16 : 0
            self.leftConstraint.isActive = self.sender == .user
            self.rightConstraint.isActive = self.sender != .user
        }
    }
    
    //----------------------------------------------------------------------------------------------------------------
    
    //MARK: Init
    
    //----------------------------------------------------------------------------------------------------------------
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        guard reuseIdentifier != nil, let sender = WhosMessage(rawValue: reuseIdentifier!) else { return }
        self.messageLabel.textColor = sender.messageColor
        
        self.setUp()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    fileprivate func setUp(){
        self.backgroundColor = UIColor(named: "Colors/mainbacground")
        
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
        self.bottomLine.topAnchor.constraint(equalTo: self.messageBackground.topAnchor).isActive = true
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
        
        self.messageLabel.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
    }
    
    //----------------------------------------------------------------------------------------------------------------
    
    //MARK: Configure
    
    //----------------------------------------------------------------------------------------------------------------
    
    func configure(with message: Message, and indent: CGFloat){
        self.sender = message.sender
        
        self.topConstrint.constant = indent
        
        self.messageBackground.backgroundColor = self.sender.backgroundColor
        self.bottomLine.backgroundColor = self.sender.backgroundColor
        
        self.messageLabel.message = message
    }
    
}

//----------------------------------------------------------------------------------------------------------------

//MARK: InteractiveLinkLabel

//----------------------------------------------------------------------------------------------------------------

class InteractiveLinkLabel: UILabel {
    
    //----------------------------------------------------------------------------------------------------------------

    //MARK: Init

    //----------------------------------------------------------------------------------------------------------------
    
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
    
    //----------------------------------------------------------------------------------------------------------------

    //MARK: Title setUp

    //----------------------------------------------------------------------------------------------------------------
    
    public var message: Message = Message(text: ""){
        didSet{
            self.text = self.message.title ?? self.message.text.html2String
            
            guard self.message.title == nil, self.message.sender != .user, !self.message.ranges.isEmpty else { return }
            guard self.message.text != self.message.text.html2String else {
                self.message.title = self.message.text
                self.message.save()
                return
            }
                    
            let muttableAttributedString = NSMutableAttributedString(string: message.text.html2String, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor: message.sender.messageColor])

            for range in self.message.ranges.keys{
                muttableAttributedString.addAttributes([NSAttributedString.Key.foregroundColor : UIColor.blue], range: range)
                self.attributedText = muttableAttributedString
            }
        }
    }
    
    //----------------------------------------------------------------------------------------------------------------

    //MARK: Touch

    //----------------------------------------------------------------------------------------------------------------
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard event?.type == .touches, self.text != nil else { return false}
        
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
        
        characterIndex += characterIndex == 0 ? 0 : -1
        // work out how many characters are in the string up to and including the line tapped, to ensure we are not off the end of the character string
        let lineTapped = Int(ceil(locationOfTouchInLabel.y / font.lineHeight)) 
        let rightMostPointInLineTapped = CGPoint(x: bounds.size.width, y: font.lineHeight * CGFloat(lineTapped))
        let charsInLineTapped = layoutManager.characterIndex(for: rightMostPointInLineTapped, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        guard characterIndex < charsInLineTapped else {return false}
        
        for range in self.message.ranges{
            guard range.key.contains(characterIndex) else { continue }
            if let url = URL(string: range.value) {
                UIApplication.shared.open(url)
                break
            }
            let message = Message(text: range.value, sender: .user)
            DataManager.shared.saveNew(message)
            NetworkManager.shared.sendMessage(cuid: DataManager.shared.currentAssistants.cuid.string, message: range.value) { (msg,animation, error) in
                guard error == nil else { return }
                AnimateVC.shared.configure(with: animation)
                guard let messg = msg else { return }
                let message = Message(text: messg, sender: .assistant)
                DataManager.shared.saveNew(message)
            }
            break
        }
        
        return superBool
        
    }
}
