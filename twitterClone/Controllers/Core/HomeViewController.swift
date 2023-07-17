//
//  HomeTabbarViewController.swift
//  twitterClone
//
//  Created by KH on 28/03/2023.
//

import UIKit
import FirebaseAuth
import Combine
import SwiftUI

class HomeViewController: UIViewController {
    
    private var viewModel = HomeViewViewModel()
    private var subscriptions: Set<AnyCancellable> = []
    
    private lazy var composeTweetButton: UIButton = {
        let button = UIButton(type: .system, primaryAction: UIAction { [weak self] _ in //new feature instead of making an objc function and adding it with add target
            self?.navigateToTweetComposer()
        })
        button.backgroundColor = .twitterBlueColor
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        let plusSign = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .bold))
        button.setImage(plusSign, for: .normal)
        button.layer.cornerRadius = 30
        button.clipsToBounds = true
         
        return button
    }()
    
    func configureNavigationBar(){
        let size: CGFloat = 24
        let logoImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: size, height: size))
        logoImageView.contentMode = .scaleAspectFill
        logoImageView.image = UIImage(named: "Twitter-logo")
        
        let middleView = UIView(frame: CGRect(x: 0, y: 0, width: size, height: size))
        middleView.addSubview(logoImageView)
        navigationItem.titleView = middleView
        
        let profileImage = UIImage(systemName: "person")
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: profileImage, style: .plain, target: self, action: #selector(didTapProfile))
    }
    
    @objc private func didTapProfile(){
        let vc = ProfileViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    private let timelineTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(TweetTableViewCell.self, forCellReuseIdentifier: TweetTableViewCell.identifier)
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(timelineTableView)
        view.addSubview(composeTweetButton)
        timelineTableView.delegate = self
        timelineTableView.dataSource = self
        configureNavigationBar()
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "rectangle.portrait.and.arrow.right"), style: .plain, target: self, action: #selector(didTapSignOut))
        bindViews()

    }
    

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        timelineTableView.frame = view.frame
        configureConstraints()
    }
    @objc private func didTapSignOut(){
        try? Auth.auth().signOut()
       
        handleAuthentication()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //this will make the navigation bar appear again after it's hidden in the profile controller
        navigationController?.navigationBar.isHidden = false
        handleAuthentication()
        viewModel.retrieveUser()


    }
    func completeUserOnboarding(){
        let vc = ProfileDataFormViewController()
        present(vc, animated: true)
    }

    func bindViews(){
        viewModel.$user.sink{ [weak self] user in
            guard let user = user else { return }
            if !user.isUserOnboarded {
                self?.completeUserOnboarding()
            }
        }.store(in: &subscriptions)
        
        viewModel.$tweets.sink{ [weak self] _ in
            DispatchQueue.main.async {
                self?.timelineTableView.reloadData()
            }
        }.store(in: &subscriptions)
    }
    
    private func configureConstraints(){
        let composeTweetButtonConstraints = [
            composeTweetButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            composeTweetButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -120),
            composeTweetButton.widthAnchor.constraint(equalToConstant: 60),
            composeTweetButton.heightAnchor.constraint(equalToConstant: 60)
        ]
        NSLayoutConstraint.activate(composeTweetButtonConstraints)
        
    }
    
    private func handleAuthentication(){
            if Auth.auth().currentUser == nil {
                let vc = UINavigationController(rootViewController: OnboardingViewController())
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: false)
                DispatchQueue.main.async {
                    self.timelineTableView.reloadData()
                }
            }
    }
    
    private func navigateToTweetComposer(){
        let vc = UINavigationController(rootViewController: TweetComposeViewController())
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }

}


extension HomeViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if Auth.auth().currentUser == nil {
            return 0
        }
        return viewModel.tweets.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TweetTableViewCell.identifier, for: indexPath) as? TweetTableViewCell else {
            return UITableViewCell()
        }
        
        let tweetModel = viewModel.tweets[indexPath.row]
        cell.configureTweet(with: tweetModel.author.displayName,
                            username: tweetModel.author.username,
                            tweetTextContent: tweetModel.tweetContent,
                            avatarPath: tweetModel.author.avatarPath)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        timelineTableView.deselectRow(at: indexPath, animated: true)
    }
    
}
extension HomeViewController: tweetTableViewCellDelegate {
    func tweetTableViewCellDidTapReply() {
        print("Reply")
    }

    func tweetTableViewCellDidTapRetweet() {
        print("Retweet")

    }

    func tweetTableViewCellDidTapLike() {
        print("Like")

    }

    func tweetTableViewCellDidTapShare() {
        print("Share")

    }
        
    
}
