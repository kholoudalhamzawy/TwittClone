//
//  ProfileDataFormViewController.swift
//  twitterClone
//
//  Created by KH on 08/04/2023.
//

import UIKit
import PhotosUI
import Combine

class ProfileDataFormViewController: UIViewController {
    
    private let viewModel = ProfileDataFormViewViewModel()
    private var subscriptions: Set<AnyCancellable> = []

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true //very important when initilizing scrollviews it shows that the content can be scrollable
        scrollView.keyboardDismissMode = .onDrag
        return scrollView
    }()
    
       private let hintLabel: UILabel = {
          
           let label = UILabel()
           label.translatesAutoresizingMaskIntoConstraints = false
           label.text = "Fill in your data"
           label.font = .systemFont(ofSize: 32, weight: .bold)
           label.textColor = .label
           return label
       }()
       
       
       private let avatarPlaceholderImageView: UIImageView = {
           let imageView = UIImageView()
           imageView.translatesAutoresizingMaskIntoConstraints = false
           imageView.clipsToBounds = true
           imageView.layer.masksToBounds = true
           imageView.layer.cornerRadius = 60
           imageView.backgroundColor = .lightGray
           imageView.image = UIImage(systemName: "camera.fill")
           imageView.tintColor = .gray 
           imageView.isUserInteractionEnabled = true
           imageView.contentMode = .scaleAspectFill
           return imageView
       }()
    
     private let displayNameTextField: UITextField = {
         let textField = UITextField()
         textField.translatesAutoresizingMaskIntoConstraints = false
         textField.keyboardType = .default
         textField.backgroundColor =  .secondarySystemFill
         textField.leftViewMode = .always //so this gives the placeholder text a padding
         textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
         textField.layer.masksToBounds = true
         textField.layer.cornerRadius = 8
         textField.attributedPlaceholder = NSAttributedString(string: "Display Name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
         return textField
     }()
     
     
     private let usernameTextField: UITextField = {
         let textField = UITextField()
         textField.translatesAutoresizingMaskIntoConstraints = false
         textField.keyboardType = .default
         textField.backgroundColor =  .secondarySystemFill
         textField.leftViewMode = .always
         textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
         textField.layer.masksToBounds = true
         textField.layer.cornerRadius = 8
         textField.attributedPlaceholder = NSAttributedString(string: "Username", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
         return textField
     }()
    
       private let bioTextView: UITextView = {
          
           let textView = UITextView()
           textView.translatesAutoresizingMaskIntoConstraints = false
           textView.backgroundColor = .secondarySystemFill
           textView.layer.masksToBounds = true
           textView.layer.cornerRadius = 8
           textView.textContainerInset = .init(top: 15, left: 15, bottom: 15, right: 15)
           textView.text = "Tell the world about yourself"
           textView.textColor = .gray
           textView.font = .systemFont(ofSize: 16)
           return textView
       }()
       
       
       private let submitButton: UIButton = {
           let button = UIButton(type: .system)
           button.translatesAutoresizingMaskIntoConstraints = false
           button.setTitle("Submit", for: .normal)
           button.tintColor = .white
           button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
           button.backgroundColor = .twitterBlueColor
           button.layer.masksToBounds = true
           button.layer.cornerRadius = 25
           button.isEnabled = false
           return button
       }()
     
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        isModalInPresentation = true //makes the scrollview undissmisable
        
        scrollView.addSubview(hintLabel)
        scrollView.addSubview(avatarPlaceholderImageView)
        scrollView.addSubview(displayNameTextField)
        scrollView.addSubview(usernameTextField)
        scrollView.addSubview(bioTextView)
        scrollView.addSubview(submitButton)
        
        displayNameTextField.delegate = self
        usernameTextField.delegate = self
        bioTextView.delegate = self
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapToDismiss)))

        submitButton.addTarget(self, action: #selector(didTapSubmit), for: .touchUpInside)
        
        avatarPlaceholderImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapToUpload))) //adding an action for a view like a button
        
        bindViews()
        configureConstraints()
    }
    
    @objc private func didTapSubmit() {
          viewModel.uploadAvatar()
      }
    
    @objc private func didUpdateDisplayName() {
          viewModel.displayName = displayNameTextField.text
          viewModel.validateUserProfileForm() //we check if the form is valid evry time anything in it is changed so we can enable the button
      }
      
      @objc private func didUpdateUsername() {
          viewModel.username = usernameTextField.text
          viewModel.validateUserProfileForm()  //we check if the form is valid evry time anything in it is changed so we can enable the button
      }
      
      private func bindViews() {
          //we add a target to a textfield to make it ike a button
          displayNameTextField.addTarget(self, action: #selector(didUpdateDisplayName), for: .editingChanged)
          usernameTextField.addTarget(self, action: #selector(didUpdateUsername), for: .editingChanged)
          
//          we subscribe to the viewModel published variables,
//          whenever the $isFormValid changes, the closure is excuted,
//          then the subscription is stored so it gets cancelled when the application dies.
          viewModel.$isFormValid.sink { [weak self] buttonState in
              self?.submitButton.isEnabled = buttonState
          }
          .store(in: &subscriptions)
          
          
          viewModel.$isOnBoardingFinished.sink{ [weak self] success in
              if success {
                  self?.dismiss(animated: true)
              }
          }.store(in: &subscriptions)
          
      }
    
    
    @objc private func didTapToUpload() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images //accepts only images
        configuration.selectionLimit = 1 //aceepts one image
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc private func didTapToDismiss() {
        view.endEditing(true)
    }
    
    
    private func configureConstraints() {
        
        let scrollViewConstraints = [
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        
        
        let hintLabelConstraints = [
            hintLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            hintLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 30)
        ]
        
        
        let avatarPlaceholderImageViewConstraints = [
            avatarPlaceholderImageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            avatarPlaceholderImageView.heightAnchor.constraint(equalToConstant: 120),
            avatarPlaceholderImageView.widthAnchor.constraint(equalToConstant: 120),
            avatarPlaceholderImageView.topAnchor.constraint(equalTo: hintLabel.bottomAnchor, constant: 30)
        ]
        
        let displayNameTextFieldConstraints = [
            displayNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            displayNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            displayNameTextField.topAnchor.constraint(equalTo: avatarPlaceholderImageView.bottomAnchor, constant: 40),
            displayNameTextField.heightAnchor.constraint(equalToConstant: 50)
        ]
        
        let usernameTextFieldConstraints = [
            usernameTextField.leadingAnchor.constraint(equalTo: displayNameTextField.leadingAnchor),
            usernameTextField.trailingAnchor.constraint(equalTo: displayNameTextField.trailingAnchor),
            usernameTextField.topAnchor.constraint(equalTo: displayNameTextField.bottomAnchor, constant: 20),
            usernameTextField.heightAnchor.constraint(equalToConstant: 50)
        ]
        
        let bioTextViewConstraints = [
            bioTextView.leadingAnchor.constraint(equalTo: displayNameTextField.leadingAnchor),
            bioTextView.trailingAnchor.constraint(equalTo: displayNameTextField.trailingAnchor),
            bioTextView.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 20),
            bioTextView.heightAnchor.constraint(equalToConstant: 150)
        ]
        
        let submitButtonConstraints = [
            submitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            submitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            submitButton.heightAnchor.constraint(equalToConstant: 50),
            submitButton.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -20) //this always makes the button appear on top of the keyboard so it doesnt hide it
        ]
        
        NSLayoutConstraint.activate(scrollViewConstraints)
        NSLayoutConstraint.activate(hintLabelConstraints)
        NSLayoutConstraint.activate(avatarPlaceholderImageViewConstraints)
        NSLayoutConstraint.activate(displayNameTextFieldConstraints)
        NSLayoutConstraint.activate(usernameTextFieldConstraints)
        NSLayoutConstraint.activate(bioTextViewConstraints)
        NSLayoutConstraint.activate(submitButtonConstraints)
    }

    


}


