//
//  DataBaseManager.swift
//  twitterClone
//
//  Created by KH on 07/04/2023.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import FirebaseFirestoreCombineSwift
import Combine

class DatabaseManager {
    static let shared = DatabaseManager()
    
    let db = Firestore.firestore()
    let usersPath: String = "users"
    let tweetsPath: String = "tweets"
    
    func collectionUsers(add user: User) -> AnyPublisher<Bool, Error>{
        let twitterUser = TwitterUser(from: user)
        return db.collection(usersPath).document(twitterUser.id).setData(from: twitterUser)
            .map{ _ in
                //the function returns anypublisher of type bool so we map the result to true that's the data was succefully set
                return true
            }
            .eraseToAnyPublisher()
    }
    
    func collectionUsers(retrieve id: String) -> AnyPublisher<TwitterUser, Error>{
        db.collection(usersPath).document(id).getDocument() //this returns a snapshot of the firebase user
            .tryMap { //trymap cause the function might throw errors
                try $0.data(as: TwitterUser.self) //$0 is the document snapshot, .data() is a method by FirebaseFirestoreSwift to decode the data base user to our twitter user
            }
            .eraseToAnyPublisher()
    }
    func collectionUsers(updateFields: [String: Any], for id: String) -> AnyPublisher<Bool, Error> {
        db.collection(usersPath).document(id).updateData(updateFields)
            .map{ _ in true}
            .eraseToAnyPublisher()
    }
    func collectionTweets(dispatch tweet: Tweet) -> AnyPublisher<Bool, Error> {
        db.collection(tweetsPath).document(tweet.id).setData(from: tweet)
            .map{ _ in true}
            .eraseToAnyPublisher()
    }
    func collectionTweets(retrieveTweets forUserId: String) -> AnyPublisher<[Tweet], Error> {
        db.collection(tweetsPath).whereField("authorID", isEqualTo: forUserId)
            .getDocuments()
            .tryMap(\.documents)
            .tryMap { snapshots in //the array of snapshots in the document
                try snapshots.map({ //we map every single snapshot to a tweet to create the array of tweets
                    try $0.data(as: Tweet.self)
                })
            }
            .eraseToAnyPublisher()
    }
}
