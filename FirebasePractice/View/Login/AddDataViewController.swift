//
//  AddDataView.swift
//  FirebasePractice
//
//  Created by 曾問 on 2021/4/20.
//

import UIKit
import Firebase

protocol AddDataViewDelegate: AnyObject {
    func addData(object: ArticleObject, completion: @escaping (Result<String, Error>) -> Void)
}

class AddDataViewController: UIViewController {
    
    var newAuthor: ArticleObject?
    
    var delegate: AddDataViewDelegate?
    
    @IBOutlet var idField: UITextField! {
        didSet {
            idField.delegate = self
        }
    }
    
    @IBOutlet var titleField: UITextField! {
        didSet {
            titleField.delegate = self
        }
    }
    
    @IBOutlet var contentField: UITextField! {
        didSet {
            contentField.delegate = self
        }
    }
    
    @IBOutlet var segment: UISegmentedControl!
    
    @IBOutlet var authorIdField: UITextField! {
        didSet {
            authorIdField.delegate = self
        }
    }
    
    @IBOutlet var submitButton: UIButton! {
        didSet {
            submitButton.backgroundColor = UIColor.B4
            submitButton.isEnabled = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        self.view.isHidden = true
    }
    
    @IBAction func submitAddData(_ sender: UIButton) {
        delegate?.addData(object: newAuthor!) {
            result in
            switch result {
            case .success(let result):
                let controller = UIAlertController(title: "Create success", message: "reference id: \(result)", preferredStyle: .alert)
                let confirmAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                controller.addAction(confirmAction)
                self.present(controller, animated: true)
            case .failure(let error):
                let controller = UIAlertController(title: "Create failed", message: "error: \(error)", preferredStyle: .alert)
                let confirmAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                controller.addAction(confirmAction)
                self.present(controller, animated: true)
            }
        }
    }
    
    func setButtonEnable(isEnabled: Bool) {
        submitButton.isEnabled = isEnabled
        if isEnabled {
            submitButton.backgroundColor = UIColor.B1
        } else {
            submitButton.backgroundColor = UIColor.B4
        }
    }
}

extension AddDataViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let id = idField.text,
              let title = titleField.text,
              let content = contentField.text,
              let authorId = authorIdField.text,
              let tag = ArticleTag.index(segment.selectedSegmentIndex) else {
            submitButton.isEnabled = false
            submitButton.backgroundColor = UIColor.B4
            return }
        submitButton.isEnabled = true
        submitButton.backgroundColor = UIColor.B1
        newAuthor =  ArticleObject(docId: nil, id: id, title: title, content: content, tag: tag, authorId: authorId, createdTime: Timestamp.init(date: Date()))
    }
}
