//
//  LoginViewController.swift
//  FirebasePractice
//
//  Created by 曾問 on 2021/4/20.
//

import UIKit

protocol LoginUserInputDelegate: AnyObject {
    func didChangeUserData(_ view: LoginView, data: UserAccount)
    func doSubmit(_ view: LoginView, type: LoginType)
    func getAll(_ view: LoginView, completion: @escaping (Result<[AuthorObject], Error>) -> Void)
}

struct UserAccount {
    let email: String
    let password: String
}

enum LoginType: Int {
    case signIn = 0
    case signUp = 1
}

class LoginView: UIView {
    
    @IBOutlet var segment: UISegmentedControl!
    
    @IBOutlet var emailTextField: UITextField! {
        didSet {
            emailTextField.delegate = self
        }
    }

    @IBOutlet var passwordTextField: UITextField! {
        didSet {
            passwordTextField.delegate = self
        }
    }
    
    @IBOutlet var submitButton: UIButton! {
        didSet {
            guard let button = submitButton else { return }
            if button.isEnabled {
                button.backgroundColor = UIColor.B1
            } else {
                button.backgroundColor = UIColor.B4
            }
        }
    }
    
    @IBOutlet var resultLabel: UILabel!
    
    @IBOutlet var userInfoView: UIView!
    
    weak var delegate: LoginUserInputDelegate?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.endEditing(true)
    }
    
    func passData() {
        guard let email = emailTextField.text,
              let password = passwordTextField.text else {
            return
        }
        
        delegate?.didChangeUserData(self, data: UserAccount(email: email, password: password))
    }
    
    func setSubmitButton(isEnabled: Bool) {
        submitButton.isEnabled = isEnabled
        if isEnabled {
            submitButton.backgroundColor = UIColor.B1
        } else {
            submitButton.backgroundColor = UIColor.B4
        }
    }
    
    func setResult(result: Result<UserObject, Error>){
        switch result {
        case .success(let user):
            userInfoView.isHidden = false
            userInfoView.subviews.forEach {
                view in
                guard let label = view as? UILabel else { return }
                switch label.tag {
                case 0:
                    label.text = "id: \(user.id)"
                case 1:
                    label.text = "name: \(user.name)"
                case 2:
                    label.text = "email: \(user.email)"
                default:
                    break
                }
            }
        case .failure(let error):
            resultLabel.isHidden = false
            resultLabel.textColor = .red
            resultLabel.text = "\(error)"
        }
    }
    
    @IBAction func submit(_ sender: UIButton) {
        resultLabel.isHidden = true
        switch LoginType(rawValue: segment.selectedSegmentIndex) {
        case .signIn:
            delegate?.doSubmit(self, type: .signIn)
        case .signUp:
            delegate?.doSubmit(self, type: .signUp)
        case .none:
            print("")
        }
    }
}

extension LoginView: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        passData()
    }
}
