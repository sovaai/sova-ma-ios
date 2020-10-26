//
//  Settings .swift
//  SOVA
//
//  Created by Мурат Камалов on 02.10.2020.
//

import UIKit
import MessageUI

class SettingsVC: UIViewController{
    
    static func show(in parent: UIViewController){
        guard let vc = parent as? UINavigationController else {
            parent.present(SettingsVC(), animated: true)
            return
        }
        vc.pushViewController(SettingsVC(), animated: true)
    }
    
    //----------------------------------------------------------------------------------------------------------------
    
    //MARK: Support variables
    
    //----------------------------------------------------------------------------------------------------------------
    
    private var model : [Assitant] {
        get{
            return DataManager.shared.assistantsId.compactMap{DataManager.shared.getAssistant(by: $0)}
        }
    }
    
    private var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.doesRelativeDateFormatting = true
        return df
    }
    
    private var mailComposer = MFMailComposeViewController()
    
    //----------------------------------------------------------------------------------------------------------------
    
    //MARK: Table view variables
    
    //----------------------------------------------------------------------------------------------------------------
    
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
    
    //----------------------------------------------------------------------------------------------------------------
    
    //MARK: VC life cycle
    
    //----------------------------------------------------------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor =  UIColor(named: "Colors/mainbacground")
        
        self.title = "Настройки".localized
        self.navigationController?.navigationBar.isHidden = false
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: self.cellId)
        
        if UIScreen.main.traitCollection.userInterfaceStyle == .dark{
            self.tableView.backgroundColor = UIColor(named: "Colors/settingsBackground")
        }
        
        self.view.addSubview(self.tableView)
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        self.tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
      
    //----------------------------------------------------------------------------------------------------------------
    
    //MARK: Logs
    
    //----------------------------------------------------------------------------------------------------------------
    
    func createLog(){
        let messageListId = DataManager.shared.currentAssistants.messageListId
        var text: String = ""
        for id in messageListId{
            guard let ms: MessageList = DataManager.shared.get(by: id) else { continue }
            text += self.dateFormatter.string(from: ms.date) + "\n"
            for message in ms.messages{
                text += message.sender.rawValue + ":" + message.title + "\n"
            }
        }
        self.write(text: text, to: "Logs")
    }
    
    func write(text: String, to fileNamed: String, folder: String = "SavedFiles") {
        guard let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else { return }
        guard let writePath = NSURL(fileURLWithPath: path).appendingPathComponent(folder) else { return }
        do{
            try FileManager.default.createDirectory(atPath: writePath.path, withIntermediateDirectories: true)
            let file = writePath.appendingPathComponent(fileNamed + ".txt")
            try text.write(to: file, atomically: false, encoding: String.Encoding.utf8)
            self.sendLogsl(fileURL: file)
        }catch{
            self.showSimpleAlert(title: "Не получается сохранть файл".localized)
        }
    }
    
    func sendLogsl(fileURL: URL) {
        guard MFMailComposeViewController.canSendMail() else { self.showSimpleAlert(title: "Неполучается открывать почтовый клиент".localized); return }
        self.mailComposer = MFMailComposeViewController()
        self.mailComposer.mailComposeDelegate = self
        self.mailComposer.setSubject("Logs")
        
        guard let fileData = try? Data(contentsOf: fileURL) else { self.showSimpleAlert(title: "Не получается загрузить логи".localized); return }
        self.mailComposer.addAttachmentData(fileData, mimeType: ".txt", fileName: "Logs")
    
        self.present(mailComposer, animated: true, completion: nil)
    }
    
    //----------------------------------------------------------------------------------------------------------------
    
    //MARK: Support
    
    //----------------------------------------------------------------------------------------------------------------
    
    func sendSupport(){
        guard MFMailComposeViewController.canSendMail() else { self.showSimpleAlert(title: "Неполучается открывать почтовый клиент".localized); return }
        self.mailComposer = MFMailComposeViewController()
        self.mailComposer.mailComposeDelegate = self
        let email = "support@sova.ai"
        self.mailComposer.setToRecipients([email])
        
        self.present(mailComposer, animated: true, completion: nil)
    }
    
    //----------------------------------------------------------------------------------------------------------------
    
}


