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
    //    private var tableView = UITableView(frame: .zero, style: .grouped)
    
    private var messageList = Assitant.currentAssistants.messageList
    
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
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        collectionView.transform = CGAffineTransform.init(rotationAngle: (-(CGFloat)(Double.pi)))
        
        let btn = UIButton()
        self.view.addSubview(btn)
        btn.frame = CGRect(x: 10, y: 10, width: 100, height: 100)
        btn.backgroundColor = .green
        btn.addTarget(self, action: #selector(self.action), for: .touchUpInside)
    }
    
    @objc func action(){
        self.collectionView.reloadData()
        
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
        return self.messageList[section].messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dialogCell", for: indexPath) as? DialogCell else { return UICollectionViewCell() }
        let message = self.messageList[indexPath.section].messages[indexPath.row]
        cell.configure(with: message)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: self.view.frame.width, height: 44)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

//extension DialogViewController: UITableViewDelegate{
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 64))
//        let label = UILabel()
//        view.addSubview(label)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
//        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        let date  = messageList[section].date
//        label.attributedText = NSAttributedString(string: self.dateFormatter.string(from: date), attributes:
//                                                    [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14),
//                                                     NSAttributedString.Key.foregroundColor : UIColor(r: 21, g: 31, b: 73, a: 0.3)])
//        return view
//    }
//
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 64
//    }
//}

//extension DialogViewController: UITableViewDataSource{

//    func numberOfSections(in tableView: UITableView) -> Int {
//        return messageList.count
//    }

//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return messageList[section].messages.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "dialogCell") as? DialogCell else { return UITableViewCell() }
//        let message = messageList[indexPath.section].messages[indexPath.row]
//        cell.configure(with: message)
//        return cell
//    }
//}



