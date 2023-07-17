//
//  TweetComposeViewController.swift
//  twitterClone
//
//  Created by KH on 18/04/2023.
//

import UIKit
import Combine

class TweetComposeViewController: UIViewController {
    
    private var viewModel = TweetComposeViewViewModel()
    private var subscriptions: Set<AnyCancellable> = []

    
    private let tweetButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .twitterBlueColor
        button.setTitle("Tweet", for: .normal)
        button.layer.cornerRadius = 20
        button.clipsToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.isEnabled = false
        //the differance between this and button.tintColor = .white is that tint color is dimmed automatically when it's disabled
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.white.withAlphaComponent(0.7), for: .disabled) //this makes the button dim when it's disabaled
        button.addTarget(self, action: #selector(didTapToTweet), for: .touchUpInside)
        return button
    }()
    
    @objc func didTapToTweet(){
        viewModel.dispatchTweet()
    }
    
    private let tweetContentTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.layer.masksToBounds = true
        textView.layer.cornerRadius = 8
        textView.textContainerInset = .init(top: 15, left: 15, bottom: 15, right: 15)
        textView.text = "what's happening"
        textView.textColor = .gray
        textView.font = .systemFont(ofSize: 16)
        return textView
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Tweet"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title:"Cancel", style: .plain, target: self, action: #selector(didTapCancel))
        tweetContentTextView.delegate = self
        view.addSubview(tweetButton)
        view.addSubview(tweetContentTextView)
        bindViews()
        configureConstraints()
        
    }
    
    private func bindViews(){
        viewModel.$isValidToTweet.sink{ [weak self] state in
            self?.tweetButton.isEnabled = state
        }.store(in: &subscriptions)
        
        viewModel.$shouldDismissComposer.sink { [weak self] success in
            if success {
                self?.dismiss(animated: true)
            }
        }.store(in: &subscriptions)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.getUserData()
    }
    
    @objc private func didTapCancel(){
        dismiss(animated: true)
    }
    private func configureConstraints() {
        let tweetButtonConsytaints = [
            tweetButton.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -10),
            tweetButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            tweetButton.widthAnchor.constraint(equalToConstant: 120),
            tweetButton.heightAnchor.constraint(equalToConstant: 40)
        ]
        let tweetContentTextViewConstraints = [
            tweetContentTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tweetContentTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            tweetContentTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            tweetContentTextView.bottomAnchor.constraint(equalTo: tweetButton.topAnchor, constant: -10)
            
        ]
        NSLayoutConstraint.activate(tweetButtonConsytaints)
        NSLayoutConstraint.activate(tweetContentTextViewConstraints)

    }
    
    
}

extension TweetComposeViewController: UITextViewDelegate{
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.textColor == .gray { // to remove the costimized place holder
            textView.textColor = .label
            textView.text = ""
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if textView.text.isEmpty { // to return the costimized place holder
            textView.text = "what's happening"
            textView.textColor = .gray
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        viewModel.tweetContent = textView.text
        viewModel.validateToTweet()
    }
}