//----------------------------------------------------------------------------------------------------------------
//MARK:Table view delegates
//----------------------------------------------------------------------------------------------------------------
extension SettingsVC: UITableViewDelegate, UITableViewDataSource{
    
    //----------------------------------------------------------------------------------------------------------------
    
    //MARK: TableView Configure
    
    //----------------------------------------------------------------------------------------------------------------
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? self.model.count + 1 : UserSettings.allCases.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section != 1 ? "Аккаунт".localized : "Подключить еще".localized
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: self.cellId)
        cell.selectionStyle = .none
        cell.backgroundColor = UIColor(named: "Colors/settingsCell")
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
        cell.textLabel?.text = UserSettings.allCases[indexPath.row].string.localized
        guard UserSettings(rawValue: indexPath.row) != .language else {
            cell.accessoryType = .disclosureIndicator
            cell.accessibilityLabel = Language.userValue
        
            return cell
        }
        
        return cell
    }
    
    //----------------------------------------------------------------------------------------------------------------
    
    //MARK: TableView Actions
    
    //----------------------------------------------------------------------------------------------------------------
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0{
            guard indexPath.row < self.model.count else { AssistantVC.show(with: nil, in: self.navigationController!); return }
            self.selectedAssistant = indexPath
            DataManager.shared.checkAnotherAssistant(self.model[indexPath.row].id)
        }else{
            switch UserSettings.allCases[indexPath.row] {
            case .cashe:
                let alert = UIAlertController(title: "Подтверждение удаления?".localized, message: "Вы уверены что хотите все удалить?", preferredStyle: .alert)
                let delete = UIAlertAction(title: "Удалить все", style: .destructive) { (_) in
                    DataManager.shared.deleteAll()
                }
                let cancel = UIAlertAction(title: "Неее, не надо", style: .cancel)
                alert.addAction(cancel)
                alert.addAction(delete)
                self.present(alert, animated: true, completion: nil)
            case .logs:
                self.createLog()
            case .support:
                self.sendSupport()
            case .aboutApp:
                AboutVC.show(parent: self.navigationController!)
            default:
                break
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard indexPath.section == 0,
              indexPath.row < self.model.count,
              self.model[indexPath.row].uuid.string != "b03822f6-362d-478b-978b-bed603602d0e" else { return false}
        return true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить".localized) { (_, _, _) in
            DataManager.shared.deleteAssistant(self.model[indexPath.row])
            self.tableView.reloadData()
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Изменить".localized) { (_, _, _) in
            AssistantVC.show(with: self.model[indexPath.row], in: self.navigationController!)
        }
        
        let swipeAction = UISwipeActionsConfiguration(actions: [deleteAction,editAction])
        
        return swipeAction
    }
    
    //----------------------------------------------------------------------------------------------------------------
}

//----------------------------------------------------------------------------------------------------------------
//MARK: Email
//----------------------------------------------------------------------------------------------------------------
extension SettingsVC: MFMailComposeViewControllerDelegate{
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.mailComposer.dismiss(animated: true, completion: nil)
    }
}


//----------------------------------------------------------------------------------------------------------------

//MARK: UserEnam

//----------------------------------------------------------------------------------------------------------------
enum UserSettings: Int, CaseIterable{
    case language = 0
    case cashe = 1
    case logs = 2
    case support = 3
    case aboutApp = 4
    
    var string: String {
        switch self {
        case .language:
            return "Язык приложения"
        case .cashe:
            return "Очистить историю и кеш"
        case .logs:
            return "Отправить логи"
        case .support:
            return "Техподдержка"
        case .aboutApp:
            return "О приложении"
        }
    }
}