extension ProfileDataFormViewController: UITextViewDelegate, UITextFieldDelegate {
    
    //textView delegates
    func textViewDidBeginEditing(_ textView: UITextView) {
        scrollView.setContentOffset(CGPoint(x: 0, y: textView.frame.origin.y - 100), animated: true) //this puts the scroll view up so the keyboard is shown without hiding anyhing
        
        if textView.textColor == .gray { // to remove the costimized place holder
            textView.textColor = .label
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true) //this puts the scroll view down again after dismissing the keyboard
        if textView.text.isEmpty { // to return the costimized place holder
            textView.text = "Tell the world about yourself"
            textView.textColor = .gray
        }
    }
    
    func textViewDidChange(_ textView: UITextView) { //you cant add a target function on a text view like textfields to make them like buttons, but this delegate method works
        viewModel.bio = textView.text
        viewModel.validateUserProfileForm() //we check if the form is valid evry time anything in it is changed so we can enable the button
    }

    
    //textField delegates
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //this puts the scroll view up so the keyboard is shown without hiding anyhing
        scrollView.setContentOffset(CGPoint(x: 0, y: textField.frame.origin.y - 100), animated: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //this puts the scroll view down again after dismissing the keyboard
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
}


extension ProfileDataFormViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        picker.dismiss(animated: true) //to seelect the image and dismiss the gallery picked from
        
        for result in results { //although we specified the results to be one image but it returns an array so we iterate throw it
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
                if let image = object as? UIImage {
                    DispatchQueue.main.async {
                        self?.avatarPlaceholderImageView.image = image
                        self?.viewModel.imageData = image
                        self?.viewModel.validateUserProfileForm()  //we check if the form is valid evry time anything in it is changed so we can enable the button
                    }
                }
            }
        }
    }
}
