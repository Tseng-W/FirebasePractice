//
//  ArticleViewController.swift
//  FirebasePractice
//
//  Created by 曾問 on 2021/4/21.
//

import UIKit
import PKHUD

struct ArticleCells {
    static let content = "content"
}

class ArticleViewController: UIViewController {
    
    private var articles: [ArticleObject] = []

    @IBOutlet var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = self
            collectionView.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reloadArticles()
    }
    
    func reloadArticles() {
        FirestoreManager.shared.getData(collection: .articles, filter: nil) {
            (result: Result<[ArticleObject], Error>) in
            switch result {
            case .success(let articles):
                self.articles = articles
                self.collectionView.reloadData()
            case .failure(let error):
                print("\(error)")
                HUD.flash(.labeledError(title: "載入失敗", subtitle: nil), delay: 2.0)
            }
        }
    }
}

extension ArticleViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        articles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ArticleCells.content, for: indexPath) as? ArticleViewCell {
            cell.setUp(article: articles[indexPath.row])
            return cell
        }
        
        return UICollectionViewCell()
    }
}

extension ArticleViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.bounds.size.width * 0.43
        let height = width / 0.57
        return CGSize(width: width, height: height)
    }
}
