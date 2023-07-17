//
//  logInViewController.swift
//  twitterClone
//
//  Created by KH on 07/04/2023.
//

import UIKit
import Combine

class logInViewController: UIViewController {
    
    private var viewModel = AuthenticationViewViewModel()
    private var subscriptions: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        view.addSubview(loginTitleLabel)
        view.addSubview(emailTextField)
        view.addSubview(PasswordTextField)
        view.addSubview(loginButton)
        configureConstraints()
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapToDismiss)))
        bindViews()

    }
    
      @objc private func didTapToDismiss(){
          view.endEditing(true)
      }
    
    @objc private func didChangeEmailField(){
        viewModel.email = emailTextField.text
        viewModel.validateAuthenticationForm()
    }
    @objc private func didChangepasswordField(){
        viewModel.password = PasswordTextField.text
        viewModel.validateAuthenticationForm()
    }
    
    private func bindViews(){
        emailTextField.addTarget(self, action: #selector(didChangeEmailField), for: .editingChanged)
        PasswordTextField.addTarget(self, action: #selector(didChangepasswordField), for: .editingChanged)
        viewModel.$isAuthenticationFormValid.sink{ [weak self] validationState in //sink is the chanel we get the subscription that the subscribers did in the observable class from //validationState is a variable for isRegistrationFormValid
            
            self?.loginButton.isEnabled = validationState
        }
        .store(in: &subscriptions)
        
        viewModel.$user.sink{ [weak self] user in //when we get a user from the view model
//            print( user)
            guard user != nil else {return}
            // onboarding is set in the homeViewController as the root, so we dismiss it when a user is created, basically navigating back to the home ViewController
            guard let vc = self?.navigationController?.viewControllers.first as? OnboardingViewController else {return}
            vc.dismiss(animated: true)
        }
        .store(in: &subscriptions)
        
        viewModel.$error.sink{ [weak self] errorString in //weak self for the retaining cycle of the errorString variable wich holds the value which $error publishes
            guard let error = errorString else { return } //guard let cause $error is an optional
            self?.presentAlert(with: error)
                                
        }
        .store(in: &subscriptions)
    }
    
    private func presentAlert(with error: String) {
        let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        let okayButton = UIAlertAction(title: "ok", style: .default)
        alert.addAction(okayButton)
        present(alert, animated: true)
    }

    
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("login", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        button.backgroundColor = .twitterBlueColor
        button.layer.masksToBounds = true
        button.tintColor = .white
        button.layer.cornerRadius = 25
        button.isEnabled = false//this won't make a difference it already checks in the bind views function
        button.addTarget(self, action: #selector(didTapTologin), for: .touchUpInside)
        return button
    }()
    @objc func didTapTologin(){
        viewModel.logInUser()
    }
    
    private let  loginTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "login to your account"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        return label
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.attributedPlaceholder = NSAttributedString(
            string: "Email",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray]
        )
        return textField
    }()

    private let PasswordTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.attributedPlaceholder = NSAttributedString(
            string: "Password",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray]
        )
        textField.isSecureTextEntry = true
        return textField
    }()
    
    
    private func configureConstraints(){
        
        let loginTitleLabelConstraints = [
            loginTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20)
        ]
        
        let emailTextFieldConstraint = [
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 20),
            emailTextField.topAnchor.constraint(equalTo:loginTitleLabel.bottomAnchor, constant: 20),
            emailTextField.widthAnchor.constraint(equalToConstant: view.frame.width - 40),
            emailTextField.heightAnchor.constraint(equalToConstant: 60),
            emailTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ]
        
        let PasswordTextFieldConstraint = [
            PasswordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 20),
            PasswordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 15),
            PasswordTextField.widthAnchor.constraint(equalToConstant: view.frame.width - 40),
            PasswordTextField.heightAnchor.constraint(equalToConstant: 60),
            PasswordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ]
        
        let loginButtonConstraint = [
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -20),
            loginButton.topAnchor.constraint(equalTo: PasswordTextField.bottomAnchor, constant: 20),
            loginButton.widthAnchor.constraint(equalToConstant:180),
            loginButton.heightAnchor.constraint(equalToConstant: 50)
       ]
        
        
        NSLayoutConstraint.activate(loginTitleLabelConstraints)
        NSLayoutConstraint.activate(emailTextFieldConstraint)
        NSLayoutConstraint.activate(PasswordTextFieldConstraint)
        NSLayoutConstraint.activate(loginButtonConstraint)
        
    }
    

}
