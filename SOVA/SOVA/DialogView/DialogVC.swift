//
//  DialogVC.swift
//  SOVA
//
//  Created by Мурат Камалов on 02.10.2020.
//

import UIKit

class DialogViewController: UIViewController{
    
    static var shared = DialogViewController()
    
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
    
    internal private(set) var bottomCollectionView: NSLayoutConstraint? = nil
    
    private var messageList = DataManager.shared.messageList //Array(DataManager.shared.currentAssistants.messageList.reversed()).sorted{$0.date > $1.date}
        
    internal var isSpeechRegonizing: Bool = false
    
    
    private var animateComplition: (() -> ())? = nil
    
//    private var btnsCollectionView = BtnsCollectonView()
    
    private var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.doesRelativeDateFormatting = true
        return df
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.uiSetUp()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadData), name: NSNotification.Name.init("MessagesUpdate"), object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        self.collectionView.scrollToItem(at: IndexPath(row: self.messageList.last?.messages.count ?? 0, section: self.messageList.count), at: .bottom, animated: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.init("MessagesUpdate"), object: nil)
    }

    
    func uiSetUp(){
        self.view.backgroundColor = UIColor(named: "Colors/mainbacground")
        
        self.view.addSubview(self.collectionView)
//        self.view.addSubview(self.btnsCollectionView)

        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        self.collectionView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.collectionView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.bottomCollectionView = self.collectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -70)
        self.bottomCollectionView?.isActive = true
        
        self.collectionView.backgroundColor = UIColor(named: "Colors/mainbacground")
        
        self.collectionView.register(DialogCell.self, forCellWithReuseIdentifier: "dialogCell")
        self.collectionView.register(SimpleCell.self, forCellWithReuseIdentifier: "header")
        self.collectionView.register(AnimationCell.self, forCellWithReuseIdentifier: "animationCell")
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.collectionView.transform = CGAffineTransform.init(rotationAngle: (-(CGFloat)(Double.pi)))
        
//        self.btnsCollectionView.translatesAutoresizingMaskIntoConstraints = false
//        self.btnsCollectionView.bottomAnchor.constraint(equalTo: self.recordingBtn.topAnchor, constant: 0).isActive = true
//        self.btnsCollectionView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
//        self.btnsCollectionView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
//        self.btnsCollectionView.heightAnchor.constraint(equalToConstant: 0).isActive = true
        
    }
    
    @objc func reloadData(notification: Notification){
        self.messageList = DataManager.shared.messageList
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
}

extension DialogViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.messageList.count + (self.isSpeechRegonizing ? 1 : 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard section != 0 || !self.isSpeechRegonizing else { return 1}
        return self.messageList[section - (self.isSpeechRegonizing ? 1 : 0)].messages.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard indexPath.section != 0 || !self.isSpeechRegonizing else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "animationCell", for: indexPath) as? AnimationCell  else { return UICollectionViewCell() }
            cell.isAnimateStart = true
            self.animateComplition = { cell.isAnimateStart = false }
            return cell
        }
        let section = indexPath.section - (self.isSpeechRegonizing ? 1 : 0)
        guard self.messageList[section].messages.count != indexPath.row else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "header", for: indexPath) as? SimpleCell  else { return UICollectionViewCell() }
            cell.title = self.dateFormatter.string(from: self.messageList[section].date)
            return cell
        }
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dialogCell", for: indexPath) as? DialogCell else { return UICollectionViewCell() }
        let messages = self.messageList[section].messages
        let message = messages[messages.count - indexPath.row - 1]
        let indent: CGFloat
        if indexPath.row >= messages.count - 1{
            indent = 8
        }else{
            let beforeMessageSender = self.messageList[section].messages[indexPath.row + 1].sender
            indent = beforeMessageSender == message.sender ? 8 : 24
        }
        cell.configure(with: message, and: indent)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: self.view.frame.width, height: 44)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? DialogCell,
              let url = cell.url else { return }
        UIApplication.shared.open(url)
    }
    
}


extension DialogViewController: AudioAnimateDelegate{
    func speechState(state: AudioState) {
        DispatchQueue.main.async {
            self.isSpeechRegonizing = state == .start
            self.collectionView.reloadData()
            guard state == .stop else { return }
            self.animateComplition?()
        }
    }
}





