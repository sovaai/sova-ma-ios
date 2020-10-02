//
//  Settings .swift
//  SOVA
//
//  Created by Мурат Камалов on 02.10.2020.
//

import UIKit


class SettingsVC: UIViewController{
    
    static func show(in parent: UIViewController){
        parent.present(SettingsVC(), animated: true)
    }
    
    private var model = ["Лисенок", "Волк", "Пес"]
    
    private var cellId = "SettingsCell"
    
    private var tableView: UITableView = UITableView(frame: .zero, style: .grouped)
    
    //MARK: VC life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Настройки"
        
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
        
        //Configure cell with bots
        guard indexPath.section == 1 else {
            guard indexPath.row < self.model.count  else {
                cell.textLabel?.text = "Подключить еще".localized
                return cell
            }
            cell.textLabel?.text = self.model[indexPath.row]
            return cell
        }
        
        //Configure setings's cell
        cell.textLabel?.text = UserSettings.allCases[indexPath.row].rawValue.localized
        guard indexPath.row != 0 else {
            cell.accessoryType = .disclosureIndicator
            cell.accessibilityLabel = Language.userValue
            cell.detailTextLabel?.text = Language.userValue
            cell.accessibilityHint = Language.userValue
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
}


enum UserSettings: String, CaseIterable{
    case language = "Язык приложения"
    case theme = "Темная тема"
    case cashe = "Очистить историю и кеш"
    case logs = "ОТправить логи"
    case support = "Техподдержка"
    case aboutApp = "О приложении"
    
    
}
