//
//  CredentialsController.swift
//  Music Goer
//
//  Created by Ben Erekson on 9/22/21.
//

import Foundation
import GameplayKit

class CredentialsController {
    static var shared = CredentialsController()
    
    var currentCredentials: Credentials?
    
    //MARK: - Persistance
    ///Returns URL for persistent store on device
    func createPresistenceStore() -> URL {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let fileURL = url[0].appendingPathComponent("credentials.json")
        return fileURL
    }
    ///Saves currentCredentails to persistent store and encrypts them
    func saveToPresistenceStore() {
        guard let currentCredentials = currentCredentials else {return}
        
        if let email = currentCredentials.email {
            currentCredentials.email = encrypt(string: email, isEncrypting: true)
        }
        if let password = currentCredentials.password {
            currentCredentials.password = encrypt(string: password, isEncrypting: true)
        }
        
        do {
            let data = try JSONEncoder().encode(currentCredentials)
            try data.write(to: createPresistenceStore())
        } catch {
            print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
        }
    }
    /**
     Loads and decrypts credentials from persistent store.
     
     - Parameter completion: Runs at the completion of all tasks to help resolve conflicts with singletons.
     */
    func loadFromPresistenceStore(completion: @escaping (Bool) -> Void) {
        do {
            let data = try Data(contentsOf: createPresistenceStore())
            currentCredentials = try JSONDecoder().decode(Credentials.self, from: data)
            
            guard let currentCredentials = currentCredentials else {return}
            
            if let email = currentCredentials.email {
                currentCredentials.email = encrypt(string: email, isEncrypting: false)
            }
            if let password = currentCredentials.password {
                currentCredentials.password = encrypt(string: password, isEncrypting: false)
            }
            
            return completion(true)
        }catch {
            print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            return completion(false)
        }
    }
    ///Removes persistent store.
    func deletePersistentStore() {
        do {
            try FileManager.default.removeItem(at: createPresistenceStore())
        } catch {
            print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
        }
    }
    
    //MARK: - Encryption
    ///Encrypts a String and returns an encrypted string.
    private func encrypt(string: String, isEncrypting: Bool) -> String? {
        var encryptedString = ""
        for charecter in string {
            let array = (String(charecter).unicodeScalars)
            var number = array[array.startIndex].value
            let randomNum: UInt32 = 496
            isEncrypting ? (number += randomNum) : (number -= randomNum)
            
            guard let unicode = UnicodeScalar(number) else { return nil}
            
            let newCharecter = Character(unicode)
            
            encryptedString += "\(newCharecter)"
        }
        return encryptedString
    }
}
