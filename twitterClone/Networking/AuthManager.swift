//
//  AuthManeger.swift
//  twitterClone
//
//  Created by KH on 31/03/2023.
//

import Foundation
import Firebase
import FirebaseAuthCombineSwift
import Combine

class AuthManager{

    static let shared = AuthManager()
    
    func registerUser(with email: String, password: String) -> AnyPublisher<User, Error> { //user here is firebase user type, you can specify your own user type
        return Auth.auth().createUser(withEmail: email, password: password)
            .map(\.user)
            .eraseToAnyPublisher()
        
    }
    func logInUser(with email: String, password: String)-> AnyPublisher<User, Error> {
        
        return Auth.auth().signIn(withEmail: email, password: password)
            .map(\.user) //map publishes the url key path, the user is the signed in user
            .eraseToAnyPublisher() //the signin method returns a future publisher, this here makes it return any publisher 
    }
}
