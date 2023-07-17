//
//  File.swift
//  twitterClone
//
//  Created by KH on 19/04/2023.
//

import Foundation
import Combine
import FirebaseAuth

final class TweetComposeViewViewModel: ObservableObject{
    
    private var subscriptions: Set<AnyCancellable> = []
    
    @Published var isValidToTweet: Bool = false
    @Published var error: String = ""
    @Published var shouldDismissComposer: Bool = false
    var tweetContent: String = ""
    private var user: TwitterUser?
    
    func getUserData(){
        guard let id = Auth.auth().currentUser?.uid else { return }
        DatabaseManager.shared.collectionUsers(retrieve: id)
            .sink{ [weak self] Completion in
                if case .failure(let error) = Completion {
                    self?.error = error.localizedDescription }
            } receiveValue: { [weak self] twitterUser in
                self?.user = twitterUser
            }
            .store(in: &subscriptions)
    }
    
    func validateToTweet(){
        isValidToTweet = !tweetContent.isEmpty
    }
    func dispatchTweet(){
        guard let user = user else { return }
        let tweet = Tweet(author: user, authorID: user.id, tweetContent: tweetContent, likesCount: 0, likers: [], isReply: false, ParentReference: nil)
        DatabaseManager.shared.collectionTweets(dispatch: tweet)
            .sink{ [weak self] Completion in
                if case .failure(let error) = Completion {
                    self?.error = error.localizedDescription }
            } receiveValue: { [weak self] state in
                self?.shouldDismissComposer = state
            }
            .store(in: &subscriptions)
            
            
    }
    
    
}
