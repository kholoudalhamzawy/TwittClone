//
//  TweetTableViewCell.swift
//  twitterClone
//
//  Created by KH on 28/03/2023.
//

import UIKit

protocol tweetTableViewCellDelegate: AnyObject {
    func tweetTableViewCellDidTapReply()
    func tweetTableViewCellDidTapRetweet()
    func tweetTableViewCellDidTapLike()
    func tweetTableViewCellDidTapShare()
}

class TweetTableViewCell: UITableViewCell {
    
    static let identifier = "TweetTableViewCell"
    private let actionSpacing : CGFloat = 60
    
    weak var delegate: tweetTableViewCellDelegate?
    
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 25 //circular because wisth and height are 50
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true
//        imageView.image = UIImage(systemName: "person")
        imageView.backgroundColor = .purple
            return imageView
        
    }()
    
    private let displayNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel //makes it dimmer
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let tweetTextContentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
//        label.text = "this is my MokeUp tweet. it's gonna be multiple lines. i believe some more Text is enough but lets add some more anyway.. halliloighah !!!"
        label.numberOfLines = 0
        return label
    
    }()
    private let replyButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "reply"), for: .normal)
        button.tintColor = .systemGray2
        return button
        
    }()
    private let retweetButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "retweet"), for: .normal)
        button.tintColor = .systemGray2
        return button
        
    }()
    private let likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "heart"), for: .normal)
        button.tintColor = .systemGray2
        return button
        
    }()
    
    private let shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "share"), for: .normal)
        button.tintColor = .systemGray2
        return button
        
    }()
    @objc private func didTapReply(){
        delegate?.tweetTableViewCellDidTapReply()
    }
    @objc private func didTapRetweet(){
        delegate?.tweetTableViewCellDidTapRetweet()
    }
    @objc private func didTapLike(){
        delegate?.tweetTableViewCellDidTapLike()
    }
    @objc private func didTapShare(){
        delegate?.tweetTableViewCellDidTapShare()
    }
    private func configureButtons(){
        replyButton.addTarget(self, action: #selector(didTapReply), for: .touchUpInside)
        retweetButton.addTarget(self, action: #selector(didTapRetweet), for: .touchUpInside)
        likeButton.addTarget(self, action: #selector(didTapLike), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(didTapShare), for: .touchUpInside)
    }
    
    func configureTweet(with displayName: String, username: String, tweetTextContent: String, avatarPath: String){
        displayNameLabel.text = displayName
        usernameLabel.text = "@\(username)"
        tweetTextContentLabel.text = tweetTextContent
        avatarImageView.sd_setImage(with: URL(string: avatarPath))
    }
    
    
    
    private func configureConstraints() {
        let avatarImageViewConstraints = [
        avatarImageView.leadingAnchor.constraint(equalTo:contentView.leadingAnchor,constant:20),
        avatarImageView.topAnchor.constraint (equalTo: contentView.topAnchor, constant: 14),
        avatarImageView.heightAnchor.constraint (equalToConstant: 50),
        avatarImageView.widthAnchor.constraint (equalToConstant: 50)
        ]
        let displayNameLabelConstraints = [
        displayNameLabel.leadingAnchor.constraint (equalTo: avatarImageView.trailingAnchor, constant: 20),
        displayNameLabel.topAnchor.constraint (equalTo: contentView.topAnchor, constant: 20)
        ]
        let usernameLabelConstraints = [
        usernameLabel.leadingAnchor.constraint (equalTo: displayNameLabel.trailingAnchor, constant: 10),
        usernameLabel.centerYAnchor.constraint (equalTo: displayNameLabel.centerYAnchor)
        ]
        let tweetTextContentLabelConstraints = [
            tweetTextContentLabel.leadingAnchor.constraint(equalTo: displayNameLabel.leadingAnchor),
            tweetTextContentLabel.topAnchor.constraint(equalTo: displayNameLabel.bottomAnchor, constant: 10),
            tweetTextContentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -35)
        //    tweetTextContentLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15)
        ]
        let replyButtonConstraints = [
            replyButton.leadingAnchor.constraint(equalTo: tweetTextContentLabel.leadingAnchor),
            replyButton.topAnchor.constraint(equalTo: tweetTextContentLabel.bottomAnchor, constant: 20),
            replyButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ]
        
        let retweetButtonConstraints = [
            retweetButton.leadingAnchor.constraint(equalTo: replyButton.trailingAnchor, constant: actionSpacing),
            retweetButton.centerYAnchor.constraint(equalTo: replyButton.centerYAnchor)
        ]
        let likeButtonConstraints = [
            likeButton.leadingAnchor.constraint(equalTo: retweetButton.trailingAnchor, constant: actionSpacing),
            likeButton.centerYAnchor.constraint(equalTo: replyButton.centerYAnchor)
        ]
        let shareButtonConstraints = [
            shareButton.leadingAnchor.constraint(equalTo: likeButton.trailingAnchor, constant: actionSpacing),
            shareButton.centerYAnchor.constraint(equalTo: replyButton.centerYAnchor)
        ]
            
        NSLayoutConstraint.activate(avatarImageViewConstraints)
        NSLayoutConstraint.activate(displayNameLabelConstraints)
        NSLayoutConstraint.activate(usernameLabelConstraints)
        NSLayoutConstraint.activate(tweetTextContentLabelConstraints)
        NSLayoutConstraint.activate(replyButtonConstraints)
        NSLayoutConstraint.activate(retweetButtonConstraints)
        NSLayoutConstraint.activate(likeButtonConstraints)
        NSLayoutConstraint.activate(shareButtonConstraints)
        
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(avatarImageView)
        contentView.addSubview(displayNameLabel)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(tweetTextContentLabel)
        contentView.addSubview(retweetButton)
        contentView.addSubview(replyButton)
        contentView.addSubview(likeButton)
        contentView.addSubview(shareButton)
        configureButtons()
        configureConstraints()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
