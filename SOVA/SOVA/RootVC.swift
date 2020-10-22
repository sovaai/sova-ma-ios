//
//  RootVC.swift
//  SOVA
//
//  Created by Мурат Камалов on 20.10.2020.
//

import UIKit
import Network

class PageViewController: UIPageViewController{
    
    static var shared = PageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [UIPageViewController.OptionsKey.interPageSpacing : 0])
    
    private override init(transitionStyle style: UIPageViewController.TransitionStyle, navigationOrientation: UIPageViewController.NavigationOrientation, options: [UIPageViewController.OptionsKey : Any]? = nil) {
        super.init(transitionStyle: style, navigationOrientation: navigationOrientation, options: options)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Buttons
    private var settingsBtn = UIButton()
    private var recordingBtn = AudioBtn()
    private var keyboardBtn = UIButton()
    
    
    //MARK: TextField
    private var textFieldBottomConstant: NSLayoutConstraint? = nil
    
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
    
    
    //MARK: Connection
    private lazy var intetnetView: NoInternetConnectionView = {
       let view = NoInternetConnectionView()
        self.view.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        view.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        view.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        view.isHidden = true
        
        return view
    }()
    
    internal var internetConnection: ConntectionState = .correct {
        didSet{
            guard oldValue != self.internetConnection else { return }
            DispatchQueue.main.async {
                self.intetnetView.configure(with: self.internetConnection)
            }
        }
    }
    
    //MARK: Managers
    private var audioManager = AudioManager()
    
    //MARK: VC
    private var dilogVc: DialogViewController = DialogViewController.shared
    private var animateVC: AnimateVC = AnimateVC.shared
    
    private var curentVC: UIViewController = DialogViewController.shared
    
    private var nextVC: UIViewController {
        get{
            return self.curentVC is DialogViewController ? self.animateVC : self.dilogVc
        }
    }
    
    
    //MARK: VC's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.uiSetUp()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        let monitor = NWPathMonitor()
        
        monitor.pathUpdateHandler = { path in
            self.internetConnection = path.status == .satisfied ? .correct : .incorrect
        }
        
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
        
        self.audioManager.errorDelegate = self
        self.audioManager.recordDelegate = self
        
//        self.audioManager
    
    }
    
    func uiSetUp(){
        self.dataSource = self
        self.delegate = self
        self.navigationController?.navigationBar.isHidden = true
        self.setViewControllers([self.dilogVc], direction: .forward, animated: true, completion: nil)
        
        self.view.addSubview(self.recordingBtn)
        self.recordingBtn.translatesAutoresizingMaskIntoConstraints = false
        self.recordingBtn.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.recordingBtn.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: 15).isActive = true
        self.recordingBtn.heightAnchor.constraint(equalToConstant: 94).isActive = true
        self.recordingBtn.widthAnchor.constraint(equalTo: self.recordingBtn.heightAnchor).isActive = true
                
        self.recordingBtn.addTarget(self, action: #selector(self.recodingAction), for: .touchUpInside)
        
        self.view.addSubview(self.settingsBtn)
        self.settingsBtn.translatesAutoresizingMaskIntoConstraints = false
        self.settingsBtn.rightAnchor.constraint(equalTo: self.recordingBtn.leftAnchor, constant: -15).isActive = true
        self.settingsBtn.centerYAnchor.constraint(equalTo: self.recordingBtn.centerYAnchor).isActive = true
        self.settingsBtn.heightAnchor.constraint(equalToConstant: 24).isActive = true
        self.settingsBtn.widthAnchor.constraint(equalTo: self.settingsBtn.heightAnchor).isActive = true
        
        self.settingsBtn.setImage(UIImage(named: "Menu/settingsBtn")?.allowTinted, for: .normal)
        self.settingsBtn.tintColor = UIColor(named: "Colors/textColor")
        self.settingsBtn.addTarget(self, action: #selector(self.openSettings), for: .touchUpInside)
        
        self.view.addSubview(self.keyboardBtn)
        self.keyboardBtn.translatesAutoresizingMaskIntoConstraints = false
        self.keyboardBtn.centerYAnchor.constraint(equalTo: self.recordingBtn.centerYAnchor).isActive = true
        self.keyboardBtn.leftAnchor.constraint(equalTo: self.recordingBtn.rightAnchor, constant: 15).isActive = true
        self.keyboardBtn.heightAnchor.constraint(equalToConstant: 24).isActive = true
        self.keyboardBtn.widthAnchor.constraint(equalTo: self.keyboardBtn.heightAnchor).isActive = true
        
        self.keyboardBtn.tintColor = UIColor(named: "Colors/textColor")
        self.keyboardBtn.setImage(UIImage(named: "Menu/keyboardBtn")?.allowTinted, for: [])
        self.keyboardBtn.addTarget(self, action: #selector(self.keyboardAction(sender:)), for: .touchUpInside)
    }
    
    
    //MARK: Btn actions
    
    @objc func recodingAction(){
        self.audioManager.isRecording = !self.audioManager.isRecording
    }
    
    @objc func keyboardAction(sender: Any){
        guard !(sender is UITapGestureRecognizer) else {
            self.textField.keyboardIsHide = true
            self.textFieldBottomConstant?.constant = 0
            guard self.curentVC is DialogViewController else { return }
            self.dilogVc.bottomCollectionView?.constant = -70
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
        guard self.curentVC is DialogViewController else { return }
        self.dilogVc.bottomCollectionView?.constant = -keyboardHeight - 20
    }
        
}

extension PageViewController: UIPageViewControllerDataSource{
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return self.nextVc()
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return self.nextVc()
    }
    
    func nextVc() -> UIViewController{
        self.textField.keyboardIsHide = true
        let nextVC = self.nextVC
        if nextVC is DialogViewController{
            self.dilogVc.bottomCollectionView?.constant = -70
        }
        return nextVC
    }
}

extension PageViewController: UIPageViewControllerDelegate{
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed else { return }
        self.curentVC = self.nextVC
    }

}


extension PageViewController: AudioErrorDelegate{
    func audioErrorMessage(title: String) {
        self.showSimpleAlert(title: title)
    }
    
    func allowAlert() {
        let alert = UIAlertController(title: "Разрешите доступ к микрофону".localized, message: nil, preferredStyle: .alert)
        let openSettings = UIAlertAction(title: "Открыть настройки".localized, style: .default) { (_) in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
        }
        let cancel = UIAlertAction(title: "Отмена".localized, style: .destructive)
        alert.addAction(cancel)
        alert.addAction(openSettings)
        
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    
}

extension PageViewController: AudioRecordingDelegate{
    func speechState(state: AudioState) {
        DispatchQueue.main.async {
            self.animateVC.speechState(state: state)
            self.dilogVc.speechState(state: state)
        }
    }
    
    func recording(state: AudioState) {
        DispatchQueue.main.async {
            self.recordingBtn.audioState(is: state)
        }
    }
}
