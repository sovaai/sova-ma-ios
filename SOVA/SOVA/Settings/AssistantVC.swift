//
//  AssistantVC.swift
//  SOVA
//
//  Created by Мурат Камалов on 02.10.2020.
//

import UIKit

protocol SaveAssistant: class{
    func save(field: String, with key: String)
}

class AssistantVC: UIViewController, SaveAssistant{
    
    private var tableView = UITableView(frame: .zero, style: .grouped)
    
    private var cellId = "AssistantCell"
    
    private var model: Assitant? = nil
    
    fileprivate var modelJson = [String: Any]()
    
    static func show(with model: Assitant?, in parent: UINavigationController){
        let instance = AssistantVC()
        instance.model = model
        parent.pushViewController(instance, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = self.model != nil ? "Редактирование асисента" : "Новый ассистент".localized
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Сохранить".localized, style: .plain, target: self, action: #selector(self.saveModel))
        
        self.view.addSubview(self.tableView)
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        self.tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        self.tableView.register(TextFieldCell.self, forCellReuseIdentifier: "TextFieldCell")
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: self.cellId)
        
        self.tableView.allowsSelection = false
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    @objc func activationWordOn(){
        
    }
    
    @objc func saveModel(){
        guard let name = (self.modelJson[AssistantStateField.name.rawValue] ?? self.model?.name as Any) as? String,
              let urlStr = (self.modelJson[AssistantStateField.url.rawValue] ?? self.model?.url as Any) as? String,
              let tokenStr = (self.modelJson[AssistantStateField.token.rawValue] ?? self.model?.token as Any) as? String,
              let token = Int(tokenStr) else {
//              let url = URL(string: urlStr) else {
            //FIXME: ВЕРНУТЬ ПОСЛЕ ТЕСТА
            self.showSimpleAlert(title: "Ошибка".localized, message: "Не все данные верны".localized)
            return
        }
        let wordActive = (self.modelJson[AssistantStateField.name.rawValue] ?? self.model?.name as Any) as? Bool
        
        let url = URL(string: "https://vk.com/feed")! //FIXME: ВЕРНУТЬ ПОСЛЕ ТЕСТА!
        let model = Assitant(name: name, url: url, token: token, wordActive: wordActive ?? false)
        
        model.save()
    }
    
    func save(field: String, with key: String) {
        self.modelJson[key] = field
        self.close()
    }
    
    func close(){
        self.dismiss(animated: true, completion: nil)
    }
}

extension AssistantVC: UITableViewDataSource, UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.model != nil ? 5 : 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 1 }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.section != 4 else {
            let cell = tableView.dequeueReusableCell(withIdentifier: self.cellId)!
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.text = "Удалить".localized
            cell.textLabel?.textColor = .red
            return cell
        }
        
        guard indexPath.section != 3 else {
            let cell = tableView.dequeueReusableCell(withIdentifier: self.cellId)!
            cell.textLabel?.text = "Cлушать активационное слово".localized
            let switchView = UISwitch(frame: .zero)
            switchView.setOn(false, animated: true)
            switchView.tag = indexPath.row // for detect which row switch Changed
            switchView.addTarget(self, action: #selector(self.activationWordOn), for: .valueChanged)
            cell.accessoryView = switchView
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell") as?  TextFieldCell
        cell?.delegate = self
        cell?.configure(with: AssistantStateField.allCases[indexPath.section], model: self.model)
        
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard section != 4 else { return ""}
        return AssistantStateField.allCases[section].header
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 4 else { return }
        let alert = UIAlertController(title: "Подтвердение удаления".localized, message: "Нажмите на кнопку Удалить для пожтверждения удаления аккаунта".localized, preferredStyle: .alert)
        let delete = UIAlertAction(title: "Удалить".localized, style: .destructive) { (_) in
            self.model?.delete()
            self.close()
        }
        let cancel = UIAlertAction(title: "Отменить".localized, style: .cancel)
        alert.addAction(delete)
        alert.addAction(cancel)
        self.present(alert, animated: true)
    }
}


class TextFieldCell: UITableViewCell, UITextFieldDelegate{
    
    private var textField = UITextField()
    
    private var type: AssistantStateField!
    
    weak var delegate: SaveAssistant? = nil
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        //        self.textField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        self.contentView.addSubview(self.textField)
        self.textField.translatesAutoresizingMaskIntoConstraints = false
        self.textField.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.textField.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.textField.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16).isActive = true
        self.textField.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        
        self.textField.clearButtonMode = .whileEditing
        self.textField.delegate = self
    }
    
    func configure(with type: AssistantStateField, model:  Assitant?){
        self.type = type
        self.textField.keyboardType = type.keyboard
        guard let model = model else { self.textField.text = type.defaultValue; return}
        switch type {
        case .name:
            self.textField.text = model.name
        case .url:
            self.textField.text = model.url.absoluteString
        case .token:
            self.textField.text = String(model.token)
        default: return
        }
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        let isEmpty = textField.text?.isEmpty ?? false
        guard isEmpty else {
            self.backgroundColor = .clear
            self.delegate?.save(field: textField.text!, with: self.type.rawValue)
            return true
        }
        self.backgroundColor = .red
        return !isEmpty
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

enum AssistantState{
    case new
    case delete
}

enum AssistantStateField: String, CaseIterable {
    case name
    case url
    case token
    case word
    
    var keyboard: UIKeyboardType{
        switch self {
        case .url:
            return .URL
        case .token:
            return .numberPad
        default:
            return .default
        }
    }
    
    var defaultValue: String {
        switch self {
        case .name:
            return "Введите имя".localized
        case .url:
            return "https://"
        case .token:
            return "Введите токен".localized
        default:
            return ""
        }
    }
    
    var header: String{
        switch self {
        case .name: return "Имя".localized
        case .url: return "API URL".localized
        case .token: return "ТОКЕН".localized
        case .word: return "Активационное слово".localized
        }
    }
}