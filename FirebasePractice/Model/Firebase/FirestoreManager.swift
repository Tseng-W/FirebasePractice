//
//  FirebaseHandler.swift
//  FirebasePractice
//
//  Created by 曾問 on 2021/4/20.
//

import UIKit
import FirebaseFirestoreSwift
import Firebase

enum AuthorTag: String, Codable {
    case beauty
    case gossiping
    case schoolLife
    
    enum CodingKeys: String, CodingKey {
        case beauty = "Beauty"
        case gossiping = "Gossiping"
        case schoolLife = "SchoolLife"
    }
    
    static func index(_ index: Int) -> AuthorTag? {
        switch index {
        case 0:
            return .beauty
        case 1:
            return .gossiping
        case 2:
            return .schoolLife
        default:
            return nil
        }
    }
}

struct AuthorObject: Codable, Identifiable {
    @DocumentID var docId: String?
    let id: String
    let title: String
    let content: String
    let tag: AuthorTag
    let authorId: String
    let createdTime: Timestamp
    
    enum CodingKeys: String, CodingKey {
        case authorId = "author_id"
        case createdTime = "created_time"
        case title, content, tag, id, docId
    }
}

struct UserObject: Codable, Identifiable {
    @DocumentID var docID: String?
    let id: String
    let email: String
    let name: String
    let invites: [String]
    let friends: [String]
    
    static func createUserObject(user: UserAccount) -> UserObject {
        let tempName = user.email.components(separatedBy: "@")[0]
        return UserObject(docID: nil, id: tempName, email: user.email, name: tempName, invites: [], friends: [])
    }
}

enum Collections: String {
    case articles
    case users
}

class FirestoreManager {
    
    static let shared = FirestoreManager()
    
    private let db = Firestore.firestore()
    
    func getAllData<T: Decodable>(collection: Collections, completion: @escaping (Result<[T], Error>) -> Void) {
        db.collection(collection.rawValue).getDocuments {
            snapShot, error in
            guard let snapShot = snapShot else { return }
            let docs = snapShot.documents.compactMap {
                snapShot in
                try? snapShot.data(as: T.self)
            }
            completion(Result.success(docs))
        }
    }
    
    func getUserInfo(user: UserAccount, completion: @escaping (Result<UserObject, Error>) -> Void) {
        db.collection(Collections.users.rawValue).whereField("email", isEqualTo: user.email).getDocuments {
            snapShot, error in
            if let error = error { completion(.failure(error)) }
            if let snapShot = snapShot,
               snapShot.documents.count > 0 {
                let userObject = try? snapShot.documents.first?.data(as: UserObject.self)
                completion(.success(userObject!))
            } else {
                let newUser = UserObject.createUserObject(user: user)
                self.writeDate(collection: .users, data: newUser) {
                    result in
                    switch result {
                    case .success(_):
                        completion(.success(newUser))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
        }
    }
    
    func searchUser(email: String, completion: @escaping (Result<[UserObject], Error>) -> Void) {
        db.collection(Collections.users.rawValue).whereField("email", isEqualTo: email).getDocuments {
            snapShot, error in
            if let error = error {
                completion(.failure(error))
            }
            if let snapShot = snapShot {
                let users = snapShot.documents.compactMap {
                    snapShot in
                    try? snapShot.data(as: UserObject.self)
                }
                completion(.success(users))
            }
        }
    }
    
    func writeDate<T: Encodable>(collection: Collections, data: T, completion: @escaping (Result<String, Error>) -> Void) {
        do {
            let documentReference = try db.collection(collection.rawValue).addDocument(from: data)
            completion(.success(documentReference.documentID))
        } catch {
            completion(.failure(error))
        }
    }
    
    func signIn(user: UserAccount, completion: @escaping (Result<String, Error>) -> Void) {
        Auth.auth().signIn(withEmail: user.email, password: user.password) {
            user, error in
            if let error = error {
                completion(.failure(error))
            }
            if let result = user {
                completion(.success(result.user.uid))
            }
        }
    }
    
    func signUp(user: UserAccount, completion: @escaping (Result<String, Error>) -> Void) {
        Auth.auth().createUser(withEmail: user.email, password: user.password) {
            user, error in
            if let error = error {
                completion(.failure(error))
            }
            if let result = user {
                completion(.success(result.user.uid))
            }
        }
    }
    
    func listen(collection: Collections, completion: @escaping (Result<[DocumentChange], Error>) -> Void) {
        db.collection(collection.rawValue).addSnapshotListener { (snapShot, error) in
            if let error = error {
                completion(.failure(error))
            }
            guard let snapShot = snapShot else { return }
            completion(.success(snapShot.documentChanges))
        }
    }
}
