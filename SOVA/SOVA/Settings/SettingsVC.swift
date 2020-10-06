//
//  Settings .swift
//  SOVA
//
//  Created by Мурат Камалов on 02.10.2020.
//

import UIKit


class SettingsVC: UIViewController{
    
    static func show(in parent: UIViewController){
        guard let vc = parent as? UINavigationController else {
            parent.present(SettingsVC(), animated: true)
            return
        }
        vc.pushViewController(SettingsVC(), animated: true)
    }
    
    private var model : [Assitant] {
        get{
            return DataManager.shared.assistantsId.compactMap{DataManager.shared.get(by: $0)}
        }
    }
    
    private var selectedAssistant = IndexPath(){
        didSet{
            let oldCell = self.tableView.cellForRow(at: oldValue)
            oldCell?.accessoryType = .none
            let newCell = self.tableView.cellForRow(at: self.selectedAssistant)
            newCell?.accessoryType = .checkmark
        }
    }
    
    private var cellId = "SettingsCell"
    
    private var tableView: UITableView = UITableView(frame: .zero, style: .grouped)
    
    //MARK: VC life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        
        self.title = "Настройки".localized
        self.navigationController?.navigationBar.isHidden = false
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: self.cellId)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.view.addSubview(self.tableView)
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        self.tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    }
    
    @objc func changeTheme(){
        
    }
}

extension SettingsVC: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? self.model.count + 1 : 6
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section != 1 ? "Аккаунт".localized : "Подключить еще".localized
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: self.cellId)
        cell.selectionStyle = .none
        //Configure cell with bots
        guard indexPath.section == 1 else {
            guard indexPath.row < self.model.count  else {
                cell.textLabel?.text = "Подключить еще".localized
                cell.accessoryType = .disclosureIndicator
                return cell
            }
            if DataManager.shared.currentAssistants.id == self.model[indexPath.row].id{
                cell.accessoryType = .checkmark
                self.selectedAssistant = indexPath
            }
            cell.textLabel?.text = self.model[indexPath.row].name
            return cell
        }
        
        //Configure setings's cell
        cell.textLabel?.text = UserSettings.allCases[indexPath.row].rawValue.localized
        guard indexPath.row != 0 else {
            cell.accessoryType = .disclosureIndicator
            cell.accessibilityLabel = Language.userValue
        
            return cell
        }
        
        guard indexPath.row != 1 else {
            let switchView = UISwitch(frame: .zero)
            switchView.setOn(false, animated: true)
            switchView.tag = indexPath.row // for detect which row switch Changed
            switchView.addTarget(self, action: #selector(self.changeTheme), for: .valueChanged)
            cell.accessoryView = switchView
            return cell
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0{
            guard indexPath.row < self.model.count else { AssistantVC.show(with: nil, in: self.navigationController!); return }
            self.selectedAssistant = indexPath
            DataManager.shared._currentAssistants = self.model[indexPath.row]
        }else{
            //Остальное функционал
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard indexPath.section == 0 else { return false}
        return indexPath.row < self.model.count
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete".localized) { (_, _, _) in
            self.model[indexPath.row].delete()
            self.tableView.reloadData()
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit".localized) { (_, _, _) in
            AssistantVC.show(with: self.model[indexPath.row], in: self.navigationController!)
        }
        
        let swipeAction = UISwipeActionsConfiguration(actions: [deleteAction,editAction])
        
        return swipeAction
    }
}


enum UserSettings: String, CaseIterable{
    case language = "Язык приложения"
    case theme = "Темная тема"
    case cashe = "Очистить историю и кеш"
    case logs = "ОТправить логи"
    case support = "Техподдержка"
    case aboutApp = "О приложении"
    
    
}
