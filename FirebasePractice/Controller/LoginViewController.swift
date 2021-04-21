//
//  ViewController.swift
//  FirebasePractice
//
//  Created by 曾問 on 2021/4/20.
//

import UIKit
import Firebase


class LoginViewController: UIViewController {
    
    var user: UserAccount?
    
    @IBOutlet var loginView: LoginView! {
        didSet {
            loginView.delegate = self
        }
    }
    
    @IBOutlet var addDataVC: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addDataVC.isHidden = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? AddDataViewController {
            controller.delegate = self
        }
    }
    
    func getAuthorData(completion: @escaping  (Result<[ArticleObject], Error>) -> Void) {
        FirestoreManager.shared.getData(collection: .articles, filter: nil, completion: completion)
    }
    
    func writeAuthorDate(data: ArticleObject, completion: @escaping (Result<String, Error>) -> Void) {
        FirestoreManager.shared.writeDate(collection: .articles, data: data, completion: completion)
    }
    
    func signInFirebase(_ user: UserAccount) {
        FirestoreManager.shared.signIn(user: user) {
            result in
            switch result {
            case .success(_):
                self.addDataVC.isHidden = false
                FirestoreManager.shared.getUserInfo(user: user) {
                    data in
                    switch data {
                    case .success(let userObject):
                        self.navigationItem.title = "Writing"
                        self.tabBarItem.title = "Writing"
                        self.loginView.setResult(result: .success(userObject))
                        
                        if let navVC = self.tabBarController!.viewControllers![2] as? UINavigationController,
                           let friendVC = navVC.viewControllers.first as? FriendsViewController {
                            friendVC.preloadUserData(user: userObject)
                        }
                    case .failure(let error): self.loginView.setResult(result: .failure(error))
                    }
                }
            case .failure(let error):
                self.loginView.setResult(result: .failure(error))
            }
        }
    }
    
    func signUpFirebase(_ user: UserAccount) {
        FirestoreManager.shared.signUp(user: user) {
            result in
            switch result {
            case .success(_):
                self.addDataVC.isHidden = false
                FirestoreManager.shared.getUserInfo(user: user) {
                    data in
                    switch data {
                    case .success(let userObject):
                        self.navigationItem.title = "Writing"
                        self.tabBarItem.title = "Writing"
                        self.loginView.setResult(result: .success(userObject))
                        if let navVC = self.tabBarController!.viewControllers![2] as? UINavigationController,
                           let friendVC = navVC.viewControllers.first as? FriendsViewController {
                            friendVC.preloadUserData(user: userObject)
                        }
                    case .failure(let error):
                        self.loginView.setResult(result: .failure(error))
                    }
                }
            case .failure(let error):
                self.loginView.setResult(result: .failure(error))
            }
        }
    }
}

extension LoginViewController: LoginUserInputDelegate {
    func getAll(_ view: LoginView, completion: @escaping (Result<[ArticleObject], Error>) -> Void) {
        getAuthorData(completion: completion)
    }
    
    func didChangeUserData(_ view: LoginView, data: UserAccount) {
        guard data.email != "",
              data.password != "" else {
            view.setSubmitButton(isEnabled: false)
            return
        }
        user = data
        view.setSubmitButton(isEnabled: true)
    }
    
    func doSubmit(_ view: LoginView, type: LoginType) {
        guard let user = user else { return }
        switch type {
        case .signIn:
            signInFirebase(user)
        case .signUp:
            signUpFirebase(user)
        }
    }
}

extension LoginViewController: AddDataViewDelegate {
    func addData(object: ArticleObject, completion: @escaping (Result<String, Error>) -> Void) {
        writeAuthorDate(data: object, completion: completion)
    }
}
