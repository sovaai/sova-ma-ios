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
    
    private lazy var textField: DialogTextField = {
        let tf = DialogTextField()
        self.view.addSubview(tf)
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        tf.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        tf.heightAnchor.constraint(greaterThanOrEqualToConstant: 50).isActive = true
        self.textFieldBottomConstant =  tf.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
        self.textFieldBottomConstant?.isActive = true
        tf.isHidden = true
        let tapGest = UITapGestureRecognizer(target: self, action: #selector(self.keyboardAction(sender:)))
        self.view.addGestureRecognizer(tapGest)
        self.view.layoutIfNeeded()
        tf.centerVertically()
        return tf
    }()
    
    private var textFieldBottomConstant: NSLayoutConstraint? = nil
    private var bottomCollectionView: NSLayoutConstraint? = nil
    
    private var settingsBtn = UIButton()
    private var recordingBtn = AudioBtn()
    private var keyboardBtn = UIButton()
    
    private var messageList = DataManager.shared.messageList //Array(DataManager.shared.currentAssistants.messageList.reversed()).sorted{$0.date > $1.date}
    
    private var audioManager = AudioManager()
    
    private var isSpeechRegonizing: Bool = false
    
    
    private var animateComplition: (() -> ())? = nil
    //-----------------------------------------------------------------------------------------------------------------------------
    //MARK: TEST
    //-----------------------------------------------------------------------------------------------------------------------------
    
    lazy var testSwitch: UISwitch = {
        let sw = UISwitch()
        self.view.addSubview(sw)
        sw.translatesAutoresizingMaskIntoConstraints = false
        sw.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 40).isActive = true
        sw.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 10).isActive = true
        sw.addTarget(self, action: #selector(self.selector), for: .allEvents)
        return sw
    }()
    
    lazy var playAudioBtn: UIButton = {
        let btn = UIButton()
        self.view.addSubview(btn)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.topAnchor.constraint(equalTo: self.testSwitch.bottomAnchor, constant: 5).isActive = true
        btn.leftAnchor.constraint(equalTo: self.testSwitch.leftAnchor).isActive = true
        btn.heightAnchor.constraint(equalTo: self.testSwitch.heightAnchor).isActive = true
        btn.widthAnchor.constraint(equalTo: self.testSwitch.widthAnchor).isActive = true
        btn.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        btn.addTarget(self, action: #selector(self.playAudio), for: .touchUpInside)
        btn.layer.cornerRadius = self.testSwitch.frame.height / 2
        return btn
    }()
    
    static var sender: WhosMessage = .user
    
    @objc func selector(){
        guard DialogViewController.sender == .user else {
            DialogViewController.sender = .user
            return
        }
        DialogViewController.sender = .assistant
    }
    
    @objc func playAudio(){
        self.audioManager.playSpeech(with: "Hellow")
    }
    
    //-----------------------------------------------------------------------------------------------------------------------------
    //MARK: TEST
    //-----------------------------------------------------------------------------------------------------------------------------
    
    private var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.doesRelativeDateFormatting = true
        return df
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        
        self.view.addSubview(self.collectionView)
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
        self.collectionView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.collectionView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.bottomCollectionView = self.collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        self.bottomCollectionView?.isActive = true
        
        self.collectionView.backgroundColor = .white
        
        self.collectionView.register(DialogCell.self, forCellWithReuseIdentifier: "dialogCell")
        self.collectionView.register(SimpleCell.self, forCellWithReuseIdentifier: "header")
        self.collectionView.register(AnimationCell.self, forCellWithReuseIdentifier: "animationCell")
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.collectionView.transform = CGAffineTransform.init(rotationAngle: (-(CGFloat)(Double.pi)))
        
        self.collectionView.contentInset = UIEdgeInsets(top: 124, left: 0, bottom: 0, right: 0)
        
        self.view.addSubview(self.recordingBtn)
        self.recordingBtn.translatesAutoresizingMaskIntoConstraints = false
        self.recordingBtn.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.recordingBtn.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
        self.recordingBtn.heightAnchor.constraint(equalToConstant: 94).isActive = true
        self.recordingBtn.widthAnchor.constraint(equalTo: self.recordingBtn.heightAnchor).isActive = true
        
        self.recordingBtn.addTarget(self, action: #selector(self.recodingAction), for: .touchUpInside)
        self.audioManager.delegate = self
        
        self.view.addSubview(self.settingsBtn)
        self.settingsBtn.translatesAutoresizingMaskIntoConstraints = false
        self.settingsBtn.rightAnchor.constraint(equalTo: self.recordingBtn.leftAnchor, constant: -15).isActive = true
        self.settingsBtn.centerYAnchor.constraint(equalTo: self.recordingBtn.centerYAnchor).isActive = true
        self.settingsBtn.heightAnchor.constraint(equalToConstant: 24).isActive = true
        self.settingsBtn.widthAnchor.constraint(equalTo: self.settingsBtn.heightAnchor).isActive = true
        
        self.settingsBtn.setImage(UIImage(named: "Menu/settingsBtn"), for: .normal)
        self.settingsBtn.addTarget(self, action: #selector(self.openSettings), for: .touchUpInside)
        
        self.view.addSubview(self.keyboardBtn)
        self.keyboardBtn.translatesAutoresizingMaskIntoConstraints = false
        self.keyboardBtn.centerYAnchor.constraint(equalTo: self.recordingBtn.centerYAnchor).isActive = true
        self.keyboardBtn.leftAnchor.constraint(equalTo: self.recordingBtn.rightAnchor, constant: 15).isActive = true
        self.keyboardBtn.heightAnchor.constraint(equalToConstant: 24).isActive = true
        self.keyboardBtn.widthAnchor.constraint(equalTo: self.keyboardBtn.heightAnchor).isActive = true
        
        self.keyboardBtn.setImage(UIImage(named: "Menu/keyboardBtn"), for: [])
        self.keyboardBtn.addTarget(self, action: #selector(self.keyboardAction(sender:)), for: .touchUpInside)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadData), name: NSNotification.Name.init("MessagesUpdate"), object: nil)
        
        self.testSwitch.isOn = true
        self.playAudioBtn.setTitle("play", for: [])
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

    
    //MARK: Btn actions
    
    @objc func recodingAction(){
        self.audioManager.isRecording = !self.audioManager.isRecording
    }
    
    @objc func keyboardAction(sender: Any){
        guard !(sender is UITapGestureRecognizer) else {
            self.textField.keyboardIsHide = true
            self.bottomCollectionView?.constant = 0
            self.textFieldBottomConstant?.constant = 0
            return
        }
        guard sender is UIButton else { return }
        self.textField.keyboardIsHide = false
    }
    
    @objc func openSettings(){
        SettingsVC.show(in: self.navigationController ?? self)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else{ return }
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        self.textFieldBottomConstant?.constant = -keyboardHeight
        self.bottomCollectionView?.constant = -keyboardHeight
        
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
            cell.startAnimate()
            self.animateComplition = { cell.stopAnimate() }
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


extension DialogViewController: AudioDelegate{
    func audioErrorMessage(title: String) {
        self.showSimpleAlert(title: title)
    }
    
    func allowAlert() {
        let alert = UIAlertController(title: "Разрешите доступ к микрофону".localized, message: nil, preferredStyle: .alert)
        let openSettings = UIAlertAction(title: "Открыть настройки", style: .default) { (_) in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
        }
        let cancel = UIAlertAction(title: "Отмена".localized, style: .destructive)
        alert.addAction(cancel)
        alert.addAction(openSettings)
        self.present(alert, animated: true)
    }
    
    func recording(state: AudioState) {
        self.recordingBtn.audioState(is: state)
    }
    
    func speechState(state: AudioState) {
        DispatchQueue.main.async {
            self.isSpeechRegonizing = state == .start
            guard state == .stop else { return }
            self.animateComplition?()
        }
    }
}







