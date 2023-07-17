//
//  HomeViewViewModel.swift
//  twitterClone
//
//  Created by KH on 08/04/2023.
//

import Foundation
import Combine
import FirebaseAuth

final class HomeViewViewModel: ObservableObject{
    
    @Published var user: TwitterUser?
    @Published var error: String?
    @Published var tweets: [Tweet] = []
    
    private var subscriptions: Set<AnyCancellable> = []
    
    func retrieveUser(){
        guard let id = Auth.auth().currentUser?.uid else { return }
        DatabaseManager.shared.collectionUsers(retrieve: id)
            .handleEvents(receiveOutput: { [weak self] user in
                self?.user = user //we first need to set the user so we can fetch its tweets
                self?.fetchTweets() //this will happen after the user is retrieved
            })
            .sink{ [weak self] Completion in
                if case .failure(let error) = Completion {
                    self?.error = error.localizedDescription }
            } receiveValue: { [weak self] user in
                self?.user = user
            }
            .store(in: &subscriptions) //this is for memory management, the subscriptions: Set<AnyCancellable> cancells all the subsciptions that's in it when the viewModel is deleted
    }
    func fetchTweets(){
        guard let id = user?.id else { return }
        DatabaseManager.shared.collectionTweets(retrieveTweets: id)
            .sink{ [weak self] Completion in
                if case .failure(let error) = Completion {
                    self?.error = error.localizedDescription }
            } receiveValue: { [weak self] retrievedTweets in
                self?.tweets = retrievedTweets
            }
            .store(in: &subscriptions) //this is for memory management, the subscriptions: Set<AnyCancellable> cancells all the subsciptions that's in it when the viewModel is deleted
    }
    
}
