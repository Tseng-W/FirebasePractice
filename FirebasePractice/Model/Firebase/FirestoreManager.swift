//
//  FirebaseHandler.swift
//  FirebasePractice
//
//  Created by 曾問 on 2021/4/20.
//

import UIKit
import FirebaseFirestoreSwift
import Firebase

enum ArticleTag: String, Codable {
    case beauty
    case gossiping
    case schoolLife
    
    enum CodingKeys: String, CodingKey {
        case beauty = "Beauty"
        case gossiping = "Gossiping"
        case schoolLife = "SchoolLife"
    }
    
    static func index(_ index: Int) -> ArticleTag? {
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

struct ArticleObject: Codable, Identifiable {
    @DocumentID var docId: String?
    let id: String
    let title: String
    let content: String
    let tag: ArticleTag
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
    var invites: [String]
    var friends: [String]
    
    static func createUserObject(user: UserAccount) -> UserObject {
        let subMail = user.email.components(separatedBy: "@")[0]
        return UserObject(
            docID: nil,
            id: "id_\(subMail)",
            email: user.email,
            name: "name_\(subMail)",
            invites: [],
            friends: [])
    }
    
    mutating func addInvites(docId: String) {
        invites.append(docId)
    }
    
    mutating func addFriends(docId: String) {
        friends.append(docId)
    }
    
    func canInvited(target: String) -> Bool {
        return !invites.contains(target)
    }
}

enum Collections: String {
    case articles
    case users
}

enum WhereType {
    case greater
    case greaterOrEqual
    case equal
    case euqalOrLess
    case less
}

struct CollectionFilter {
    let type: WhereType
    let paramName: String
    let value: String
}

class FirestoreManager {
    
    static let shared = FirestoreManager()
    
    private let db = Firestore.firestore()

    func getData<T: Decodable>(collection: Collections, filter: [CollectionFilter]?, completion: @escaping (Result<[T], Error>) -> Void) {
        let collectionPath = db.collection(collection.rawValue)
        
        if let filter = filter {
            filter.forEach {
                filter in
                switch filter.type {
                case .greater:
                    collectionPath.whereField(filter.paramName, isGreaterThan: filter.value)
                case .greaterOrEqual:
                    collectionPath.whereField(filter.paramName, isGreaterThanOrEqualTo: filter.value)
                case .equal:
                    collectionPath.whereField(filter.paramName, isEqualTo: filter.value)
                case .euqalOrLess:
                    collectionPath.whereField(filter.paramName, isLessThanOrEqualTo: filter.value)
                case .less:
                    collectionPath.whereField(filter.paramName, isLessThan: filter.value)
                }
            }
        }
        
        collectionPath.getDocuments {
            snapShot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            let result = snapShot?.documents.compactMap {
                snapShot in
                try? snapShot.data(as: T.self)
            }
            
            if let result = result {
                completion(.success(result))
            }
            completion(.success([]))
        }
    }
    
    func getUserInfo(user: UserAccount, completion: @escaping (Result<UserObject, Error>) -> Void) {
        db.collection(Collections.users.rawValue).whereField("email", isEqualTo: user.email).getDocuments {
            snapShot, error in
            if let error = error { completion(.failure(error)) }
            if let snapShot = snapShot,
               snapShot.documents.count > 0 {
                let userObject = try? snapShot.documents.first?.data(as: UserObject.self)
                UserDefaults.standard.setValue(userObject!.docID, forKey: "selfId")
                completion(.success(userObject!))
            } else {
                var newUser = UserObject.createUserObject(user: user)
                self.writeDate(collection: .users, data: newUser) {
                    result in
                    switch result {
                    case .success(let docID):
                        newUser.docID = docID
                        UserDefaults.standard.setValue(docID, forKey: "selfId")
                        completion(.success(newUser))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
        }
    }
    
    func updateInvites(newUser: UserObject, completion: @escaping (Result<UserObject, Error>) -> Void) {
        db.collection(Collections.users.rawValue).document(newUser.docID!).updateData(["invites": newUser.invites]) {
            error in
            if let error = error {
                completion(.failure(error))
            }
            completion(.success(newUser))
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
    
    func connectFriend(acceptUser: UserObject, inviteUser: UserObject, completion: @escaping (Result<UserObject, Error>) -> Void) {
        // MARK: 移除對方的邀請，這時雙方不觸發事件
        var newInvites = inviteUser.invites
        guard let index = newInvites.firstIndex(of: acceptUser.docID!) else { return }
        newInvites.remove(at: index)
        db.collection(Collections.users.rawValue).document(inviteUser.docID!).updateData(["invites": newInvites]) {
            error in
            if let error = error{ completion(.failure(error)) }
        }
        
        // MARK: 優先同意方先加好友，以利被同意方判斷是否為首次加入好友
        var newFriends = acceptUser.friends
        newFriends.append(inviteUser.docID!)
        db.collection(Collections.users.rawValue).document(acceptUser.docID!).updateData(["friends": newFriends]) { [weak self]
            error in
            if let error = error { completion(.failure(error)) }
            newFriends = inviteUser.friends
            newFriends.append(acceptUser.docID!)
            self?.db.collection(Collections.users.rawValue).document(inviteUser.docID!).updateData(["friends": newFriends]) {
                error in
                if let error = error { completion(.failure(error)) }
                completion(.success(acceptUser))
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
    
    func addListener(collection: Collections, completion: @escaping (Result<[DocumentChange], Error>) -> Void) {
        db.collection(collection.rawValue).addSnapshotListener { (snapShot, error) in
            if let error = error {
                completion(.failure(error))
            }
            guard let snapShot = snapShot else { return }
            completion(.success(snapShot.documentChanges))
        }
    }
}
