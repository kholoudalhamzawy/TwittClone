//
//  registerViewController.swift
//  twitterClone
//
//  Created by KH on 30/03/2023.
//

import UIKit
import Combine

class registerViewController: UIViewController {
    
    private var viewModel = AuthenticationViewViewModel()
    private var subscriptions: Set<AnyCancellable> = []
    
  
    @objc private func didTapToDismiss(){
        view.endEditing(true)
    }
    
    private let registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Create account", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        button.backgroundColor = .twitterBlueColor
        button.layer.masksToBounds = true
        button.tintColor = .white
        button.layer.cornerRadius = 25
        button.isEnabled = false
        button.addTarget(self, action: #selector(didTapToRegister), for: .touchUpInside)
        return button
    }()
    @objc func didTapToRegister(){
        viewModel.createUser()
    }
    
    private let registerTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Create your account"
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
            
            self?.registerButton.isEnabled = validationState
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

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(registerTitleLabel)
        view.addSubview(emailTextField)
        view.addSubview(PasswordTextField)
        view.addSubview(registerButton)
        configureConstraints()
//        emailTextField.becomeFirstResponder() //the keyboard is already on when you enter the viewController
//        PasswordTextField.becomeFirstResponder()

        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapToDismiss)))
        bindViews()
       
    }
    

    private func configureConstraints(){
        
        let registerTitleLabelConstraints = [
            registerTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            registerTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20)
        ]
        
        let emailTextFieldConstraint = [
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 20),
            emailTextField.topAnchor.constraint(equalTo: registerTitleLabel.bottomAnchor, constant: 20),
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
        
        let registerButtonConstraint = [
            registerButton.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -20),
            registerButton.topAnchor.constraint(equalTo: PasswordTextField.bottomAnchor, constant: 20),
            registerButton.widthAnchor.constraint(equalToConstant:180),
            registerButton.heightAnchor.constraint(equalToConstant: 50)
       ]
        
        
        NSLayoutConstraint.activate(registerTitleLabelConstraints)
        NSLayoutConstraint.activate(emailTextFieldConstraint)
        NSLayoutConstraint.activate(PasswordTextFieldConstraint)
        NSLayoutConstraint.activate(registerButtonConstraint)
        
    }
}
