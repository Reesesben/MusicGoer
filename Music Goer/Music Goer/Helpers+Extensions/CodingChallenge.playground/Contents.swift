import UIKit

//Write a function that accepts a String as its only parameter, and returns true if the string has
//only unique letters, taking letter case into account.
//Sample input and output
//• The string “No duplicates” should return true.
//• The string “abcdefghijklmnopqrstuvwxyz” should return true.
//• The string “AaBbCc” should return true because the challenge is case-sensitive.
//• The string “Hello, world” should return false because of the double Ls and double Os.

func noDuplicates( _ testString: String) -> Bool {
//    var letters: [Character] = []
//
//    for letter in testString {
//        if !letters.contains(letter) {
//            letters.append(letter)
//        } else {
//            return false
//        }
//    }
    
    let stringArray = Array(testString)
    let arraySet = Set(stringArray)
    
    return stringArray.count == arraySet.count
}

let testOne = "AaBbCc"

let testTwo = "Hello, world"


print("Test one: \(noDuplicates(testOne))")
print("Test two: \(noDuplicates(testTwo))")
