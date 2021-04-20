//
//  FriendsViewController.swift
//  FirebasePractice
//
//  Created by 曾問 on 2021/4/20.
//

import UIKit

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorColor = .white
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}

extension FriendsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchedUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "friend") as? FriendTableViewCell {
            cell.setUp(user: matchedUsers[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
    
}

extension FriendsViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        FirestoreManager.shared.searchUser(email: textField.text!) {
            result in
            switch result {
            case .success(let users):
                self.matchedUsers = users
                self.tableView.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }
}
