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
    func createPresistenceStore() -> URL {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let fileURL = url[0].appendingPathComponent("credentials.json")
        return fileURL
    }
    
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
    
    func deletePersistentStore() {
        do {
            try FileManager.default.removeItem(at: createPresistenceStore())
        } catch {
            print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
        }
    }
    
    //MARK: - Encryption
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
        print("Encrypted String: \(encryptedString)")
        return encryptedString
    }
}
