//
//  StorageManager.swift
//  twitterClone
//
//  Created by KH on 16/04/2023.
//

import Foundation
import Combine
import FirebaseStorageCombineSwift
import FirebaseStorage

enum FirestorageError: Error {
    case invalidImageID
}

final class StorageManager {
    static let shared = StorageManager()
    
    let storage = Storage.storage()
    
    func getDownloadURL(for id: String?) -> AnyPublisher<URL, Error> {
        guard let id = id else {
            return Fail(error: FirestorageError.invalidImageID)
                .eraseToAnyPublisher()
        }
        print("getDownloadURL")
        return storage
            .reference(withPath: id)
            .downloadURL()
            .print()
            .eraseToAnyPublisher() //downloadURL returns a future so we turn it into anypublisher
    }
    
    func uploadProfilePhoto(with randomID: String, image: Data, metaData: StorageMetadata) -> AnyPublisher<StorageMetadata, Error> {
        print ("uploadProfilePhoto")
        return storage //bucket is the storage is the same one in the firebase
            .reference() //root
            .child("images/\(randomID).jpg") //the additional path after root
            .putData(image, metadata: metaData) //meta data is information about the data
            .print()
            .eraseToAnyPublisher() //put data returns a future so we turn it into anypublisher
    }
    
    
}
