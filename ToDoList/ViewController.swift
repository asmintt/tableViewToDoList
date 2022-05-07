//
//  ViewController.swift
//  ToDoList
//
//  Created by user on 2022/03/03.
//
//5.7追加　sectionのrowを開閉する機能
/*出来なかった事→section単位での開閉．
 structと辞書型使ったサンプル．エラー
 実例コードを見て開閉まではできたが，セルの移動や保存のコードの書き換えがうまくできず．
 エラー解消できなかった
 
 struct expand {
 var isOpened: Bool
 var rowitem: [String]
 }
 var rowArray = [
 expand(isOpened: true, rowitem: ["0","1"]),
 expand(isOpened: true, rowitem: ["2","3"]),
 expand(isOpened: true, rowitem:["4","5","6"])
 ]
 userdefaultに，structの型で保存しようとするとエラー．Codable？
 https://qiita.com/uhooi/items/429cac9b798b9c0937ae
 extension expand : Codable {}
 
 // indicesはどんな時に使う？printしたら0...3とか範囲で出てきた．
 var indexPaths = [IndexPath]()
 for row in rowArray[section].rowitem.indices {
 let indexPath = IndexPath(row: row, section: section)
 indexPaths.append(indexPath)
 }
 
 // タップするたびに，true falseを反転させる
 let isOpened = rowArray[section].isOpened
 rowArray[section].isOpened = !isOpened
 print(rowArray[section].isOpened,indexPaths)
 
 button.setTitle(isOpened ? "Open" : "Close", for: .normal)
 
 
 
 */


import UIKit

class ViewController: UIViewController {
    
    var rowArray: [[String?]] = [["0","1"],["2","3"],["4","5"]] {
        didSet {
            tableView?.reloadData()
            print(sectionArray,rowArray)
        }
    }
    var sectionArray: [String?] = ["A0","B1","C2"] {
        didSet {
            tableView?.reloadData()
        }
    }
    
    var isOpened = true{
        didSet {
            tableView?.reloadData()
        }
    }
    
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField! {
        didSet {
            textField.placeholder = "セクション名を入力"
            textField.returnKeyType = .done
            textField.borderStyle = .none
            textField.layer.cornerRadius = 10
            textField.layer.borderColor = UIColor.systemGray.cgColor
            textField.layer.borderWidth = 1.0
        }
    }
    @IBOutlet weak var sectionButton: UIButton! {
        didSet {
            sectionButton.setTitle("add", for: .normal)
        }
    }
    
    // sectionデータを追加するときに，rowデータも追加する
    @IBAction func addSectionButton(_ sender: Any) {
        rowArray.append(["new item"])
        UserDefaults.standard.set( self.rowArray, forKey: "rowArray")
        if let text = textField.text {
            sectionArray.append(text)
            UserDefaults.standard.set( self.sectionArray, forKey: "sectionArray")
            tableView?.reloadData()
        }
    }
    
    // userDefaultsの保存データをリセットするボタンアクション
    @IBAction func resetUserDefaultAction(_ sender: Any) {
        let appDomain = Bundle.main.bundleIdentifier
        UserDefaults.standard.removePersistentDomain(forName: appDomain!)
        tableView?.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //         UserDefaultsDataをクリアして起動する時のテスト用コード
        //         let appDomain = Bundle.main.bundleIdentifier
        //         UserDefaults.standard.removePersistentDomain(forName: appDomain!)
        
        if UserDefaults.standard.object(forKey: "rowArray") != nil {
            rowArray = UserDefaults.standard.object(forKey: "rowArray") as! [[String?]]
        }
        if UserDefaults.standard.object(forKey: "sectionArray") != nil {
            sectionArray = UserDefaults.standard.object(forKey: "sectionArray") as! [String?]
        }
        tableView.dataSource = self
        tableView.delegate = self
        isEditing = true
    }
    override func setEditing(_ editing: Bool, animated: Bool) {
        tableView.setEditing(editing, animated: animated)
    }
}



extension ViewController: UITableViewDelegate {
    // Sort remove & insert
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let itemToMove = rowArray[sourceIndexPath.section].remove(at: sourceIndexPath.row)
        rowArray[sourceIndexPath.section].insert(itemToMove, at: destinationIndexPath.row)
        
