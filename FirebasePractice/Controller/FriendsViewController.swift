//
//  FriendsViewController.swift
//  FirebasePractice
//
//  Created by 曾問 on 2021/4/20.
//

import UIKit
import PKHUD

struct FriendCells {
    static let searchResult = "searchResult"
    static let friend = "friend"
}

class FriendsViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    @IBOutlet var searchField: UITextField! {
        didSet {
            searchField.delegate = self
        }
    }
    
    private var matchedUsers: [UserObject] = []
    private var myFriends: [UserObject] = []
    private var selfObject: UserObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorColor = .white
    }
    
    func preloadUserData(user: UserObject) {
        selfObject = user
        self.addListener()
    }
    
    func addListener() {
        FirestoreManager.shared.addListener(collection: .users) {
            result in
            switch result {
            case .success(let changes):
                changes.forEach {
                    change in
                    print(change.document.documentID)
                    // 首次添加所有好友
                    guard let changedObject = try? change.document.data(as: UserObject.self) else { return }
                    if let selfId = self.selfObject?.docID,
                       changedObject.friends.contains(selfId) {
                        self.myFriends.append(changedObject)
                    }
                    
                    switch change.type {
                    case .modified:
                        guard let selfObject = self.selfObject,
                              let docID = selfObject.docID else {
                            return }
                        // MARK: 如果刷新用戶中，好友名單包含自己則刷新，自己也要加好友
                        if changedObject.friends.contains(docID) &&
                            !selfObject.friends.contains(changedObject.docID!) {
                            self.tableView.reloadData()
                            HUD.flash(.labeledSuccess(title: "新增好友成功", subtitle: "你和 \(changedObject.name) 成為了好友"), delay: 3.0)
                            print(changedObject)
                            
                        }
                        
                        // MARK: 如果刷新用戶中，邀請名單包含自己則？
                        if changedObject.invites.contains(docID) {
                            let alertController = UIAlertController(title: "收到交友邀請", message: "\(changedObject.name) 向您發送了交友邀請，是否同意？", preferredStyle: .alert)
                            let confirm = UIAlertAction(title: "同意", style: .default) {_ in
                                // MAKR: 自己名單先加對方，再對方加自己
                                FirestoreManager.shared.connectFriend(acceptUser: selfObject, inviteUser: changedObject) {
                                    result in
                                    switch result {
                                    case .success(_):
                                        HUD.flash(.labeledSuccess(title: "加入成功", subtitle: "與 \(changedObject.id) 成為了好友"), delay: 3)
                                    case .failure(let error):
                                        HUD.flash(.labeledError(title: "加入失敗", subtitle: "\(error)"), delay: 3)
                                    }
                                }
                            }
                            let cancel = UIAlertAction(title: "拒絕", style: .cancel) {
                                _ in
                                if let index = changedObject.invites.firstIndex(of: docID) {
                                    var copyChangeObject = changedObject
                                    copyChangeObject.invites.remove(at: index)
                                    FirestoreManager.shared.updateInvites(newUser: copyChangeObject) {
                                        result in
                                        switch result {
                                        case .success(_):
                                            HUD.flash(.labeledSuccess(title: "拒絕成功", subtitle: nil), delay: 2.0)
                                        case .failure(let error):
                                            print(error)
                                            HUD.flash(.labeledError(title: "拒絕失敗", subtitle: nil), delay: 2.0)
                                        }
                                    }
                                }
                            }
                            alertController.addAction(confirm)
                            alertController.addAction(cancel)
                            self.present(alertController, animated: true)
                            print(changedObject)
                        }
                        
                    default:
                        break
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension FriendsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return matchedUsers.count
        } else {
            return myFriends.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0,
           let cell = tableView.dequeueReusableCell(withIdentifier: FriendCells.searchResult) as? FriendTableViewCell {
            let nextUser = matchedUsers[indexPath.row]
            cell.setUp(userName: nextUser.name, userId: nextUser.id, canInvite: selfObject!.canInvited(target: nextUser.docID!))
            cell.delegate = self
            return cell
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: FriendCells.friend) as? FriendTableViewCell {
                let nextUser = myFriends[indexPath.row]
                cell.setUp(userName: nextUser.name, userId: nextUser.id, canInvite: false)
                cell.delegate = self
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.backgroundColor = .white
            cell.isSelected = false
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .white
        let titleLabel = UILabel()
        if section == 0 {
            titleLabel.text = "尋找好友"
        } else {
            titleLabel.text = "我的好友"
        }
        titleLabel.textColor = UIColor.B1
        titleLabel.sizeToFit()
        titleLabel.textAlignment = .center
        headerView.addSubview(titleLabel)
        
        NSLayoutConstraint.init(item: titleLabel, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: headerView, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint.init(item: titleLabel, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: headerView, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0).isActive = true
        return headerView
    }
}

extension FriendsViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        FirestoreManager.shared.searchUser(email: textField.text!) {
            result in
            switch result {
            case .success(let users):
                self.matchedUsers = users.filter {
                    user in
                    return user.docID != self.selfObject?.docID
                }
                self.tableView.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}

extension FriendsViewController: FriendCellDelegate {
    func invite(indexPath: IndexPath) {
        guard var selfObject = selfObject else { return }
        selfObject.addInvites(docId: matchedUsers[indexPath.row].docID!)
        FirestoreManager.shared.updateInvites(newUser: selfObject) {
            result in
            switch result {
            case .success(_):
                self.selfObject = selfObject
                self.tableView.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }
}
