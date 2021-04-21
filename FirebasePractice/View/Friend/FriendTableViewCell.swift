//
//  FriendTableViewCell.swift
//  FirebasePractice
//
//  Created by 曾問 on 2021/4/20.
//

import UIKit

protocol FriendCellDelegate: AnyObject {
    func invite(indexPath: IndexPath)
}

class FriendTableViewCell: UITableViewCell {
    @IBOutlet var name: UILabel!
    @IBOutlet var id: UILabel!
    @IBOutlet var inviteButton: UIButton!
    
    weak var delegate: FriendCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setUp(user: UserObject, canInvite: Bool) {
        name.text = user.name
        id.text = user.id
        
        if canInvite {
            inviteButton.tintColor = .green
            inviteButton.isEnabled = true
        } else {
            inviteButton.tintColor = .gray
            inviteButton.isEnabled = false
        }
    }

    @IBAction func inviteSubmit(_ sender: UIButton) {
        if let tableView = superview as? UITableView {
            delegate?.invite(indexPath: tableView.indexPath(for: self)!)
        }
    }
    
}
