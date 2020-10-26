//
//  DialogVC.swift
//  SOVA
//
//  Created by Мурат Камалов on 02.10.2020.
//

import UIKit

class DialogViewController: UIViewController{
    
    static var shared = DialogViewController()
    
    private lazy var tableView: UITableView =   UITableView(frame: .zero, style: .grouped)
    
    public var isActive: Bool = false {
        didSet{
            guard self.isActive else{ return }
            self.tableView.reloadData()
        }
    }
    
    internal private(set) var bottomCollectionView: NSLayoutConstraint? = nil
    
    private var messageList = DataManager.shared.messageList //Array(DataManager.shared.currentAssistants.messageList.reversed()).sorted{$0.date > $1.date}
    
    internal var isSpeechRegonizing: Bool = false
    private var isScrolling: Bool = false
    
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
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.animateComplition?()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.init("MessagesUpdate"), object: nil)
    }
    
    
    private func uiSetUp(){
        self.view.backgroundColor = UIColor(named: "Colors/mainbacground")
        
        self.view.addSubview(self.tableView)
        //        self.view.addSubview(self.btnsCollectionView)
        
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        self.tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.bottomCollectionView = self.tableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -70)
        
        self.bottomCollectionView?.isActive = true
        
        self.tableView.register(DialogCell.self, forCellReuseIdentifier: WhosMessage.user.rawValue)
        self.tableView.register(DialogCell.self, forCellReuseIdentifier: WhosMessage.assistant.rawValue)
        self.tableView.register(SimpleCell.self, forCellReuseIdentifier: "header")
        self.tableView.register(AnimationCell.self, forCellReuseIdentifier: "animationCell")
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        self.tableView.separatorStyle = .none
        self.tableView.allowsSelection = false
        self.tableView.showsVerticalScrollIndicator = false
        
        self.tableView.backgroundColor = UIColor(named: "Colors/mainbacground")
    }
    
    @objc func reloadData(notification: Notification){
        guard self.isActive else { return }
        DispatchQueue.main.async {
            if DataManager.shared.messageList.count == 0 || self.messageList.count == 0 || self.messageList[0].id != DataManager.shared.messageList[0].id {
                self.messageList = DataManager.shared.messageList
                self.tableView.reloadData()
            }else{
                self.messageList = DataManager.shared.messageList
                self.tableView.insertRows(at: [IndexPath(row: self.isSpeechRegonizing ? 1 : 0, section: 0)], with: .automatic)
            }
        }
    }
    
    func speechState(state: AudioState) {
        guard self.isActive else { return }
        DispatchQueue.main.async {
            self.isSpeechRegonizing = state != .stop
            if self.isSpeechRegonizing{
                self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            }else{
                self.animateComplition?()
                self.tableView.deleteRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            }
        }
    }
}

extension DialogViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.messageList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messageList[section].messages.count + 1 + (self.isSpeechRegonizing ? (section == 0 ? 1 : 0) : 0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath != IndexPath(row: 0, section: 0) || !self.isSpeechRegonizing else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "animationCell", for: indexPath) as? AnimationCell  else { return UITableViewCell() }
            cell.isAnimateStart = true
            self.animateComplition = { cell.isAnimateStart = false }
            return cell
        }
        guard self.messageList[indexPath.section].messages.count + (self.isSpeechRegonizing && indexPath.section == 0 ? 1 : 0) != indexPath.row else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "header", for: indexPath) as? SimpleCell  else { return UITableViewCell() }
            cell.title = self.dateFormatter.string(from: self.messageList[indexPath.section].date)
            return cell
        }
        
        let messages = self.messageList[indexPath.section].messages
        let message = messages[messages.count - indexPath.row - 1 - (self.isSpeechRegonizing && indexPath.section == 0 ? -1 : 0)]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: message.sender.rawValue, for: indexPath) as? DialogCell else { return UITableViewCell() }
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
        
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.isScrolling = true
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        self.isScrolling = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self, !self.isScrolling else { return }
            let cells = self.tableView.visibleCells
            cells.forEach{($0 as? DialogCell)?.messageLabel.addLinks()}
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print(decelerate)
    }
    
}





