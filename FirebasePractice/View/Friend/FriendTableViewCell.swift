//
//  FriendTableViewCell.swift
//  FirebasePractice
//
//  Created by 曾問 on 2021/4/20.
//

import UIKit

class FriendTableViewCell: UITableViewCell {
    
    
    @IBOutlet var name: UILabel!
    @IBOutlet var id: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setUp(user: UserObject) {
        name.text = user.name
        id.text = user.id
    }

}
