//
//  RegisterViewViewModell.swift
//  twitterClone
//
//  Created by KH on 30/03/2023.
//

import Foundation
import Firebase
import Combine

final class AuthenticationViewViewModel: ObservableObject {

    @Published var email: String?
    @Published var password: String?
    @Published var isAuthenticationFormValid: Bool = false
    @Published var user: User?
    @Published var subscriptions: Set<AnyCancellable> = []
    @Published var error: String?
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    func validateAuthenticationForm(){
        guard let email = email, let password = password else {
            isAuthenticationFormValid = false
            return
        }
        isAuthenticationFormValid = isValidEmail(email) && password.count >= 8
    }
    
    func createUser() {
        guard let email = email, let password = password else {return}

        AuthManager.shared.registerUser(with: email, password: password)
            .handleEvents(receiveOutput: { [weak self] user in
                self?.user = user
            })
            .sink { [weak self] completion in
                if case .failure(let error) = completion { //the completion that's returned either is failure or success, so instead of switch statement we just put " if case .failure " because we only want to check for that case
                    self?.error = error.localizedDescription
                }
                
            } receiveValue: { [weak self] user in
                self?.createRecord(for: user)
            }
            .store(in: &subscriptions)
    }
    
    func createRecord(for user: User) {
        DatabaseManager.shared.collectionUsers(add: user)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.error = error.localizedDescription
                }
            } receiveValue: { state in
                print("Adding user record to database: \(state)")
            }
            .store(in: &subscriptions)
    }
    func logInUser() {
        guard let email = email, let password = password else {
            return
        }

        AuthManager.shared.logInUser(with: email, password: password)
            .sink { [weak self] completion in
                if case .failure(let error) = completion { 
                    self?.error = error.localizedDescription
                }
                
            } receiveValue: { [weak self] user in
                self?.user = user
            }
            .store(in: &subscriptions)
    }
    
    
 
    
}