        UserDefaults.standard.set( rowArray, forKey: "rowArray")
    }
    
    // Swipe delete.edit.add
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // Delete
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            self.rowArray[indexPath.section].remove(at: indexPath.row)
            UserDefaults.standard.set( self.rowArray, forKey: "rowArray")
            // print("isEmpty判定前",self.rowArray,self.sectionArray)
            if self.rowArray[indexPath.section].isEmpty {
                print("true")
                self.sectionArray.remove(at: indexPath.section)
                UserDefaults.standard.set( self.sectionArray, forKey: "sectionArray")
                
                self.rowArray.remove(at: indexPath.section)
                UserDefaults.standard.set( self.rowArray, forKey: "rowArray")
                // print("true",self.rowArray,self.sectionArray)
            }
            completionHandler(true)
        }
        deleteAction.backgroundColor = .systemGray
        deleteAction.image = UIImage(systemName: "trash") //タイトルは非表示になる
        // Edit
        let editAction = UIContextualAction(style: .normal, title: "edit") { (action, view, completionHandler) in
            var alertTextField: UITextField?
            let alert = UIAlertController(
                title: "edit item",
                message: "Text input",
                preferredStyle: UIAlertController.Style.alert
            )
            alert.addTextField(
                configurationHandler: {(textField: UITextField!) in
                    alertTextField = textField
                    let selectIndexPath = IndexPath(row: indexPath.row, section: indexPath.section)
                    textField.placeholder = self.rowArray[selectIndexPath.section][selectIndexPath.row]
                })
            
            alert.addAction(
                UIAlertAction(
                    title: "Cancel",
                    style: UIAlertAction.Style.cancel,
                    handler: nil
                )
            )
            alert.addAction(
                UIAlertAction(
                    title: "OK",
                    style: UIAlertAction.Style.default
                ) {_ in
                    if let text = alertTextField?.text {
                        let selectItem = text
                        let selectIndexPath = IndexPath(row: indexPath.row, section: indexPath.section)
                        self.rowArray[selectIndexPath.section][selectIndexPath.row]
                        = selectItem
                        UserDefaults.standard.set( self.rowArray, forKey: "rowArray")
                        print(#function)
                        self.tableView.reloadData()
                    }
                }
            )
            self.present(alert, animated: true, completion: nil)
            completionHandler(true)
        }
        editAction.backgroundColor = .systemGray // 背景色設定
        editAction.image = UIImage(systemName:  "pencil.circle")
        // Add
        let addAction = UIContextualAction(style: .normal, title: "Add") { (action, view, completionHandler) in
            var alertTextField: UITextField?
            let alert = UIAlertController(
                title: "new item",
                message: "Text input",
                preferredStyle: UIAlertController.Style.alert
            )
            alert.addTextField(
                configurationHandler: {(textField: UITextField!) in
                    alertTextField = textField
                }
            )
            alert.addAction(
                UIAlertAction(
                    title: "Cancel",
                    style: UIAlertAction.Style.cancel,
                    handler: nil
                )
            )
            alert.addAction(
                UIAlertAction(
                    title: "OK",
                    style: UIAlertAction.Style.default
                ) {_ in
                    if let text = alertTextField?.text {
                        let newItem = text
                        let newIndexPath = IndexPath(row: indexPath.row + 1, section: indexPath.section)
                        self.rowArray[newIndexPath.section].insert(newItem, at: newIndexPath.row)
                        UserDefaults.standard.set( self.rowArray, forKey: "rowArray")
                        print(#function)
                        self.tableView.reloadData()
                    }
                }
            )
            self.present(alert, animated: true, completion: nil)
            completionHandler(true)
        }
        addAction.backgroundColor = .systemGray
        addAction.image = UIImage(systemName:  "plus.circle")
        
        return UISwipeActionsConfiguration(actions: [deleteAction,editAction,addAction])
    }
}


extension ViewController: UITableViewDataSource {
    // 必須メソッド．セル
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell();
        var content = cell.defaultContentConfiguration();
        content.text =  rowArray[indexPath.section][indexPath.row]
        cell.contentConfiguration = content;
        print("cell",[indexPath.section],rowArray[indexPath.section][indexPath.row] ?? "")
        return cell
    }
    //表示するセクションの数を返すメソッド
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionArray.count
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = .systemFill
    }
    
    // 必須． それぞれのセクションのrowの数を返すメソッド isOpenedがfalseならrow数は0
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isOpened {
            return rowArray[section].count
        } else {
            return 0
        }
    }
    // セクション索引．最初の1文字だけ．
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sectionArray.map { array in
            if let char = array?.first {
                return String(char)
            }
            return ""
        }
    }
    
    // sectionにexpand機能を追加するメソッド
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let button = UIButton(type: .system)
        button.setTitleColor(.black, for: .normal)
        button.setTitle("\(sectionArray[section]!)", for:  .normal)
        button.backgroundColor = .yellow
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        
        button.addTarget(self, action: #selector(handleExpandClose), for: .touchUpInside)
        button.tag = section
        return button
    }
    
    @objc func handleExpandClose(button: UIButton) {
        // tag ボタン判別用
        let section = button.tag
        // タップするたびに，true falseを反転させる
        isOpened = !isOpened
        
        if isOpened == true {
            button.setTitle("\(sectionArray[section]!)", for: .normal)
        } else {
            button.setTitle("close", for: .normal)
        }
        
    }
}
