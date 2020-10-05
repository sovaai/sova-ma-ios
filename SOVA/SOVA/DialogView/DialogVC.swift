//
//  DialogVC.swift
//  SOVA
//
//  Created by Мурат Камалов on 02.10.2020.
//

import UIKit

class DialogViewController: UIViewController{
    
    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        let cv = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        cv.isPagingEnabled = true
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        return cv
    }()
    
    private var settingsBtn = UIButton()
    private var recordingBtn = UIButton()
    private var keyboardBtn = UIButton()
    
    private var messageList = Array(Assitant.currentAssistants.messageList.reversed()).sorted{$0.date > $1.date}
    
    private var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.doesRelativeDateFormatting = true
        return df
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.navigationController?.navigationBar.isHidden = true
        
        self.view.addSubview(self.collectionView)
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        self.collectionView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.collectionView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        self.collectionView.backgroundColor = .white
        
        self.collectionView.register(DialogCell.self, forCellWithReuseIdentifier: "dialogCell")
        self.collectionView.register(SimpleCell.self, forCellWithReuseIdentifier: "header")
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.collectionView.transform = CGAffineTransform.init(rotationAngle: (-(CGFloat)(Double.pi)))
        
        self.collectionView.contentInset = UIEdgeInsets(top: 124, left: 0, bottom: 0, right: 0)
        
        self.view.addSubview(self.recordingBtn)
        self.recordingBtn.translatesAutoresizingMaskIntoConstraints = false
        self.recordingBtn.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.recordingBtn.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
        self.recordingBtn.heightAnchor.constraint(equalToConstant: 60).isActive = true
        self.recordingBtn.widthAnchor.constraint(equalTo: self.recordingBtn.heightAnchor).isActive = true
        
        self.recordingBtn.setImage(UIImage(named: "Menu/recordingbtn"), for: [])
        
        self.view.addSubview(self.settingsBtn)
        self.settingsBtn.translatesAutoresizingMaskIntoConstraints = false
        self.settingsBtn.rightAnchor.constraint(equalTo: self.recordingBtn.leftAnchor, constant: -32).isActive = true
        self.settingsBtn.centerYAnchor.constraint(equalTo: self.recordingBtn.centerYAnchor).isActive = true
        self.settingsBtn.heightAnchor.constraint(equalToConstant: 24).isActive = true
        self.settingsBtn.widthAnchor.constraint(equalTo: self.settingsBtn.heightAnchor).isActive = true
        
        self.settingsBtn.setImage(UIImage(named: "Menu/settingsBtn"), for: [])
        self.settingsBtn.addTarget(self, action: #selector(self.openSettings), for: .touchUpInside)
        
        self.view.addSubview(self.keyboardBtn)
        self.keyboardBtn.translatesAutoresizingMaskIntoConstraints = false
        self.keyboardBtn.centerYAnchor.constraint(equalTo: self.recordingBtn.centerYAnchor).isActive = true
        self.keyboardBtn.leftAnchor.constraint(equalTo: self.recordingBtn.rightAnchor, constant: 32).isActive = true
        self.keyboardBtn.heightAnchor.constraint(equalToConstant: 24).isActive = true
        self.keyboardBtn.widthAnchor.constraint(equalTo: self.keyboardBtn.heightAnchor).isActive = true
        
        self.keyboardBtn.setImage(UIImage(named: "Menu/keyboardBtn"), for: [])
    }
    

    @objc func openSettings(){
        SettingsVC.show(in: self.navigationController ?? self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.collectionView.scrollToItem(at: IndexPath(row: self.messageList.last?.messages.count ?? 0, section: self.messageList.count), at: .bottom, animated: true)
    }
    
}

extension DialogViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.messageList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messageList[section].messages.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard self.messageList[indexPath.section].messages.count != indexPath.row else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "header", for: indexPath) as? SimpleCell  else { return UICollectionViewCell() }
            cell.title = self.dateFormatter.string(from: self.messageList[indexPath.section].date)
            return cell
        }
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dialogCell", for: indexPath) as? DialogCell else { return UICollectionViewCell() }
        let messages = self.messageList[indexPath.section].messages
        let message = messages[indexPath.row]
        let indent: CGFloat
        if indexPath.row >= messages.count - 1{
            indent = 8
        }else{
            let beforeMessageSender = self.messageList[indexPath.section].messages[indexPath.row + 1].sender
            indent = beforeMessageSender == message.sender ? 8 : 24
        }
        cell.configure(with: message, and: indent)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: self.view.frame.width, height: 44)
    }
    
}





