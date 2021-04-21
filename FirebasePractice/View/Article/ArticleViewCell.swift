//
//  ArticleViewCell.swift
//  FirebasePractice
//
//  Created by 曾問 on 2021/4/21.
//

import UIKit

class ArticleViewCell: UICollectionViewCell {
    
    @IBOutlet var idLabel: UILabel!
    @IBOutlet var authorIdLabel: UILabel!
    @IBOutlet var tagLabel: UILabel!
    @IBOutlet var contentLabel: UILabel!
    
    func setUp(article: ArticleObject) {
        idLabel.text = article.id
        authorIdLabel.text = article.authorId
        tagLabel.text = article.tag.rawValue
        contentLabel.text = article.content
    }
}
