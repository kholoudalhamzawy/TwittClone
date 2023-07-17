//
//  ProfileDataFormViewViewModel.swift
//  twitterClone
//
//  Created by KH on 08/04/2023.
//

import Foundation
import Combine
import UIKit
import FirebaseAuth
import FirebaseStorage
import SwiftUI

final class ProfileDataFormViewViewModel: ObservableObject{
    
    private var subscriptions: Set<AnyCancellable> = []
    @Published var displayName: String?
    @Published var username: String?
    @Published var bio: String?
    @Published var avatarPath: String?
    @Published var imageData: UIImage?
    @Published var isFormValid: Bool = false
    @Published var error: String = ""
    @Published var isOnBoardingFinished: Bool = false
    
    
    func validateUserProfileForm() {
        guard let displayName = displayName,
              displayName.count > 2,
              let username = username,
              username.count > 2,
              let bio = bio,
              bio.count > 2,
              imageData != nil else {
                  isFormValid = false
                  return
              }
        isFormValid = true
    }
    
    func uploadAvatar() {
         let randomID = UUID().uuidString
         guard let imageData = imageData?.jpegData(compressionQuality: 0.5) else { return }
         let metaData = StorageMetadata() //meta data is the information of the object
         metaData.contentType = "image/jpeg"
         
         StorageManager.shared.uploadProfilePhoto(with: randomID, image: imageData, metaData: metaData)
             .flatMap({ metaData in //map turns the type of object into the desired type
                 StorageManager.shared.getDownloadURL(for: metaData.path)
             })
             .sink { [weak self] completion in
                 switch completion {
                 case .failure(let error):
                     self?.error = error.localizedDescription
                     
                     //when the function recieves the bool value it performs the closure, updateUserData() is excuted after the avatarpath is set with the url
                 case .finished:
                     print ("url is")
                     print(self?.avatarPath ?? "" )
                     self?.updateUserData()
                 
//                 if case .failure(let error) = completion {
//                     self?.error = error.localizedDescription
//                 
                 }
             } receiveValue: { [weak self] url in
                 self?.avatarPath = url.absoluteString //the string for the url
             }
             .store(in: &subscriptions)
        
         
    }
    
    private func updateUserData(){
        guard let displayName = displayName,
              let username = username,
              let bio = bio,
              let avatarPath = avatarPath,
              let id = Auth.auth().currentUser?.uid else { return }
        
        let updatedFields: [String: Any] = [
            "displayName": displayName,
            "username": username,
            "bio": bio,
            "avatarPath": avatarPath,
            "isUserOnboarded": true
        ]
        
        DatabaseManager.shared.collectionUsers(updateFields: updatedFields, for: id)
        //when the function recieves the bool value it performs the closure
            .sink{ [weak self] Completion in
                if case .failure(let error) = Completion {
                    print(error.localizedDescription)
                    self?.error = error.localizedDescription
                }
            } receiveValue: { [weak self] onboardingState in
                self?.isOnBoardingFinished = onboardingState
            }
            .store(in: &subscriptions)
            
    }
}
